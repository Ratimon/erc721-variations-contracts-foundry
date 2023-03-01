// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";

import {IPresaleRoles} from "@main/interfaces/IPresaleRoles.sol";

import {ERC721Presale} from "@main/ERC721Presale.sol";
import {FixedPricePreSale} from "@main/FixedPricePreSale.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

import {DeploymentERC721Presale}  from "@test/utils/ERC721Presale.constructor.sol";
import {DeploymentFixedPricePreSale}  from "@test/utils/FixedPricePreSale.constructor.sol";

contract TestFixedPricePreSale is ConstantsFixture,DeploymentERC721Presale, DeploymentFixedPricePreSale {

    ERC721Presale erc721Presale;
    FixedPricePreSale fixedPricePreSale;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestFixedPricePreSale");

        vm.startPrank(deployer);

        arg_erc721Presale._name =  "Test NFT Presale";
        arg_erc721Presale._symbol = "Presale";
        arg_erc721Presale.initialRoyaltyReceiver = msg.sender;
        arg_erc721Presale.initialRoyaltyPer10Thousands = 250; // 250 per 10_000 = 2.5%
        arg_erc721Presale.initialOwner = msg.sender;
        arg_erc721Presale.initialMinter = msg.sender;


        erc721Presale = new ERC721Presale(
            arg_erc721Presale._name,
            arg_erc721Presale._symbol,
            arg_erc721Presale.initialRoyaltyReceiver,
            arg_erc721Presale.initialRoyaltyPer10Thousands,
            arg_erc721Presale.initialOwner,
            arg_erc721Presale.initialMinter

        );
        vm.label(address(erc721Presale), "erc721Presale");

        string[] memory inputs = new string[](4);
        inputs[0] = "yarn";
        inputs[1] = "hardhat";
        inputs[2] = "run";
        inputs[3] = "utils/merkletree/getRootHashFFI.ts";

        bytes memory res = vm.ffi(inputs);
        bytes32 merkleroot = abi.decode(res, (bytes32));
        // console2.log( 'merkleroot');
        // console2.logBytes32(merkleroot);

        arg_fixedPricePreSale.erc721Presale = erc721Presale;
        arg_fixedPricePreSale.price = 0.05e18;
        arg_fixedPricePreSale.startTime = staticTime + 1 days;
        arg_fixedPricePreSale.whitelistPrice = 0.1e18;
        arg_fixedPricePreSale.whitelistEndTime = 7 days;
        arg_fixedPricePreSale.whitelistMerkleRoot = merkleroot;
        arg_fixedPricePreSale.saleRecipient = msg.sender;

        fixedPricePreSale = new FixedPricePreSale(
            arg_fixedPricePreSale.erc721Presale,
            arg_fixedPricePreSale.price,
            arg_fixedPricePreSale.startTime,
            arg_fixedPricePreSale.whitelistPrice,
            arg_fixedPricePreSale.whitelistEndTime,
            arg_fixedPricePreSale.whitelistMerkleRoot,
            payable(arg_fixedPricePreSale.saleRecipient)
        );
        vm.label(address(erc721Presale), "fixedPricePreSale");
        // vm.warp(staticTime + 1 days );
        IPresaleRoles(address(erc721Presale)).setMinter(address(fixedPricePreSale));

        vm.stopPrank();
        // console2.log( 'alice', alice);
        // console2.log( 'bob', bob);
        // console2.log( 'carol', carol);
        // console2.log( 'dave', dave);
    }

    function test_mintWithPresale() external {

        vm.warp(staticTime + 2 days );

        deal(alice, 10 ether);
        vm.startPrank(alice);

        string[] memory inputs = new string[](4);
        inputs[0] = "yarn";
        inputs[1] = "hardhat";
        inputs[2] = "run";
        inputs[3] = "utils/merkletree/getProofFFI.ts";

        bytes memory res = vm.ffi(inputs);
        bytes32[2] memory proof = abi.decode(res, (bytes32[2]));

        console2.log( 'proof1');
        console2.logBytes32(proof[0]);
        console2.log( 'proof2');
        console2.logBytes32(proof[1]);

        // erc721Presale.mintWithPresale(0);

        

    }

}

