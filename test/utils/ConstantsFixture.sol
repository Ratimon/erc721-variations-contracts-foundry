// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

contract ConstantsFixture is Test, RegisterScripts {
    uint256 public constant WAD = 1e18;

    uint256 constant maxUint256 = type(uint256).max;
    mapping (string => mapping (string => address)) public addresses;

uint256 public staticTime;

    address public deployer;
    address public alice = address(11);
    address public bob = address(12);
    address public carol = address(13);
    address public dave = address(14);


    function setUp() public virtual {

        staticTime = block.timestamp;


        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(carol, "carol");
        vm.label(dave, "dave");

        deal(alice, 1 ether);
        deal(bob, 1 ether);


    }

}