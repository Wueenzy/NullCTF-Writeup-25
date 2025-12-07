// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Coin is ERC20 {
    uint256 public constant INITIAL_RATE = 100; 

    constructor() ERC20("Nullium", "NULL") payable {
        
    }

    function exchange() external payable {
        require(msg.value > 0, "Must send ETH");

        uint256 _totalSupply = totalSupply();
        uint256 amountToMint;

        if (_totalSupply == 0) {
            amountToMint = msg.value * INITIAL_RATE;
        } else {
            uint256 ethReserve = address(this).balance - msg.value;
            amountToMint = (msg.value * _totalSupply) / ethReserve;
        }

        _mint(msg.sender, amountToMint);
    }

    function burn(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        uint256 _totalSupply = totalSupply();
        uint256 ethBalance = address(this).balance;

        uint256 ethToReturn = (amount * ethBalance) / _totalSupply;

        require(address(this).balance >= ethToReturn, "Liquidity error");

        (bool success, ) = payable(msg.sender).call{value: ethToReturn}("");
        require(success, "Transfer failed");

        _burn(msg.sender, amount);
    }

    function burnFree(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient token balance");

        _burn(msg.sender, amount);     
    }
}