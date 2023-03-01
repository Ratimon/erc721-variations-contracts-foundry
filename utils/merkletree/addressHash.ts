import {Wallet} from '@ethersproject/wallet';
import {keccak256 as solidityKeccak256} from '@ethersproject/solidity';

// export function calculateHash(passId: string, signer: string): string {
//   return solidityKeccak256(['uint256', 'address'], [passId, signer]);
// }

export function calculateHash(address: string): string {
    return solidityKeccak256(["address"], [address]);
  }

// export function hashLeaves(data: {passId: string; signer: string}[]): string[] {
//   const hashedLeaves: string[] = [];

//   for (let i = 0; i < data.length; i++) {
//     hashedLeaves.push(calculateHash(data[i].passId, data[i].signer));
//   }

//   return hashedLeaves;
// }

export function hashLeaves(data: {Address: string}[]): string[] {
    const hashedLeaves: string[] = [];
  
    for (let i = 0; i < data.length; i++) {
      hashedLeaves.push(calculateHash(data[i].Address));
    }
  
    return hashedLeaves;
  }


// export function createLeavesFromPrivateKeys(
//     startIndex: number,
//     privateKeys: string[]
// ): {passId: string; signer: string}[] {
//     const leaves: {passId: string; signer: string}[] = [];

//     for (let i = 0; i < privateKeys.length; i++) {
//     const privateKey = privateKeys[i];
//     leaves.push({passId: '' + (startIndex + i), signer: new Wallet(privateKey).address});
//     }

//     return leaves;
// }

export function createLeavesFromAddress(
    Addresses: string[]
): {Address: string}[] {
const leaves: {Address: string}[] = [];

for (let i = 0; i < Addresses.length; i++) {
    const address = Addresses[i];
    leaves.push({Address: address});
}

return leaves;
}