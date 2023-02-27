// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {ERC721Presale} from "@main/ERC721Presale.sol";

contract DeploymentFixedPricePreSale {

    struct Constructors_fixedPricePreSale {
        ERC721Presale erc721Presale;
        uint256 price;
        uint256 startTime;
        uint256 whitelistPrice;
        uint256 whitelistEndTime;
        bytes32 whitelistMerkleRoot;
        address saleRecipient;
    }

    Constructors_fixedPricePreSale arg_fixedPricePreSale;

}