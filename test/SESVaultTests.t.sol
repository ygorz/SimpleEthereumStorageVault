// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {SimpleEthereumStorageVault} from "src/SimpleEthereumStorageVault.sol";
import {DeploySESVault} from "script/DeploySESVault.s.sol";

contract SESVaultTests is Test {
    SimpleEthereumStorageVault vault;
    DeploySESVault deployer;

    uint256 public constant USER_WALLET_BALANCE = 100 ether;
    uint256 public constant USER_ETH_DEPOSIT = 1 ether;
    uint256 public constant VAULT_BALANCE = 1 ether;
    address public user1 = makeAddr("user1");

    function setUp() external {
        deployer = new DeploySESVault();
        vault = deployer.run();

        vm.deal(user1, USER_WALLET_BALANCE);
    }

    // Modifiers
    modifier depositedEthereum() {
        vm.startPrank(user1);
        vault.storeEthereum{value: USER_ETH_DEPOSIT}();
        vm.stopPrank();
        _;
    }

    // Deposit Tests
    function testCanStoreEthereum() public depositedEthereum {
        assertEq(address(vault).balance, VAULT_BALANCE);
    }

    // Withdraw Tests
    function testCanWithdrawEthereum() public depositedEthereum {
        vm.startPrank(user1);
        vault.withdrawEthereum(USER_ETH_DEPOSIT);
        vm.stopPrank();
        assertEq(address(vault).balance, 0);
    }

    function testWithdrawZeroRverts() public depositedEthereum {
        vm.startPrank(user1);
        vm.expectRevert(SimpleEthereumStorageVault.SimpleEthereumStorageVault__MustBeMoreThanZero.selector);
        vault.withdrawEthereum(0);
        vm.stopPrank();
    }

    function testWithdrawMoreThanBalanceReverts() public depositedEthereum {
        vm.startPrank(user1);
        vm.expectRevert(SimpleEthereumStorageVault.SimpleEthereumStorageVault__WithdrawalMoreThanBalance.selector);
        vault.withdrawEthereum(USER_ETH_DEPOSIT * 2);
        vm.stopPrank();
    }

    // User Balance Tests
    function testStoringEthLogsIntoUserBalance() public depositedEthereum {
        assertEq(vault.getUserBalance(user1), USER_ETH_DEPOSIT);
    }

    function testWithdrawingEthRemovesFromUserBalance() public depositedEthereum {
        assertEq(vault.getUserBalance(user1), USER_ETH_DEPOSIT);
        vm.startPrank(user1);
        vault.withdrawEthereum(USER_ETH_DEPOSIT);
        vm.stopPrank();
        assertEq(vault.getUserBalance(user1), 0);
    }
}
