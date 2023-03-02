// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Errors} from "@main/shared/Error.sol";
import {Minter2StepRoles} from "@main/roles/Minter2StepRoles.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @notice ERC20 to be rewarded when staking NFT
 */
contract ERC20Game is ERC20, Minter2StepRoles {


        /**
     * @notice ERC20 Game constructor
     * @param _name token name for ERC20 Game
     * @param _symbol token symbol for ERC20 Game
     * @param initialOwner account for initial owner 
     * @param initialMinter account for initial minter eg. presale contract
    **/
    constructor(
        string memory _name,
        string memory _symbol,
        address  initialOwner,
        address  initialMinter
    ) ERC20(_name, _symbol) Minter2StepRoles(initialOwner,initialMinter) {
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
     * @notice mint new ERC1363 from the contract
     * @param to account to the ERC1363 to send
     * @param amount amount quantity of ERC1363 to send
     */
    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }


}