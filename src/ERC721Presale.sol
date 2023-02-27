// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {PresaleRoles} from "@main/roles/PresaleRoles.sol";

contract ERC721Presale is IERC2981, ERC721, PresaleRoles {

    event RoyaltySet(address receiver, uint256 royaltyPer10Thousands);

    struct Royalty {
        address receiver;
        uint96 per10Thousands;
    }

    Royalty internal _royalty;

    /**
     * @notice NFT constructor
     * @param _name token name for ERC721
     * @param _symbol token symbol for ERC721
     * @param initialOwner account for initial owner 
     * @param initialMinter account for initial minter eg. presale contract
     * @param initialRoyaltyReceiver account for initial owner 
     * @param initialRoyaltyPer10Thousands account for initial minter eg. presale contract
    **/
    constructor(
        string memory _name,
        string memory _symbol,
        address initialRoyaltyReceiver,
        uint96 initialRoyaltyPer10Thousands,
        address  initialOwner,
        address  initialMinter
    ) ERC721(_name, _symbol) PresaleRoles(initialOwner,initialMinter) {
        _royalty.receiver = initialRoyaltyReceiver;
        _royalty.per10Thousands = initialRoyaltyPer10Thousands;
        emit RoyaltySet(initialRoyaltyReceiver, initialRoyaltyPer10Thousands);
    }

    modifier onlyOwner() {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }


    modifier onlyMinter() {
        if (_minter != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    /**
     * @notice mint one of NFT if not already minted. Can only be called by `minter`.
     * @param tokenId token id which represent NFT
     * @param to address that will receive the Bleep.
    **/
    function safeMint( uint256 tokenId, address to) external onlyMinter {
        if (to == address(this)) revert Errors.NotThis();

        _safeMint(to, tokenId);
    }

    /**
     * @notice set a new royalty receiver and rate, Can only be set by the `owner`.
     *  @param newReceiver the address that should receive the royalty proceeds.
     * @param royaltyPer10Thousands the share of the salePrice (in 1/10000) given to the receiver.
     **/
    function setRoyaltyParameters(address newReceiver, uint96 royaltyPer10Thousands) external onlyOwner {
        _royalty.receiver = newReceiver;
        _royalty.per10Thousands = royaltyPer10Thousands;
        emit RoyaltySet(newReceiver, royaltyPer10Thousands);
    }

    /**
     * @notice Check if the contract supports an interface.
     * @param id The id of the interface.
     * @return Whether the interface is supported.
    **/
    function supportsInterface(bytes4 id)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return super.supportsInterface(id) || id == 0x2a55205a; /// 0x2a55205a is ERC2981 (royalty standard)
    }

    function _baseURI() internal pure override(ERC721) returns (string memory) {
        return "ipfs";
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



