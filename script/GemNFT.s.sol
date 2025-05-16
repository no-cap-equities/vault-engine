// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GemNFT} from "../src/GemNFT.sol";

contract GemNFTScript is Script {
    GemNFT public gemNFT;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        gemNFT = new GemNFT();

        vm.stopBroadcast();
    }
}
