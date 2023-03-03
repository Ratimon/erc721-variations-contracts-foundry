// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * @title SimpleNFTEnumerate
 * @notice it enumerates prime numbers of ERC721Enumerable
 */
contract SimpleNFTEnumerate {

    IERC721Enumerable public immutable enumeratableNFT;

    constructor(address _enumeratableNFTt) {
        enumeratableNFT = IERC721Enumerable(_enumeratableNFTt);
    }

    function primeBalanceOf(address owner) external view returns(uint256) {

        uint256 totalOwnerBalance = enumeratableNFT.balanceOf(owner);

        uint8 primeNumberCounter;

        for (uint i=0; i < totalOwnerBalance; i++ ) {

            uint256 tokenId = enumeratableNFT.tokenOfOwnerByIndex(owner, i);

            if(tokenId == 1) continue;
            if(tokenId < 4) {
                primeNumberCounter++;
                continue;
            }
            if(tokenId % 2 == 0) continue;

            // Assuming it is prime first then use the odd numbers to test against by dividing
            bool isTokenIdPrime = true;
            uint256 upperBound = tokenId / 2;

            for(uint256 j=3; j < upperBound; j = j + 2) {
                if(tokenId % j == 0) {
                    isTokenIdPrime = false;
                    break;
                }
            }
            if (isTokenIdPrime) primeNumberCounter++;

        }
        return primeNumberCounter;
    }

}