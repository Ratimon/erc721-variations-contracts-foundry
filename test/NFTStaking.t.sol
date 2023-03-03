// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";

import {ConstantsFixture}  from "@test/utils/ConstantsFixture.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";
import {IERC721Mintable} from "@main/interfaces/IERC721Mintable.sol";
import {IMinter2StepRoles} from "@main/interfaces/IMinter2StepRoles.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC20Game} from "@main/ERC20Game.sol";
import {ERC721Game} from "@main/ERC721Game.sol";
import {NFTStaking} from "@main/NFTStaking.sol";


contract TestFixedPricePreSale is ConstantsFixture {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event ClaimReward(address indexed receiver, uint256 indexed timestamp, uint256 rewardAmount);

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

        for (uint256 i = 0; i < 4; i++) {
             IERC721Mintable(address(erc721GameNFT)).ownerMint(deployer );
        }

        vm.stopPrank();

    }

    function test_Constructor() public {
        assertEq( address(nftStaking.gameToken()), address(erc20GameToken) );
        assertEq(  address(nftStaking.gameNFT()), address(erc721GameNFT) );
        assertEq( nftStaking.rewardPerDay(), 20e18 );

        assertEq(IMinter2StepRoles(address(erc20GameToken)).minter(), address(nftStaking)) ;
    }

    function test_RevertWhen_NotTokenOwner_stakeNFT() external {

        vm.startPrank(bob);

        uint256 tokenId = 1;

        dealERC721(address(erc721GameNFT), alice, tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotAuthorized.selector, bob)
        );

        nftStaking.stakeNFT(
            tokenId
        );

        vm.stopPrank();
    }
    // function test_RevertWhen_ALREADY_STAKED_test_stakeNFT() external {

    //     vm.startPrank(alice);

    //     uint256 tokenId = 1;

    //     dealERC721(address(erc721GameNFT), alice, tokenId);

    //     erc721GameNFT.approve(address(nftStaking), tokenId);
    //     nftStaking.stakeNFT(
    //         tokenId
    //     );

    //     vm.expectRevert(
    //         bytes("ALREADY_STAKED")
    //     );
    //     nftStaking.stakeNFT(
    //         tokenId
    //     );

    //     vm.stopPrank();
    // }

    function test_stakeNFT() external {
        vm.startPrank(alice);

        vm.warp(staticTime );

        uint256 tokenId = 1;
        uint256 currentTimestamp = block.timestamp;

        dealERC721(address(erc721GameNFT), alice, tokenId);

        erc721GameNFT.approve(address(nftStaking), tokenId);

        vm.expectEmit(true, true, true, true, address(erc721GameNFT));
        emit Transfer(alice, address(nftStaking), tokenId);

        nftStaking.stakeNFT(
            tokenId
        );

        ( address owner ,uint256 startTime ) = nftStaking.stakeInfo(tokenId);

        assertEq( owner, alice );
        assertEq( startTime, currentTimestamp );

        vm.stopPrank();
        
    }

    function test_RevertWhen_CALLER_NOT_STAKING_OWNER_unStakeNFT() external {

        vm.startPrank(alice);
        vm.warp(staticTime );

        uint256 tokenId = 1;
        uint256 stakingDayPeriod = 2 days;

        dealERC721(address(erc721GameNFT), alice, tokenId);

        erc721GameNFT.approve(address(nftStaking), tokenId);

        nftStaking.stakeNFT(
            tokenId
        );

        vm.warp(staticTime + stakingDayPeriod );
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert(
            bytes("CALLER_NOT_STAKING_OWNER")
        );
        nftStaking.unStakeNFT(
            tokenId
        );

        vm.stopPrank();
    }

    function test_unStakeNFT() external {
        vm.startPrank(alice);
        vm.warp(staticTime );

        uint256 tokenId = 1;
        uint256 stakingDayPeriod = 2 days;
       
        dealERC721(address(erc721GameNFT), alice, tokenId);

        erc721GameNFT.approve(address(nftStaking), tokenId);

        nftStaking.stakeNFT(
            tokenId
        );

        vm.warp(staticTime + stakingDayPeriod );

        vm.expectEmit(true, true, true, true, address(erc721GameNFT));
        emit Transfer(address(nftStaking), alice, tokenId);
        nftStaking.unStakeNFT(
            tokenId
        );
        ( address owner ,uint256 startTime ) = nftStaking.stakeInfo(tokenId);

         uint256 currentTimestamp = block.timestamp;

        assertEq( owner, address(0) );
        assertApproxEqRel(startTime, currentTimestamp, 2 );
        assertEq(  IERC20(address(erc20GameToken)).balanceOf(alice), (stakingDayPeriod*nftStaking.rewardPerDay())/1 days );

        vm.stopPrank();

    }


    function test_claimRewards() external {

        vm.startPrank(alice);
        vm.warp(staticTime );

        uint256 tokenId = 1;
        uint256 stakingDayPeriod = 2 days;

        dealERC721(address(erc721GameNFT), alice, tokenId);

        erc721GameNFT.approve(address(nftStaking), tokenId);

        nftStaking.stakeNFT(
            tokenId
        );

        vm.warp(staticTime + stakingDayPeriod );

        nftStaking.claimRewards(
            tokenId
        );

        ( address owner ,uint256 startTime ) = nftStaking.stakeInfo(tokenId);
        uint256 currentTimestamp = block.timestamp;

        assertEq( owner, alice );
        assertApproxEqRel(startTime, currentTimestamp, 2 );
        assertEq(  IERC20(address(erc20GameToken)).balanceOf(alice), (stakingDayPeriod*nftStaking.rewardPerDay())/1 days );

        vm.stopPrank();

    }




}
