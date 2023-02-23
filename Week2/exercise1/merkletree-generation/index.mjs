import { StandardMerkleTree } from '@openzeppelin/merkle-tree';
import fs from "fs";

// import whitelist content
const whitelist_json = JSON.parse(fs.readFileSync('whitelist.json'));

var whitelist=[];

// set json to array, to use openzeppelin merkletree implementation
for(var address in whitelist_json) {
  whitelist.push([address, whitelist_json[address]]);
}

// Generate MerkleTree
const first_tree = StandardMerkleTree.of(whitelist, ["address", "uint256"]);
console.log('Merkle Root:', first_tree.root);

// save MerkleTree to tree.json
fs.writeFileSync("tree.json", JSON.stringify(first_tree.dump()));

// get tree from tree.json (for educational purpose, because we already have the value)
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json")));


// find index for one address (here our presaleUser1 used with Foundry)
for (const [i, v] of tree.entries()) {
  if (v[0] === '0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69') {
    // (3)
    const proof = tree.getProof(i);
    console.log('Value for presaleUser1:', v);
    console.log('Proof for presaleUser1:', proof);
  }
}
