// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GEMToken} from "../src/GemToken.sol";

contract GemTokenScript is Script {
    GEMToken public gemToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        gemToken = new GEMToken();

        vm.stopBroadcast();
    }
}
