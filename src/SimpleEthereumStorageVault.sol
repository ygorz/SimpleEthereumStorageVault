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
    /*==================== Errors ====================*/
    error SimpleEthereumStorageVault__FailedToWithdrawEthereum();
    error SimpleEthereumStorageVault__MustBeMoreThanZero();
    error SimpleEthereumStorageVault__WithdrawalMoreThanBalance();

    /*==================== State Variables ====================*/
    address private immutable i_vaultOwner;
    mapping(address user => uint256 balance) private s_userBalances;

    /*==================== Modifiers ====================*/
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert SimpleEthereumStorageVault__MustBeMoreThanZero();
        }
        _;
    }

    /*==================== Functions ====================*/
    /**
     * @notice Constructor to set the owner of the vault
     */
    constructor() {
        i_vaultOwner = msg.sender;
    }

    /**
     * @notice A payable function to store Ethereum in the vault
     */
    function storeEthereum() public payable {
        require(msg.value > 0, "Cannot store 0 Ethereum");
        s_userBalances[msg.sender] += msg.value;
    }

    /**
     * @param amount Amount of Ethereum to withdraw
     */
    function withdrawEthereum(uint256 amount) public moreThanZero(amount) {
        uint256 userBalance = getUserBalance(msg.sender);
        if (amount > userBalance) {
            revert SimpleEthereumStorageVault__WithdrawalMoreThanBalance();
        }

        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) {
            revert SimpleEthereumStorageVault__FailedToWithdrawEthereum();
        }
        s_userBalances[msg.sender] -= amount;
    }

    /**
     * @param user User to check balance of
     * @return Balance of the user
     */
    function getUserBalance(address user) public view returns (uint256) {
        return s_userBalances[user];
    }
}
