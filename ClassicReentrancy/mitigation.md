## Recommended Mitigation

The `Vulnerable` contract suffers a **Clasical Reentrancy** risk.

The `withdrawAll()` function can be reentered because external interactions occur before state changes are made. 

``` solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Vulnerable {
        mapping(address => uint256) balance;
        mapping(address => bool) vip;

        function deposit() external payable {
            balance[msg.sender] += msg.value;
        }

        function withdrawAll() external {
            // Checks!
            require(balance[msg.sender] > 0, "Not enough funds");
            // Interactions D: VULNERABLE!!
            (bool success,) = payable(msg.sender).call{value: balance[msg.sender]}("");
            require(success, "Low level call failed");
            // Effects :(
            balance[msg.sender] = 0;
        }

        function withdrawSome(uint256 amount) external {
            // Checks!
            require(balance[msg.sender] >= amount, "Not enough funds");
            // Interactions D: VULNERABLE!!... but exploitable?
            (bool success,) = payable(msg.sender).call{value: balance[msg.sender]}("");
            require(success, "Low level call failed");
            // Effects :(
            balance[msg.sender] -= amount;
        }

        function userBalance(address _user) public view returns (uint256) {
            return balance[_user];
        }
    }
```

To mitigate this, the **CEI (Check Effect Interaction)** pattern should be followed. In this pattern, all state changes are made before any external interactions occur.

``` solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Vulnerable {
        mapping(address => uint256) balance;
        mapping(address => bool) vip;

        function deposit() external payable {
            balance[msg.sender] += msg.value;
        }

        function withdrawAll() external {
            // Checks!
            require(balance[msg.sender] > 0, "Not enough funds");
            // Effects :)
            balance[msg.sender] = 0;
            // Interactions D: NO LONGER VULNERABLE!!
            (bool success,) = payable(msg.sender).call{value: balance[msg.sender]}("");
            require(success, "Low level call failed");
        }

        function withdrawSome(uint256 amount) external {
            // Checks!
            require(balance[msg.sender] >= amount, "Not enough funds");
            // Interactions D: VULNERABLE!!... but exploitable?
            (bool success,) = payable(msg.sender).call{value: balance[msg.sender]}("");
            require(success, "Low level call failed");
            // Effects :(
            balance[msg.sender] -= amount;
        }

        function userBalance(address _user) public view returns (uint256) {
            return balance[_user];
        }
    }
```

**P.S.** Will try to exploit the `withdrawSome()` function.