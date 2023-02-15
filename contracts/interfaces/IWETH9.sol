// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IWETH9 {
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}