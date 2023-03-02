// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Errors} from "@main/shared/Error.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Minter2StepRoles} from "@main/roles/Minter2StepRoles.sol";

contract MyToken is ERC721, Minter2StepRoles {

    using Counters for Counters.Counter;

    uint256 public constant MAX_SUPPLY = 20;

    Counters.Counter private _tokenIdCounter;

    /**
     * @notice NFT constructor
     * @param _name token name for ERC721
     * @param _symbol token symbol for ERC721
     * @param initialOwner account for initial owner 
     * @param initialMinter account for initial minter eg. presale contract
    **/
    constructor(
        string memory _name,
        string memory _symbol,
        address  initialOwner,
        address  initialMinter
    ) ERC721(_name, _symbol) Minter2StepRoles(initialOwner,initialMinter) {
    }


    modifier onlyOwner() {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }


    modifier onlyMinter() {
        if (_minter != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    function safeMint(address to) public onlyMinter {
        
        if (to == address(this)) revert Errors.NotThis();
        uint256 tokenId = _tokenIdCounter.current();
        require (tokenId<MAX_SUPPLY, "EXCEEDS_MAX_SUPPLY");

        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}