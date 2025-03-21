// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {SimpleEthereumStorageVault} from "src/SimpleEthereumStorageVault.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeploySESVault is Script {
    function run() external returns (SimpleEthereumStorageVault) {
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.getConfigByChainId(block.chainid).priceFeed;

        vm.startBroadcast();
        SimpleEthereumStorageVault sesv = new SimpleEthereumStorageVault(priceFeed);
        vm.stopBroadcast();

        return sesv;
    }
}
