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
   const first_address = addresses[0];
   const leaves = createLeavesFromAddress(addresses);
   const tree = new MerkleTree(hashLeaves(leaves));
   const proof = tree.getProof(calculateHash(first_address));

//    console.log('first_address',first_address)
//    console.log('proof',proof)

   const encodedData = defaultAbiCoder.encode(
    ['bytes32[2] proof'],
    [proof]
   )

process.stdout.write(encodedData);