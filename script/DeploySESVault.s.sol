// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SimpleEthereumStorageVault} from "src/SimpleEthereumStorageVault.sol";

contract DeploySESVault is Script {
    function run() external returns (SimpleEthereumStorageVault) {
        vm.startBroadcast();
        SimpleEthereumStorageVault sesv = new SimpleEthereumStorageVault();
        vm.stopBroadcast();
        return sesv;
    }
}
