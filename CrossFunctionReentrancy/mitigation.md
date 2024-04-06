## Recommended Mitigation

The `Vulnerable` contract suffers a Cross-Function Reentrancy risk.

Despite the `withdraw()` function using a `nonReentrant` from the `Reentrancy Guard` from `OpenZeppelin`, because it doesn't follow the `CEI` pattern, it can be reentered through the `transferToInternally()` function.

``` solidity
    // rest of code
    function withdraw() external nonReentrant {
        require(balance[msg.sender] > 0, "No funds available!");

        (bool success,) = payable(msg.sender).call{value: balance[msg.sender]}("");
        require(success, "Transfer failed");

        balance[msg.sender] = 0;
    }

    function transferToInternally(address _recipient, uint256 _amount) external {
        // nonReentrant here will mitigate the exploit
        require(balance[msg.sender] >= _amount, "Not enough funds to transfer!");
        balance[msg.sender] -= _amount;
        balance[_recipient] += _amount;
    }

    // rest of code
```

To mitigate this risk, the `withdraw()` function should follow the `CEI` pattern, also, the `nonReentrant` can be used on the `transferToInternally()` function.

``` solidity
    // rest of code
    function withdraw() external nonReentrant {
        // Check
        require(balance[msg.sender] > 0, "No funds available!");

        // Effect
        balance[msg.sender] = 0;

        // Interaction
        (bool success,) = payable(msg.sender).call{value: balance[msg.sender]}("");
        require(success, "Transfer failed");
    }

    function transferToInternally(address _recipient, uint256 _amount) external nonReentrant {
        require(balance[msg.sender] >= _amount, "Not enough funds to transfer!");
        balance[msg.sender] -= _amount;
        balance[_recipient] += _amount;
    }

    // rest of code
```

