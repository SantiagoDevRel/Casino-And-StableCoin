// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {ERC20} from "./ERC20.sol";
import {DepositToken} from "./DepositToken.sol";
import {Oracle} from "./Oracle.sol";
import {WadLib} from "./WadLib.sol";

contract StableCoin is ERC20 {
    using WadLib for uint256;
    error InsufficientBalance(string message);
    DepositToken public depositToken;
    uint public feeRatePercentage;
    Oracle public oracle;
    uint256 public constant COLLATERAL_RATIO = 10;

    constructor(uint256 _feeRate, Oracle _oracle) ERC20("DollarB", "USDB", 0) {
        feeRatePercentage = _feeRate;
        oracle = _oracle;
    }

    function mint() external payable {
        uint256 fee = _getFee(msg.value);
        uint256 remainETH = msg.value - fee;
        uint256 mintStableCoin = remainETH * oracle.getPrice();
        _mint(msg.sender, mintStableCoin);
    }

    function burn(uint256 _StableCoinAmount) external {
        int256 deficitOrSurplus = _getDeficitOrSurplusInUsd();
        require(
            deficitOrSurplus >= 0,
            "StablecCoin: Can't burn while in deficit"
        );

        _burn(msg.sender, _StableCoinAmount);

        uint256 refundingEth = _StableCoinAmount / oracle.getPrice();
        uint256 fee = _getFee(refundingEth);
        uint256 remainETH = fee - refundingEth;

        (bool success, ) = msg.sender.call{value: remainETH}("");
        require(success, "StableCoin: Burn transaction failed");
    }

    function _getFee(uint256 ethAmount) private view returns (uint256) {
        //If the deposit token hasn't been created or totalsupply = 0, there is no fee yet.
        bool hasDepositors = address(depositToken) != address(0) &&
            depositToken.totalSupply() > 0;
        if (!hasDepositors) {
            return 0;
        }

        return (ethAmount * feeRatePercentage) / 100;
    }

    function depositCollateral() external payable {
        int256 deficirOrSurplus = _getDeficitOrSurplusInUsd();
        if (deficirOrSurplus <= 0) {
            uint256 deficitInUsd = uint256(deficirOrSurplus * -1);
            uint256 EthInUsdPrice = oracle.getPrice();
            uint256 deficitInEth = deficitInUsd / EthInUsdPrice;

            uint256 requiredInitialSurplusRatioInUsd = (COLLATERAL_RATIO *
                totalSupply) / 100;
            uint256 requiredInEth = requiredInitialSurplusRatioInUsd /
                EthInUsdPrice;
            require(
                msg.value > deficitInEth + requiredInEth,
                "StableCoin: Initial Collateral ratio not met"
            );
            uint256 newInitialSurplusInEth = msg.value - deficitInEth;
            uint256 newInitialSurplusInUsd = newInitialSurplusInEth *
                EthInUsdPrice;
            depositToken = new DepositToken();
            uint256 mintDepositorTokenAmount = newInitialSurplusInUsd;
            depositToken.mint(msg.sender, mintDepositorTokenAmount);
            return;
        }
        //if surplus (+positive) convert to UINT
        uint256 surplusInUsd = uint256(deficirOrSurplus);
        //get supply of
        WadLib.Wad depositTokenPriceInUsd = _getDepositTokenInUsd(surplusInUsd);
        uint256 mintDepositTokenAmount = (
            msg.value.multWad(depositTokenPriceInUsd)
        ) / oracle.getPrice();
        depositToken.mint(msg.sender, mintDepositTokenAmount);
    }

    function withdrawCollateral(uint256 _burnDepositorToken) external {
        if (_burnDepositorToken > depositToken.balanceOf(msg.sender)) {
            revert InsufficientBalance("StableCoin: Insufficient balance");
        }

        depositToken.burn(msg.sender, _burnDepositorToken);

        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInUsd();
        require(deficitOrSurplusInUsd > 0, "StableCoin: No funds available");
        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        WadLib.Wad depositTokenInUsd = _getDepositTokenInUsd(surplusInUsd);
        uint256 refundingUsd = _burnDepositorToken.multWad(depositTokenInUsd);
        uint256 refundingEth = refundingUsd / oracle.getPrice();
        (bool success, ) = payable(msg.sender).call{value: refundingEth}("");
        require(success, "StableCoin: Refund failed");
    }

    function _getDepositTokenInUsd(
        uint256 _surplusInUsd
    ) private view returns (WadLib.Wad) {
        //get totalSupply of depositToken/surplus to return the value of depositToken
        return WadLib.fromFraction(depositToken.totalSupply(), _surplusInUsd);
    }

    function _getDeficitOrSurplusInUsd() private view returns (int256) {
        //get the value in dollars of the contract (current balance in ETH * ETH Price in USD)
        uint256 contractBalanceInUsd = (address(this).balance - msg.value) *
            oracle.getPrice();

        uint256 stablecoinInUsd = totalSupply;
        //surplus = balanceETH>stableCoinMinted(totalSupply)
        //deficit = balanceETH<stableCoinMinted(totalSupply)
        int256 deficitOrSurplus = int256(contractBalanceInUsd) -
            int256(stablecoinInUsd);
        //return deficit or surplus
        return deficitOrSurplus;
    }
}
