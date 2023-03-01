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

    task( "getRootHash", "getRootHash from Merklerootr",
        async (_, hre: HardhatRuntimeEnvironment ) => {


            const fileName = (false) ? `address.production.json` : `address.test.json`
            const addresses= JSON.parse(readFileSync(path.resolve(__dirname, `../utils/merkletree/data/`+fileName) ).toString());
            const leaves = createLeavesFromAddress(addresses);
            console.log("hashleaves",hashLeaves(leaves));
         
            const tree = new MerkleTree(hashLeaves(leaves));
            const merkleRootHash = tree.getRoot().hash;
         
            console.log('tree.getRoot()',tree.getRoot())
         
         
         
            console.log('merkleRootHash',merkleRootHash)

            // const encodedData = defaultAbiCoder.encode(
            //     ['bytes32 merkleRootHash'],
            //     [merkleRootHash]
            //    )
            
            //    console.log('encodedData',encodedData)


        })
    }