// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

contract DeploymentERC721Presale {

    struct Constructors_erc721Presale {
        string _name;
        string _symbol;
        address initialRoyaltyReceiver;
        uint96 initialRoyaltyPer10Thousands;
        address initialOwner;
        address initialMinter;
    }

    Constructors_erc721Presale arg_erc721Presale;

}