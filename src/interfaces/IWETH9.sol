// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IWETH9 {
    function deposit() external payable;      // wrap ETH -> WETH
    function withdraw(uint256) external;      // unwrap
    function balanceOf(address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}
