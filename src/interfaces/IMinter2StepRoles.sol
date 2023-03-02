// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IMinter2StepRoles {

    // ----------- Events -----------

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event MinterSet(address indexed previousMinter, address indexed newMinter);

    // ----------- Governor only state changing api -----------

    function transferOwnership(address newOwner) external;
    function setMinter(address newMinter) external;

    // ----------- State changing Api -----------

    function acceptOwnership() external;

    // ----------- Getters -----------

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);

    function minter() external view returns (address);
}