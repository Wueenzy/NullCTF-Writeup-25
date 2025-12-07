// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Coin.sol";

contract Setup {
    Coin public coin;

    constructor() payable {
        require(msg.value == 101 ether, "Setup requires exactly 101 ETH");

        coin = new Coin{value: 1 ether}();
        coin.exchange{value:  100 ether}();
    }

    function isSolved() external view returns (bool) {
        return address(coin).balance < 1 ether;
    }
}