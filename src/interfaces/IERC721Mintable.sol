// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Mintable is IERC721{

    // ----------- State changing Api -----------

    function safeMint(address to) external;

    function ownerMint(address to) external;
}