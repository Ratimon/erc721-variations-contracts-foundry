// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

contract ConstantsFixture is Test, RegisterScripts {
    uint256 public constant WAD = 1e18;

    uint256 constant maxUint256 = type(uint256).max;
    mapping (string => mapping (string => address)) public addresses;

    address public deployer;
    address public alice = address(1);
    address public bob = address(2);
    address public carol = address(3);
    address public dave = address(4);

    function setUp() public virtual {

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        deal(alice, 1 ether);
        deal(bob, 1 ether);

    }

}