### Read chain data

Private data in smart contract is not really private 

So marking a variable as private only prevents other contracts from accessing it
State variables marked as private and local variables are still public accessible

To ensure that data is private, it needs to encrypt before put onto blockchain. And decryption key should never be sent to blockchain

```javascript

web3.eth.getStorageAt(<address>, <data index location>, (err, result) => console.log(web3.toAscii(result)));
```