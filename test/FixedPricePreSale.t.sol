// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

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

        arg_fixedPricePreSale.erc721Presale = erc721Presale;
        arg_fixedPricePreSale.price = 0.05e18;
        arg_fixedPricePreSale.startTime = staticTime + 1 days;
        arg_fixedPricePreSale.whitelistPrice = 0.1e18;
        arg_fixedPricePreSale.whitelistEndTime = 7 days;
        arg_fixedPricePreSale.whitelistMerkleRoot = bytes32("");
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

        vm.stopPrank();
    }

}
