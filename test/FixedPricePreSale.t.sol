// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

// import {Test} from "@forge-std/Test.sol";
// import {StdUtils} from "@forge-std/StdUtils.sol";

import {ERC721Presale} from "@main/ERC721Presale.sol";
import {FixedPricePreSale} from "@main/FixedPricePreSale.sol";


import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";



contract TestFixedPricePreSale is ConstantsFixture {


    ERC721Presale erc721Presale;
    FixedPricePreSale fixedPricePreSale;


    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestFixedPricePreSale");

        vm.startPrank(deployer);

        // erc721Presale = new ERC721Presale();
        vm.label(address(erc721Presale), "erc721Presale");

        vm.stopPrank();

    }

}

