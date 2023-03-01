import { readFileSync } from "fs";
import path from 'path';

import { BigNumber, BigNumberish, utils} from 'ethers';

import { MerkleTree} from ".";
import { calculateHash, hashLeaves, createLeavesFromAddress} from ".";

const { 
	defaultAbiCoder,
   } = utils;

async function main(): Promise<void> {
   // Hardhat always runs the compile task when running scripts through it.
   // If this runs in a standalone fashion you may want to call compile manually
   // to make sure everything is compiled
   // await run("compile");

  //  process.argv.forEach(function (val, index, array) {
  //   console.log(index + ': ' + val);
  //   });

   

   const fileName = (false) ? `address.production.json` : `address.test.json`
   const addresses= JSON.parse(readFileSync(path.resolve(__dirname, `./data/`+fileName) ).toString());
   const first_address = addresses[0];
   const leaves = createLeavesFromAddress(addresses);
   const tree = new MerkleTree(hashLeaves(leaves));
   //    const merkleRootHash = tree.getRoot().hash;
   const proof = tree.getProof(calculateHash(first_address));

   console.log('first_address',first_address)
   console.log('proof',proof)
   console.log('proof length',proof.length)

  //  const encodedData = defaultAbiCoder.encode(
  //   ['bytes32[2] proof'],
  //   [proof]
  //  )

  const encodedData = defaultAbiCoder.encode(
    [`bytes32[${proof.length}]`],
    [proof]
   )
   console.log('encodedData',encodedData)


   const decodedData = defaultAbiCoder.decode(
      [`bytes32[${proof.length}]`],
      encodedData
   )

   console.log('decodedData',decodedData)


}  
 // We recommend this pattern to be able to use async/await everywhere
 // and properly handle errors.
 main()
   .then(() => process.exit(0))
   .catch((error: Error) => {
     console.error(error);
     process.exit(1);
   });