// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

import {IERC721Mintable} from "@main/interfaces/IERC721Mintable.sol";

import {Errors} from "@main/shared/Error.sol";

import {ERC721EnumerableCollection} from "@main/ERC721EnumerableCollection.sol";
import {IsIdPrime} from "@main/IsIdPrime.sol";


contract TestIsIdPrime is ConstantsFixture {

    
    ERC721EnumerableCollection erc721Collection;
    IsIdPrime isIdPrime;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestIsIdPrime");

        vm.startPrank(deployer);

        erc721Collection = new ERC721EnumerableCollection(
            'Collection', "COLL", msg.sender, msg.sender
        );
        vm.label(address(erc721Collection), "erc721Collection");

        isIdPrime = new IsIdPrime(
            erc721Collection
        );
        vm.label(address(isIdPrime), "isIdPrime");

        for (uint256 i = 0; i < 20; i++) {
             IERC721Mintable(address(erc721Collection)).ownerMint(deployer );
        }

        vm.stopPrank();
    }

    function test_primeBalanceOf() external {

        vm.startPrank(deployer);

        uint256 tokenId1 = 10;
        uint256 tokenId2 = 11;
        uint256 tokenId3 = 12;
        uint256 tokenId4 = 13;


        erc721Collection.transferFrom(deployer, alice, tokenId1);
        erc721Collection.transferFrom(deployer, alice, tokenId2);
        erc721Collection.transferFrom(deployer, alice, tokenId3);
        erc721Collection.transferFrom(deployer, alice, tokenId4);


        uint256 primeBalance = isIdPrime.primeBalanceOf(alice);

        assertEq( primeBalance, 2 );

        vm.stopPrank();

    }

}


