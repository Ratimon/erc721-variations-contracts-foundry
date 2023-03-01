import { readFileSync } from "fs";
import path from 'path';
import { BigNumber, BigNumberish, utils} from 'ethers';

import { MerkleTree} from ".";
import { calculateHash, hashLeaves, createLeavesFromAddress} from ".";

const { 
	defaultAbiCoder,
   } = utils;

   const fileName = (false) ? `address.production.json` : `address.test.json`
   const addresses= JSON.parse(readFileSync(path.resolve(__dirname, `./data/`+fileName) ).toString());
   const leaves = createLeavesFromAddress(addresses);
   const tree = new MerkleTree(hashLeaves(leaves));
   const merkleRootHash = tree.getRoot().hash;

   const encodedData = defaultAbiCoder.encode(
    ['bytes32 hash'],
    [merkleRootHash]
   )

process.stdout.write(encodedData);
