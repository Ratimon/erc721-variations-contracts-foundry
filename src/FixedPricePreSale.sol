// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@forge-std/console2.sol";


import {ISale} from "@main/interfaces/ISale.sol";
import {ERC721Presale} from "@main/ERC721Presale.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";


contract FixedPricePreSale is ISale {

    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    ERC721Presale internal immutable _erc721Presale;
    uint256 internal immutable _price;
    uint256 internal immutable _startTime;
    uint256 internal immutable _whitelistPrice;
    uint256 internal immutable _whitelistEndTime;
    bytes32 internal immutable _whitelistMerkleRoot;
    address payable internal immutable _saleRecipient;


    BitMaps.BitMap private _isAllowanceUsed;

    constructor(
        ERC721Presale erc721Presale,
        uint256 price,
        uint256 startTime,
        uint256 whitelistPrice,
        uint256 whitelistEndTime,
        bytes32 whitelistMerkleRoot,
        address payable saleRecipient
    ) {
        _erc721Presale = erc721Presale;
        _price = price;
        _startTime = startTime;
        _whitelistPrice = whitelistPrice;
        _whitelistEndTime = whitelistEndTime;
        _whitelistMerkleRoot = whitelistMerkleRoot;
        _saleRecipient = saleRecipient;

    }

    function priceInfo()
        external
        view
        returns (
            uint256 price,
            uint256 startTime,
            uint256 whitelistPrice,
            uint256 whitelistEndTime,
            bytes32 whitelistMerkleRoot
        )
    {
        return (_price, _startTime, _whitelistPrice, _whitelistEndTime, _whitelistMerkleRoot);
    }

    function mint(uint256 tokenId, address to) public payable {
        require(block.timestamp >= _whitelistEndTime, "REQUIRE_ALLOWANCE_OR_WAIT");
        _payAndMint(tokenId, to);
    }

    function mintWithPresale(
        uint256 tokenId,
        address to,
        bytes32[] memory proof
    ) external payable {
        if (block.timestamp < _whitelistEndTime) {

            console2.log('1');

            useAllowanceIfAvailable(tokenId);

            console2.log('2');

            address signer = msg.sender;
            bytes32 leaf = _generateAllowanceHash(signer);

            console2.log('3');
            require(MerkleProof.verify(proof,_whitelistMerkleRoot,leaf), "INVALID_PROOF");

            console2.log('4');
        }
        _payAndMint(tokenId, to);
        console2.log('5');
    }

    function _generateAllowanceHash(address signer) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(signer));
    }

    function useAllowanceIfAvailable(uint256 tokenId) internal {
        require(!_isAllowanceUsed.get(tokenId), "ALLOWANCE_ALREADY_USED");
        _isAllowanceUsed.setTo(tokenId, true);
    }

    function _payAndMint(uint256 tokenId, address to) internal {
        require(block.timestamp >= _startTime, "SALE_NOT_STARTED");

        console2.log('41');

        uint256 expectedValue = block.timestamp >= _whitelistEndTime ? _price : _whitelistPrice;

        console2.log('42');

        require(msg.value >= expectedValue, "NOT_ENOUGH");
         console2.log('43');

        
        if (msg.value > expectedValue) {
            payable(msg.sender).transfer(msg.value - expectedValue);
        }

        if (expectedValue > 0) {
            _saleRecipient.transfer(expectedValue);
        }

        _erc721Presale.safeMint(tokenId, to);
    }

    
}

