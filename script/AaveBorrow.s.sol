// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {AaveBorrow} from "../src/AaveBorrow.sol";

contract AaveBorrowScript is Script {
    function run() external {
        vm.startBroadcast();

        AaveBorrow a = new AaveBorrow();

        // Single call with value: wrap + approve
        a.wrapAndApprove{value: 1 ether}(1 ether);
        a.supplyWETH(1 ether);
        a.borrowUSDC(100e6);

        vm.stopBroadcast();
    }
}
