// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IERC721Mintable} from "@main/interfaces/IERC721Mintable.sol";
import {IMinter2StepRoles} from "@main/interfaces/IMinter2StepRoles.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC721Game} from "@main/ERC721Game.sol";


contract TestERC721Game is ConstantsFixture {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    ERC721Game erc721GameNFT;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestTestERC721Game");

        vm.startPrank(deployer);


        erc721GameNFT = new ERC721Game(
            'GameNFT', "NFT", msg.sender, msg.sender
        );
        vm.label(address(erc721GameNFT), "erc721GameNFT");


        // for (uint256 i = 0; i < 4; i++) {
        //      IERC721Mintable(address(erc721GameNFT)).ownerMint(deployer );
        // }

        vm.stopPrank();

    }

    function test_safeMint() external {
        vm.startPrank(deployer);
        IMinter2StepRoles(address(erc721GameNFT)).setMinter(alice);
        vm.stopPrank();

        vm.startPrank(alice);
        uint256 tokenId = 0;
        vm.expectEmit(true, true, true, true, address(erc721GameNFT));
        emit Transfer(address(0), alice, tokenId);
        IERC721Mintable(address(erc721GameNFT)).safeMint(alice );
        vm.stopPrank();
    }

    function test_ownerMint() external {
        vm.startPrank(deployer);
        uint256 tokenId = 0;
        vm.expectEmit(true, true, true, true, address(erc721GameNFT));
        emit Transfer(address(0), deployer, tokenId);
        IERC721Mintable(address(erc721GameNFT)).ownerMint(deployer );
        vm.stopPrank();
    }



}