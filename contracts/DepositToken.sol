// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {ERC20} from "./ERC20.sol";

contract DepositToken is ERC20 {
    address public owner;

    constructor() ERC20("DepositB", "DEPB", 0) {
        owner = msg.sender;
    }

    function mint(address _to, uint _amount) external {
        require(msg.sender == owner, "DEPB: Only owner can mint");
        _mint(_to, _amount);
    }

    function burn(address _from, uint _amount) external {
        require(msg.sender == owner, "DEPB: Only owner can burn");
        _burn(_from, _amount);
    }
}
