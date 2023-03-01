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

   console.log('first_address',first_address)
   console.log('proof',proof)

   console.log('addresses',addresses)



   const encodedData = defaultAbiCoder.encode(
    ['bytes32[] proof'],
    [proof]
   )

   // const decodedData = defaultAbiCoder.decode(
   //    ['bytes32[] proof'],
   //    encodedData
   // )

   // console.log('decodedData',decodedData)

   // const input : any =  { "proofs": proof}

   // console.log(input)

   // const encodedData = defaultAbiCoder.encode(
   //    ['tuple(string[] proof)'],
   //    [ { "proofs": proof} ]
   //   )

   //   const encodedData = defaultAbiCoder.encode(
   //    ['string[2] proof'],
   //    [proof]
   //   )
  
     console.log('encodedData',encodedData)
  
  
   //   const decodedData = defaultAbiCoder.decode(
   //      ['string[] proof'],
   //      encodedData
   //   )

   //   const decodedData = defaultAbiCoder.decode(
   //    ['tuple(string[] proof)'],
   //    encodedData
   // )

  
   //   console.log('decodedData',decodedData)





process.stdout.write(encodedData);