// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "./interfaces/IERC20.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";
import {IAaveV2LendingPool} from "./interfaces/IAaveV2LendingPool.sol";

/// @title AaveBorrow (Aave v3) — deposit WETH and borrow USDC on a mainnet fork
contract AaveBorrow {
    // ===== Ethereum Mainnet (Aave v3) =====
    address public constant AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2; // v3 Pool
    address public constant WETH      = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC      = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IAaveV2LendingPool private constant pool = IAaveV2LendingPool(AAVE_POOL);
    IWETH9 private constant weth = IWETH9(WETH);
    IERC20 private constant usdc = IERC20(USDC);

    /// @notice Wrap ETH -> WETH and approve Aave pool
    function wrapAndApprove(uint256 amountETH) external payable {
        require(msg.value == amountETH, "Send exact ETH");
        weth.deposit{value: amountETH}();
        weth.approve(AAVE_POOL, amountETH);
    }

    /// @notice Supply WETH as collateral
    function supplyWETH(uint256 amount) external {
        pool.deposit(WETH, amount, address(this), 0);
    }

    /// @notice Borrow USDC (variable rate = 2)
    function borrowUSDC(uint256 usdcAmount6) external {
        pool.borrow(USDC, usdcAmount6, 2, 0, address(this));
    }

    function usdcBalance() external view returns (uint256) {
        return usdc.balanceOf(address(this));
    }

    receive() external payable {}
}
