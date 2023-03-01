import { readFileSync } from "fs";
import { BigNumber, BigNumberish, utils} from 'ethers';

import { MerkleTree} from "../../utils/merkletree";
import { calculateHash, hashLeaves, createLeavesFromAddress} from "../../utils/merkletree";

const { 
	defaultAbiCoder,
   } = utils;

   const fileName = (false) ? `address.production.json` : `address.test.json`
   const addresses= JSON.parse(readFileSync(fileName).toString());
   const leaves = createLeavesFromAddress(addresses);
   const tree = new MerkleTree(hashLeaves(leaves));
   const merkleRootHash = tree.getRoot().hash;

   const encodedData = defaultAbiCoder.encode(
    ['bytes32 hash'],
    [merkleRootHash]
   )

process.stdout.write(encodedData);

//    const proof = tree.getProof(calculateHash(firstKyc));

