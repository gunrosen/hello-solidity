## Multiply before Dividing
[Link](https://soliditydeveloper.com/solidity-design-patterns-multiply-before-dividing)

```javascript
console.log((30 / 13) \* 100 \* 13)
< 2999.9999999999995

console.log((30 * 100 * 13) / 13)
< 3000
```

Another solution is using numerator and denominator
```solidity
uint256 numerator = 30 * 100 * 13;
uint256 denominator = 13;
```