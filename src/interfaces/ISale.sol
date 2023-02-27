// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface ISale {

    // ----------- State changing Api -----------
    function mint(uint256 tokenId, address to) external payable;

}