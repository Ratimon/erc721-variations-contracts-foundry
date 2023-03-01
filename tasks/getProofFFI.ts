import {HardhatRuntimeEnvironment} from 'hardhat/types';
import { task } from "hardhat/config";

import { readFileSync } from "fs";
import path from 'path';
import { BigNumber, BigNumberish, utils} from 'ethers';

import { MerkleTree} from "../utils/merkletree";
import { calculateHash, hashLeaves, createLeavesFromAddress} from "../utils/merkletree";

const { 
	defaultAbiCoder,
   } = utils;


export default async () => { 

    task( 'getProofFFI', 'Get Proofs')
        .addParam('address', 'address being hashed')
        .setAction(async (_taskArgs, hre: HardhatRuntimeEnvironment) => {


            const fileName = (false) ? `address.production.json` : `address.test.json`


            const addresses= JSON.parse(readFileSync(path.resolve(__dirname, `../utils/merkletree/data/`+fileName) ).toString());
            // const first_address = addresses[0];
            const leaves = createLeavesFromAddress(addresses);
            const tree = new MerkleTree(hashLeaves(leaves));

            const proof = tree.getProof(calculateHash(_taskArgs.address));
         
         //    console.log('first_address',first_address)
         //    console.log('proof',proof)
         
            const encodedData = defaultAbiCoder.encode(
             ['bytes32[2] proof'],
             [proof]
            )
         
            process.stdout.write(encodedData);


        })

}