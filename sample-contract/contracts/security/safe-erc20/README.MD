## Openzepplin safeTransfer in SafeERC20

SafeERC20 is not an ERC20 extension that you use to make your token safe (OpenZeppelin’s ERC20 is already safe)

It’s a helper to make safe the interaction with someone else’s ERC20 token, in your contracts

`using SafeERC20 for IERC20` allows us to use safe operations on values of type `IERC20`
and then call `tradingToken.safeTransferFrom`