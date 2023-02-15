// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IOracle {    
    function prices(uint256 i) external view returns (uint256);
}
