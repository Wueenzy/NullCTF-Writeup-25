// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Coin.sol";
import "./Casino.sol";

contract Setup {
    LuckToken public token;
    Casino public casino;

    constructor() payable {
        require(msg.value == 100 ether, "Setup requires 100 Ether");

        token = new LuckToken();
        casino = new Casino(address(token));

        uint256 luckSupply = address(this).balance / 100;

        token.mint(address(this), luckSupply);
        token.transferOwnership(address(casino));
        token.transfer(address(casino), luckSupply);
        
        payable(address(casino)).transfer(address(this).balance);
    }

    function isSolved() external view returns (bool) {
        return address(token).balance < 1 ether;
    }
}