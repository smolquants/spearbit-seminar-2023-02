// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IOracle} from "./interfaces/IOracle.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";

/// @dev DO NOT ACTUALLY DEPLOY
contract Option {
    uint256 public constant MIN_PRICE0 = 100000000000000000000; // in wad for WETH
    uint256 public constant MIN_PRICE1 = 1500000000000000000000; // in wad for WBTC

    IWETH9 public immutable WETH9;
    address public immutable buyer;
    address public immutable seller;
    
    address public oracle;
    bool public initialized;
    bool public triggered;
    uint256 public expiry;
        
    constructor(address _WETH9, address _buyer, address _seller, address _oracle) {
        WETH9 = IWETH9(_WETH9);
        buyer = _buyer;
        seller = _seller;
        oracle = _oracle;
        expiry = block.timestamp + 4 weeks;
    }
    
    function initialize() external {
        require(!initialized, "initialized already");
        
        uint256 premiumAmount = WETH9.allowance(buyer, address(this));
        uint256 collateralAmount = WETH9.allowance(seller, address(this));
        require(premiumAmount < type(uint256).max, "allowance too large for buyer");
        require(collateralAmount < type(uint256).max, "allowance too large for seller");

        bool success = WETH9.transferFrom(buyer, address(this), premiumAmount);
        require(success, "transfer from buyer failed");
        
        success = WETH9.transferFrom(seller, address(this), collateralAmount);
        require(success, "transfer from seller failed");

        initialized = true;
    }
    
    function getPrice(uint256 i) public view returns (uint256) {
        return IOracle(oracle).prices(i);
    }
        
    function trigger() external {
        require(initialized, "not initialized");
        require(!triggered, "already triggered");
        require(block.timestamp < expiry, "option expired");

        uint256 price0 = getPrice(0);
        uint256 price1 = getPrice(1);
        require(price0 < MIN_PRICE0 && price1 < MIN_PRICE1, "prices not below strikes");

        triggered = true;
    }
    
    /// allows claim of funds from insurance fund
    function claim() external {
        require(initialized, "not initialized");
        require(block.timestamp >= expiry, "time not past expiry");
        require((triggered && msg.sender == buyer) || (!triggered && msg.sender == seller), "cannot claim");

        uint256 amount = WETH9.balanceOf(address(this));
        bool success = WETH9.transferFrom(address(this), msg.sender, amount);
        require(success, "failed to claim WETH");
    }
}
