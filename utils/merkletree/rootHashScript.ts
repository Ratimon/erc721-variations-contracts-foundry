import { readFileSync } from "fs";
import path from 'path';

import { BigNumber, BigNumberish, utils} from 'ethers';

import { MerkleTree} from "../../utils/merkletree";
import { calculateHash, hashLeaves, createLeavesFromAddress} from "../../utils/merkletree";

async function main(): Promise<void> {
   // Hardhat always runs the compile task when running scripts through it.
   // If this runs in a standalone fashion you may want to call compile manually
   // to make sure everything is compiled
   // await run("compile");

   

   const fileName = (false) ? `address.production.json` : `address.test.json`
   const addresses= JSON.parse(readFileSync(path.resolve(__dirname, `./data/`+fileName) ).toString());
   const leaves = createLeavesFromAddress(addresses);
   const tree = new MerkleTree(hashLeaves(leaves));
   const merkleRootHash = tree.getRoot().hash;

   console.log('merkleRootHash',merkleRootHash)

}  
 // We recommend this pattern to be able to use async/await everywhere
 // and properly handle errors.
 main()
   .then(() => process.exit(0))
   .catch((error: Error) => {
     console.error(error);
     process.exit(1);
   });