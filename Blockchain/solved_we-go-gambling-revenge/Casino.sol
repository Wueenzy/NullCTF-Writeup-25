// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Coin.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Casino {
    LuckToken public token;
    uint256 public constant RATE = 100;

    event Won(address indexed player, uint256 amount);
    event Lost(address indexed player, uint256 amount);

    constructor(address _tokenAddress) {
        token = LuckToken(_tokenAddress);
    }

    receive() external payable {}

    function buyLuck() public payable {
        require(msg.value >= RATE, "Send at least 100 wei");
        uint256 luckAmount = msg.value / RATE;
        
        require(token.balanceOf(address(this)) >= luckAmount, "Casino has insufficient LUCK");
        token.transfer(msg.sender, luckAmount);
    }

    function sellLuck(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        uint256 ethAmount = amount * RATE;
        require(address(this).balance >= ethAmount, "Casino has insufficient ETH liquidity");

        token.transferFrom(msg.sender, address(this), amount);

        payable(msg.sender).transfer(ethAmount);
    }

    function play(uint256 betAmount) public {
        require(msg.sender.code.length == 0, "Contracts are not allowed to play");
        require(token.balanceOf(msg.sender) >= betAmount, "Insufficient LUCK tokens");
        require(token.allowance(msg.sender, address(this)) >= betAmount, "Please approve tokens first");

        token.transferFrom(msg.sender, address(this), betAmount);

        uint256 random = uint256(keccak256(abi.encodePacked(
            block.timestamp, 
            block.prevrandao, 
            msg.sender
        ))) % 100;

        if (random < 25) {
            uint256 prize = betAmount * 4;
            require(token.balanceOf(address(this)) >= prize, "Casino cannot afford payout");
            token.transfer(msg.sender, prize);
            emit Won(msg.sender, prize);
        } else {
            emit Lost(msg.sender, betAmount);
        }
    }
}