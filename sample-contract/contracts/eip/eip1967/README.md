### EIP 1967
It describes a consistent location where proxies store the address of the logic contract they delegate to, as well as proxy-specific information

To avoid clashes in storage usage between the proxy and logic contract, the address of the logic contract is typically saved in specific storage slot

`0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`

equivalent to

`bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`

OpenZepplin uses EIP1967