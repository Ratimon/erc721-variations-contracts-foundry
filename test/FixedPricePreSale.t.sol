// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";

import {IPresaleRoles} from "@main/interfaces/IPresaleRoles.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Merkle} from "@murky/Merkle.sol";

import {ERC721Presale} from "@main/ERC721Presale.sol";
import {FixedPricePreSale} from "@main/FixedPricePreSale.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

import {DeploymentERC721Presale}  from "@test/utils/ERC721Presale.constructor.sol";
import {DeploymentFixedPricePreSale}  from "@test/utils/FixedPricePreSale.constructor.sol";

contract TestFixedPricePreSale is ConstantsFixture,DeploymentERC721Presale, DeploymentFixedPricePreSale {

    Merkle merkle;

    ERC721Presale erc721Presale;
    FixedPricePreSale fixedPricePreSale;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestFixedPricePreSale");

        vm.startPrank(deployer);

        merkle = new Merkle();

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

        // string[] memory inputs = new string[](4);
        // inputs[0] = "yarn";
        // inputs[1] = "hardhat";
        // inputs[2] = "run";
        // inputs[3] = "utils/merkletree/getRootHashFFI.ts";

        // bytes memory res = vm.ffi(inputs);
        // console2.logBytes( res);
        // bytes32 merkleRootHash = abi.decode(res, (bytes32));
        // console2.log( 'merkleroot1');
        // console2.logBytes32(merkleRootHash);

        arg_fixedPricePreSale.erc721Presale = erc721Presale;
        arg_fixedPricePreSale.price = 0.05e18;
        arg_fixedPricePreSale.startTime = staticTime + 1 days;
        arg_fixedPricePreSale.whitelistPrice = 0.1e18;
        arg_fixedPricePreSale.whitelistEndTime = 7 days;
        arg_fixedPricePreSale.whitelistMerkleRoot = 0x437ca09d93ac1db27ca6c483cb04275d6b3e34794514d270f3d7b32f4bc0c8fc;
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

        bytes32[] memory data = new bytes32[](2);
        data[0] = 0xde6e6fcaefc39f05e5912014093f38926987bb7b125e51b49ddfb49b03e36c50;
        data[1] = 0xa2bb3aed0a64660566f6ae0e3bc2f7b42de98a734d098f14f8d0c9e7abb308a0;

        fixedPricePreSale.mintWithPresale{value: 1e18}(
            1,
            alice,
            data
        );

        // bytes32[] memory data = new bytes32[](4);
        // data[0] = keccak256(abi.encodePacked(alice));
        // data[1] = keccak256(abi.encodePacked(bob));
        // data[2] = keccak256(abi.encodePacked(carol));
        // data[3] = keccak256(abi.encodePacked(dave));

        // console2.log("alice");
        // console2.logBytes32(data[0] );

        // bytes32 root = merkle.getRoot(data);


        // console2.log("root2");
        // console2.logBytes32( root ) ;

        // string[] memory inputs = new string[](4);
        // inputs[0] = "yarn";
        // inputs[1] = "hardhat";
        // inputs[2] = "run";
        // inputs[3] = "utils/merkletree/getProofFFI.ts";

        // yarn hardhat getProofFFI alice
        // Strings.toHexString(uint160(address), 20)

        // inputs[0] = "yarn";
        // inputs[1] = "hardhat";
        // inputs[2] = "getProofFFI";
        // inputs[3] = Strings.toHexString(uint160(alice), 20);

        // 'bytes32[2] proof'

        // bytes32[2] proof


        // bytes memory res = vm.ffi(inputs);
        // console2.logBytes( res);
        // bytes32[2] memory proof = abi.decode(res, (bytes32[2]));

        // console2.log( 'proof1');
        // console2.logBytes32(proof[0]);
        // console2.log( 'proof2');
        // console2.logBytes32(proof[1]);


        

        

    }

}

