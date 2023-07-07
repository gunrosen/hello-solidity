### How will `calldata` be structured or how data encoded

In this example, we have function, see [DoubleEntryPoint](https://github.com/gunrosen/hello-solidity/tree/main/sample-contract/contracts/ethernaut/DoubleEntryPoint/DoubleEntryPoint.sol)

```solidity
function handleTransaction(address user, bytes calldata msgData) external;
```

the `calldata` is taken from modifier and then passed to `handleTransaction`
```solidity
    function notify(address user, bytes calldata msgData) external override {
        if(address(usersDetectionBots[user]) == address(0)) return;
        try usersDetectionBots[user].handleTransaction(user, msgData) {
            return;
        } catch {}
    }

    modifier fortaNotify() {
        address detectionBot = address(forta.usersDetectionBots(player));

        // Cache old number of bot alerts
        uint256 previousValue = forta.botRaisedAlerts(detectionBot);

        // Notify Forta
        forta.notify(player, msg.data);

        // Continue execution
        _;

        // Check if alarms have been raised
        if(forta.botRaisedAlerts(detectionBot) > previousValue) revert("Alert has been triggered, reverting");
    }

```

And potentially, `msg.data` comes from `delegateTransfer`
```solidity
    function delegateTransfer(
        address to,
        uint256 value,
        address origSender
    ) public override onlyDelegateFrom fortaNotify returns (bool) {
        _transfer(origSender, to, value);
        return true;
    }
```

Now, we measure msg.data, potentially user call `sweepToken` from `CryptoVault`. `CryptoVault` calls `LegacyToken` transfer but logic in here not right, it will make `delegateTransfer(address to, uint256 value, address origSender)`.
By that, `DEP token` can be drained.

We will prevent that with `Forta` by `raise alert` if `origSender` is 'CryptoVault'. Only check by `msgData`

`msgData` structure is 

| Location   |      Size(byte)      |  Detail |
|----------|:-------------:|------:|
| 0-4 |  4  | `keccak256('notify(address,bytes)')` |
| 4-36 |    32   |   address user |
| 36-68 | 32 |    location of bytes (64 or 0x40) |
| 68-100 | 32 |   length of bytes |
| 100-104 | 4 |   `keccak256('delegateTransfer(address,uint256,address)')` |
| 104-136 | 32 |   address |
| 136-168 | 32 |   uint256 |
| 168-200 | 32 |   address (origSender: That what we need) |
| 200-228 | 28 |   28 bytes padding cause rule of encoding bytes |

Location if origSender at 168 or 0xa8

We can extract it by 

```solidity
contract MyDetectionBot is IDetectionBot {
    address public cryptoVaultAddress;

    constructor(address _cryptoVaultAddress) {
        cryptoVaultAddress = _cryptoVaultAddress;
    }

    // we can comment out the variable name to silence "unused parameter" error
    function handleTransaction(address user, bytes calldata /* msgData */) external override {
        // extract sender from calldata
        address origSender;
        assembly {
            origSender := calldataload(0xa8)
        }

        // raise alert only if the msg.sender is CryptoVault contract
        if (origSender == cryptoVaultAddress) {
            Forta(msg.sender).raiseAlert(user);
        }
    }
}
```







