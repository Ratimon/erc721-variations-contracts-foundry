// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {ERC721Presale} from "@main/ERC721Presale.sol";
import {FixedPricePreSale} from "@main/FixedPricePreSale.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";
import {DeploymentFixedPricePreSale}  from "@test/utils/FixedPricePreSale.constructor.sol";


contract TestFixedPricePreSale is ConstantsFixture, DeploymentFixedPricePreSale {

    ERC721Presale erc721Presale;
    FixedPricePreSale fixedPricePreSale;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestFixedPricePreSale");

        vm.startPrank(deployer);

        arg_fixedPricePreSale._name =  "Test NFT Presale";
        arg_fixedPricePreSale._symbol = "Presale";
        arg_fixedPricePreSale.initialRoyaltyReceiver = msg.sender;
        arg_fixedPricePreSale.initialRoyaltyPer10Thousands = 250; // 250 per 10_000 = 2.5%
        arg_fixedPricePreSale.initialOwner = msg.sender;
        arg_fixedPricePreSale.initialMinter = msg.sender;


        erc721Presale = new ERC721Presale(
            arg_fixedPricePreSale._name,
            arg_fixedPricePreSale._symbol,
            arg_fixedPricePreSale.initialRoyaltyReceiver,
            arg_fixedPricePreSale.initialRoyaltyPer10Thousands,
            arg_fixedPricePreSale.initialOwner,
            arg_fixedPricePreSale.initialMinter

        );
        vm.label(address(erc721Presale), "erc721Presale");

        vm.stopPrank();

    }

}

