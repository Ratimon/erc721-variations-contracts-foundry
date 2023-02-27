// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IPresaleRoles} from "@main/interfaces/IPresaleRoles.sol";
import {Errors} from "@main/shared/Error.sol";

/**
 * @notice Customised 2-step Ownable Contract, preventing setting wrong admin address
 * @dev more details is at https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable2Step
**/
contract PresaleRoles is IPresaleRoles{

    /**
     * @notice the address of the current owner, that is able to set new Sanction admin and minter
    **/  
    address internal _owner;
    address internal _pendingOwner;

    /**
     * @notice the address which is able to mint tokens eg. bonding curve contracr
    **/
    address internal _minter;

    /**
     * @notice SanctionRoles constructor
     * @param initialOwner initial owner
     * @param initialMinter initial minter
    **/
    constructor(
        address initialOwner,
        address initialMinter
    ) {
        if (initialOwner == address(0)) revert Errors.ZeroAddressNotAllowed();
        if (initialMinter == address(0)) revert Errors.ZeroAddressNotAllowed();

        _owner = initialOwner;
        _minter = initialMinter;
        emit OwnershipTransferred(address(0), initialOwner);
        emit MinterSet(address(0), initialMinter);
    }

    /**
     * @notice Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
    **/
    function transferOwnership(address newOwner) external {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(_owner, newOwner);
    }

    /**
     * @notice The new owner accepts the ownership transfer.
     * Can only be called current owner.
    **/
    function acceptOwnership() external {
        if (_pendingOwner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete _pendingOwner;
        address oldOwner = _owner;
        _owner = msg.sender;
        emit OwnershipTransferred(oldOwner, _owner);
    }


    /**
     * @notice set the new minter
     * Can only be called by either owner or the current minter.
    **/
    function setMinter(address newMinter) external {
        if ( (_minter != msg.sender) && (_owner != msg.sender) ) revert Errors.NotAuthorized(msg.sender);

        address oldMinter = _minter;
        _minter = newMinter;
        emit MinterSet(oldMinter, newMinter);
    }

    /**
     * @notice Get the owner of the contract.
    **/
    function owner() external view override returns (address) {
        return _owner;
    }

    /**
     * @notice Get the pending owner of the contract.
    **/
    function pendingOwner() external view override returns (address){
        return _pendingOwner;
    }
    
    /**
     * @notice Get the minter of the contract.
    **/
    function minter() external view override returns (address){
        return _minter;
    }

}