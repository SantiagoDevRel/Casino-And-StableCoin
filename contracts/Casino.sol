// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Casino {
    mapping(address => uint) public gameValue;
    mapping(address => uint) public blockHashToBeUsed;

    function playGame() external payable {
        if (blockHashToBeUsed[msg.sender] == 0) {
            blockHashToBeUsed[msg.sender] = block.number + 2;
            gameValue[msg.sender] = msg.value;
            return;
        }
        require(msg.value == 0, "Finish current game before starting");
        require(
            blockhash(blockHashToBeUsed[msg.sender]) != 0,
            "Block has not been mined yet"
        );

        uint256 randomNumber = uint256(
            blockhash(blockHashToBeUsed[msg.sender])
        );

        //if even, win
        if (randomNumber % 2 == 0) {
            uint256 winningAmount = gameValue[msg.sender] * 2;
            (bool success, ) = payable(msg.sender).call{value: winningAmount}(
                ""
            );
            require(success, "Transfer failed");
        }
        blockHashToBeUsed[msg.sender] = 0;
        gameValue[msg.sender] = 0;
    }
}
