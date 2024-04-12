const {MerkleTree} = require("merkletreejs");
const keccak256 = require("keccak256");
const whitelist = [
    '0x6090A6e47849629b7245Dfa1Ca21D94cd15878Ef',
    '0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8',
    '0xc0ffee254729296a45a3885639AC7E10F9d54979',
    '0x999999cf1046e68e36E1aA2E0E07105eDDD1f08E',
    '0x45546902B19438e1C8c32e3BdAc97F58D4b4638f',
    '0xb894820C040E86aeae468118F2Ae2Bb61E066a2D',
    '0xcc8176d81Db7DE8045858eE43522Cc5eB4751E56'

];
const leaves = whitelist.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true});
const rootHash = merkleTree.getRoot().toString('hex');
console.log(`Whitelist Merkle Root: 0x${rootHash}`);
console.log(merkleTree.toString())

// console.log("proofs:")
// const proofs = merkleTree.getHexProofs();
// proofs.forEach((proof) => console.log(proof))
whitelist.forEach((address) => {
    const proof = merkleTree.getHexProof(keccak256(address));
    console.log(`------\nAdddress: ${address} \nProof: ${proof}`);
});

console.log(`--------------------------------`)
badLeafAddress = "0x45546902B19438e1C8c32e3BdAc97F58DXXXXXXX"
console.log(`Bad leaf: ${badLeafAddress}`)
const badLeaf = keccak256(badLeafAddress)
const badProof = merkleTree.getProof(badLeaf);
console.log(`verify result = ${merkleTree.verify(badProof, badLeaf, rootHash)}`)

console.log(`--------------------------------`)
goodLeafAddress = "0x45546902B19438e1C8c32e3BdAc97F58D4b4638f"
console.log(`Good leaf: ${goodLeafAddress}`)
const goodLeaf = keccak256(goodLeafAddress)
const goodProof = merkleTree.getProof(goodLeaf);
console.log(`verify result = ${merkleTree.verify(goodProof, goodLeaf, rootHash)}`)