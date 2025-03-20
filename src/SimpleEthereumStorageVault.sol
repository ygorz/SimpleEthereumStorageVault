// SPDX-License-Identifier: MIT

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

pragma solidity ^0.8.18;

/**
 * @title SimpleEthereumStorageVault
 * @author George Gorzhiyev
 * @notice A simple Ethereum vault where users can deposit/withdraw Ethereum. Check balance of their account along with vault and check the USD value of their deposited Ethereum.
 */
contract SimpleEthereumStorageVault {
    /*==================== ERRORS =============================*/
    error SimpleEthereumStorageVault__FailedToWithdrawEthereum();
    error SimpleEthereumStorageVault__MustBeMoreThanZero();
    error SimpleEthereumStorageVault__WithdrawalMoreThanBalance();
    error SimpleEthereumStorageVault__UserHasNoBalance();

    /*==================== STATE VARIABLES ====================*/
    address private immutable i_vaultOwner;
    mapping(address user => uint256 balance) private s_userBalances;
    AggregatorV3Interface private s_priceFeed;

    /*==================== EVENTS =============================*/
    event DepositedEthereum(address indexed user, uint256 amount);
    event WithdrawalEthereum(address indexed user, uint256 amount);

    /*==================== MODIFIERS ==========================*/
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert SimpleEthereumStorageVault__MustBeMoreThanZero();
        }
        _;
    }

    /*==================== FUNCTIONS ==========================*/
    /**
     * @notice Constructor to set the owner of the vault and the Chainlink price feed
     * @param priceFeed Chainlink price feed to get the USD value of Ethereum
     */
    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_vaultOwner = msg.sender;
    }

    /**
     * @notice A payable function to store Ethereum in the vault contract
     */
    function storeEthereum() public payable {
        require(msg.value > 0, "Cannot store 0 Ethereum");
        s_userBalances[msg.sender] += msg.value;

        emit DepositedEthereum(msg.sender, msg.value);
    }

    /**
     * @param amount Amount of Ethereum to withdraw
     *
     * Uses CEI - Checks Effects Interactions pattern
     */
    function withdrawEthereum(uint256 amount) public moreThanZero(amount) {
        uint256 userBalance = getUserBalance(msg.sender);

        if (userBalance == 0) {
            revert SimpleEthereumStorageVault__UserHasNoBalance();
        }

        if (amount > userBalance) {
            revert SimpleEthereumStorageVault__WithdrawalMoreThanBalance();
        }

        s_userBalances[msg.sender] -= amount;

        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) {
            revert SimpleEthereumStorageVault__FailedToWithdrawEthereum();
        }

        emit WithdrawalEthereum(msg.sender, amount);
    }

    /**
     * @param user User to check balance of
     * @return Balance of the user
     */
    function getUserBalance(address user) public view returns (uint256) {
        return s_userBalances[user];
    }

    /**
     * Check the users balance in the vault and return the Usd value of it, using Chainlink price feeds
     */
    function getUsdValueOfUserEthBalance() public view returns (uint256) {
        uint256 userBalance = getUserBalance(msg.sender);

        if (userBalance == 0) {
            revert SimpleEthereumStorageVault__UserHasNoBalance();
        }

        (, int256 price,,,) = s_priceFeed.latestRoundData();

        return ((uint256(price) * 1e10) * userBalance) / 1e18;
    }
}
