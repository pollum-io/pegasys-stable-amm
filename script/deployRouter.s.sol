// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Router.sol";

contract MyScript is Script {
    function run() external {
        vm.startBroadcast();

        Router router = new Router();

        vm.stopBroadcast();
    }
}