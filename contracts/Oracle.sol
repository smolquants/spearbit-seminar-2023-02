// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @dev DO NOT ACTUALLY DEPLOY
contract Oracle {
    uint256[2] public prices;
    
    function setPrice(uint256 i, uint256 _price) public {
        prices[i] = _price;
    }
}
