// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

/**
 * @title SimpleEthereumStorageVault
 * @author George Gorzhiyev
 * @notice A simple Ethereum vault where users can deposit/withdraw Ethereum. Check balance of their account along with vault and check the USD value of their deposited Ethereum.
 */
contract SimpleEthereumStorageVault {
    /*========== Errors ==========*/
    error SimpleEthereumStorageVault__FailedToWithdrawEthereum();

    /*========== State Variables ==========*/
    address private immutable i_vaultOwner;

    constructor() {
        i_vaultOwner = msg.sender;
    }

    function storeEthereum() public payable {
        require(msg.value > 0, "Cannot store 0 Ethereum");
    }

    function withdrawEthereum(uint256 amount) public {
        bool (success, ) = msg.sender.call{value: }("");
        if (!success) {
            revert SimpleEthereumStorageVault__FailedToWithdrawEthereum;
        }
    }
}
