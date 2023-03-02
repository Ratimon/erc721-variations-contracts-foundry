// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";

import {IMinter2StepRoles} from "@main/interfaces/IMinter2StepRoles.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Merkle} from "@murky/Merkle.sol";

import {ERC721Presale} from "@main/ERC721Presale.sol";
import {FixedPricePreSale} from "@main/FixedPricePreSale.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

import {DeploymentERC721Presale}  from "@test/utils/ERC721Presale.constructor.sol";
import {DeploymentFixedPricePreSale}  from "@test/utils/FixedPricePreSale.constructor.sol";

contract TestFixedPricePreSale is ConstantsFixture,DeploymentERC721Presale, DeploymentFixedPricePreSale {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

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

        arg_fixedPricePreSale.erc721Presale = erc721Presale;
        arg_fixedPricePreSale.price = 0.2e18;
        arg_fixedPricePreSale.startTime = staticTime + 1 days;
        arg_fixedPricePreSale.whitelistPrice = 0.15e18;
        arg_fixedPricePreSale.whitelistEndTime = 7 days;
        // yarn hardhat getRootHash
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
        IMinter2StepRoles(address(erc721Presale)).setMinter(address(fixedPricePreSale));

        vm.stopPrank();
    }

    function test_Constructor() public {

        (uint256 price, uint256 startTime, uint256 whitelistPrice, uint256 whitelistEndTime, bytes32 whitelistMerkleRoot, address saleRecipient ) = fixedPricePreSale.priceInfo();

        assertEq(price, arg_fixedPricePreSale.price);
        assertEq(startTime, arg_fixedPricePreSale.startTime);
        assertEq(whitelistPrice, arg_fixedPricePreSale.whitelistPrice);
        assertEq(whitelistEndTime, arg_fixedPricePreSale.whitelistEndTime);
        assertEq(whitelistMerkleRoot, arg_fixedPricePreSale.whitelistMerkleRoot);
        assertEq(saleRecipient, arg_fixedPricePreSale.saleRecipient);

    }


    function test_RevertWhen_INVALID_PROOF_test_mintWithPresale() public {

        vm.warp(staticTime + 2 days );

        deal(bob, 10 ether);

        vm.startPrank(bob);

        uint256 tokenId = 1;

        //yarn hardhat getProof --address 0x000000000000000000000000000000000000000b (alice)
        bytes32[] memory data = new bytes32[](2);
        data[0] = 0xde6e6fcaefc39f05e5912014093f38926987bb7b125e51b49ddfb49b03e36c50;
        data[1] = 0xa2bb3aed0a64660566f6ae0e3bc2f7b42de98a734d098f14f8d0c9e7abb308a0;

        vm.expectRevert(
            bytes("INVALID_PROOF")
        );
        fixedPricePreSale.mintWithPresale{value: 1e18}(
            tokenId,
            bob,
            data
        );

        vm.stopPrank();
    }

    function test_mintWithPresale() external {

        vm.warp(staticTime + 2 days );

        deal(alice, 10 ether);
        vm.startPrank(alice);

        uint256 tokenId = 1;
        uint256 alicePreEthBal = address(alice).balance;
        assertEq(fixedPricePreSale.isAllowanceUsed(tokenId), false);

        //yarn hardhat getProof --address 0x000000000000000000000000000000000000000b (alice)
        bytes32[] memory data = new bytes32[](2);
        data[0] = 0xde6e6fcaefc39f05e5912014093f38926987bb7b125e51b49ddfb49b03e36c50;
        data[1] = 0xa2bb3aed0a64660566f6ae0e3bc2f7b42de98a734d098f14f8d0c9e7abb308a0;

        vm.expectEmit(true, true, true, true, address(erc721Presale));
        emit Transfer(address(0), alice, tokenId);

        fixedPricePreSale.mintWithPresale{value: 1e18}(
            tokenId,
            alice,
            data
        );

         uint256 alicePostEthBal = address(alice).balance;

        uint256 changeInAliceBal = alicePostEthBal > alicePreEthBal ? (alicePostEthBal - alicePreEthBal) : (alicePreEthBal - alicePostEthBal);
        (,, uint256 whitelistPrice,, , ) = fixedPricePreSale.priceInfo();

        assertEq(changeInAliceBal, whitelistPrice );
        assertEq(fixedPricePreSale.isAllowanceUsed(tokenId), true);

        vm.stopPrank();

    }

}

