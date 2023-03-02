// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IMinter2StepRoles} from "@main/interfaces/IMinter2StepRoles.sol";

import {ERC20Game} from "@main/ERC20Game.sol";
import {ERC721Game} from "@main/ERC721Game.sol";
import {NFTStaking} from "@main/NFTStaking.sol";


contract TestFixedPricePreSale is ConstantsFixture {

    ERC20Game erc20GameToken;
    ERC721Game erc721GameNFT;
    NFTStaking nftStaking;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestFixedPricePreSale");

        vm.startPrank(deployer);

        erc20GameToken = new ERC20Game(
            'GameToken', "REWARD", msg.sender, msg.sender
        );
        vm.label(address(erc20GameToken), "erc20GameToken");


        erc721GameNFT = new ERC721Game(
            'GameNFT', "NFT", msg.sender, msg.sender
        );
        vm.label(address(erc721GameNFT), "erc721GameNFT");

        nftStaking = new NFTStaking(
            IERC20Mintable(address(erc20GameToken)),
            IERC721(erc721GameNFT),
            20
        );
        vm.label(address(nftStaking), "nftStaking");

        IMinter2StepRoles(address(erc20GameToken)).setMinter(address(nftStaking));

        vm.stopPrank();

    }


}
