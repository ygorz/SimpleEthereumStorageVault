// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {SimpleEthereumStorageVault} from "src/SimpleEthereumStorageVault.sol";
import {DeploySESVault} from "script/DeploySESVault.s.sol";
import {NonPayableContract} from "test/mocks/NonPayableContract.sol";

contract SESVaultTests is Test {
    SimpleEthereumStorageVault vault;
    DeploySESVault deployer;
    NonPayableContract dumby;

    uint256 public constant USER_WALLET_BALANCE = 100 ether;
    uint256 public constant USER_ETH_DEPOSIT = 1 ether;
    uint256 public constant VAULT_BALANCE = 1 ether;
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    event DepositedEthereum(address indexed user, uint256 amount);
    event WithdrawalEthereum(address indexed user, uint256 amount);

    function setUp() external {
        deployer = new DeploySESVault();
        vault = deployer.run();
        dumby = new NonPayableContract();

        vm.deal(user1, USER_WALLET_BALANCE);
        vm.deal(user2, USER_WALLET_BALANCE);
        vm.deal(address(dumby), USER_WALLET_BALANCE);
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

    function testWithdrawEthereumFails() public {
        uint256 expectedBalance = USER_ETH_DEPOSIT;
        vm.startPrank(address(dumby));
        vault.storeEthereum{value: USER_ETH_DEPOSIT}();
        uint256 actualBalance = vault.getUserBalance(address(dumby));
        assertEq(expectedBalance, actualBalance); // test that the deposit of dumby contract went through
        vm.expectRevert(SimpleEthereumStorageVault.SimpleEthereumStorageVault__FailedToWithdrawEthereum.selector);
        vault.withdrawEthereum(USER_ETH_DEPOSIT); // simulate withdrawal failure since dumby has no payable function
        vm.stopPrank();
    }

    function testWithdrawEthereumFailsRevertUndoesUserBalanceChange() public {
        vm.startPrank(address(dumby));
        vault.storeEthereum{value: USER_ETH_DEPOSIT}();
        uint256 beginningBalance = vault.getUserBalance(address(dumby));
        vm.expectRevert(SimpleEthereumStorageVault.SimpleEthereumStorageVault__FailedToWithdrawEthereum.selector);
        vault.withdrawEthereum(USER_ETH_DEPOSIT);
        uint256 endingBalance = vault.getUserBalance(address(dumby));
        assertEq(beginningBalance, endingBalance);
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

    function testUserWithNoBalanceShouldReturnZero() public depositedEthereum {
        vm.startPrank(user2);
        assertEq(vault.getUserBalance(user2), 0);
        vm.stopPrank();
    }

    // Emitter Tests
    function testDepositEthEmitsEvent() public {
        vm.startPrank(user1);
        vm.expectEmit(true, true, false, false, address(vault));
        emit DepositedEthereum(user1, USER_ETH_DEPOSIT);
        vault.storeEthereum{value: USER_ETH_DEPOSIT}();
        vm.stopPrank();
    }

    function testWithdrawEthEmitsEvent() public depositedEthereum {
        vm.startPrank(user1);
        vm.expectEmit(true, true, false, false, address(vault));
        emit WithdrawalEthereum(user1, USER_ETH_DEPOSIT);
        vault.withdrawEthereum(USER_ETH_DEPOSIT);
        vm.stopPrank();
    }
}
