// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Oracle {
    address public owner;
    uint256 public price;

    constructor() {
        owner = msg.sender;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    function setPrice(uint256 _newPrice) external {
        require(
            msg.sender == owner,
            "Oracle: You are not allowed to change the price"
        );
        price = _newPrice;
    }
}
