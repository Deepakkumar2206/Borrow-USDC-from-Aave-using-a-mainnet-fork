// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {AaveBorrow} from "../src/AaveBorrow.sol";
import {IAaveV2LendingPool} from "../src/interfaces/IAaveV2LendingPool.sol";

contract AaveBorrowTest is Test {
    // Aave v3 Pool (Ethereum)
    address constant POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;

    AaveBorrow aaveBorrow;

    function setUp() public {
        vm.createSelectFork("mainnet"); // uses MAINNET_RPC_URL from foundry.toml/.env
        aaveBorrow = new AaveBorrow();
    }

    function test_DepositWETH_ThenBorrowUSDC() public {
        uint256 collateralETH = 1 ether;

        // Give this test contract ETH so it can fund the call with value
        vm.deal(address(this), collateralETH);

        // 1) Wrap ETH -> WETH and approve pool (single call with value)
        aaveBorrow.wrapAndApprove{value: collateralETH}(collateralETH);

        // 2) Supply WETH as collateral
        aaveBorrow.supplyWETH(collateralETH);

        // 3) Borrow USDC (conservative amount for healthy HF)
        uint256 borrowAmount = 100e6; // 100 USDC
        aaveBorrow.borrowUSDC(borrowAmount);

        // 4) Assertions
        uint256 usdcBal = aaveBorrow.usdcBalance();
        assertGe(usdcBal, borrowAmount, "USDC not borrowed");

        // Optional: check health factor > 1
        IAaveV2LendingPool pool = IAaveV2LendingPool(POOL);
        (, , , , , uint256 hf) = pool.getUserAccountData(address(aaveBorrow));
        assertGt(hf, 1e18, "HF too low");
    }

    function test_Impersonation_Demo() public {
        address someEOA = 0x00000000219ab540356cBB839Cbe05303d7705Fa; // example
        vm.startPrank(someEOA);
        vm.stopPrank();
        assertTrue(true);
    }

    receive() external payable {}
}
