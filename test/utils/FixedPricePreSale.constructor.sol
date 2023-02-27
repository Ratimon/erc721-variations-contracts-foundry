// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;


contract DeploymentFixedPricePreSale {

    struct Constructors_fixedPricePreSale {
        string _name;
        string _symbol;
        address initialRoyaltyReceiver;
        uint96 initialRoyaltyPer10Thousands;
        address initialOwner;
        address initialMinter;
    }

    Constructors_fixedPricePreSale arg_fixedPricePreSale;

}