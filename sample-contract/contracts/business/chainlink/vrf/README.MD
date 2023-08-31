### Verified Randomness Function
ChainLink v2 offers two methods: subscriptions and direct funding
>* Request testnet LINK and ETH here: https://faucets.chain.link/
>* Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
>
## Direct funding
| Var | Description |
| ------------- |-------------|
| uint32 callbackGasLimit      | The limit for how much gas to use for the callback request to your contract's fulfillRandomWords() function     |
| uint16 requestConfirmations      | How many confirmations the Chainlink node should wait before responding     |
| uint32 numWords      |  How many random values to request. If you can use several random values in a single callback, you can reduce the amount of gas that you spend per random value     |

## Subscriptions
Funding Link is managed in subscription account