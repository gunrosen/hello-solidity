## Un-check transfer
[REF](https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-transfer)


```text
ignores return value by IERC20(_poolAddress).transferFrom(msg.sender,address(this),_lpAmount)
ignores return value by IERC20(rewardsToken).transfer(msg.sender,totalUserReward)
```

Several tokens do not revert in case of failure and return false. 

### Recommendation
Use SafeERC20, or ensure that the transfer/transferFrom return value is checked.