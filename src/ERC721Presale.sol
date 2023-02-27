// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract NFTTest is IERC2981, ERC721  {

    event RoyaltySet(address receiver, uint256 royaltyPer10Thousands);

    struct Royalty {
        address receiver;
        uint96 per10Thousands;
    }

    Royalty internal _royalty;

    constructor(
        address initialRoyaltyReceiver,
        uint96 imitialRoyaltyPer10Thousands
    ) ERC721("NFTTest", "Test") {
        _royalty.receiver = initialRoyaltyReceiver;
        _royalty.per10Thousands = imitialRoyaltyPer10Thousands;
        emit RoyaltySet(initialRoyaltyReceiver, imitialRoyaltyPer10Thousands);
    }

    /**
     * @notice Called with the sale price to determine how much royalty is owed and to whom.
     * @param id - the token queried for royalty information.
     * @param salePrice - the sale price of the token specified by id.
     * @return receiver - address of who should be sent the royalty payment.
     * @return royaltyAmount - the royalty payment amount for salePrice.
    **/
    function royaltyInfo(uint256 id, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royalty.receiver;
        royaltyAmount = (salePrice * uint256(_royalty.per10Thousands)) / 10000;
    }



}



