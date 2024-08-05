// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

interface IERC20Swapper {
    function swapEtherToToken(address token, uint256 minAmount) external payable returns (uint256);
}

interface IUniswapV2Router02 {
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function WETH() external pure returns (address);
}

error InvalidEthUsdPriceFeed();
error InvalidTokenUsdPriceFeed();
error MustSendEther();
error MinAmountGreaterThanZero();
error InvalidEthUsdPrice();
error InvalidTokenUsdPrice();
error InvalidTokenAddress();
error InvalidRouterAddress();
error UnfairExchangeRate();
error InsufficientOutputAmount();
error DirectEtherTransfersNotAllowed();

contract ERC20SwapperImplV2 is
    Initializable,
    IERC20Swapper,
    PausableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    IUniswapV2Router02 public uniswapRouter;
    AggregatorV3Interface internal priceFeedEthUsd;
    AggregatorV3Interface internal priceFeedTokenUsd;

    event TokensSwapped(address indexed user, address token, uint256 amountIn, uint256 amountOut);

    // TODO: Relocate priceFeedTokenUsd within the swap function
    function initialize(address _ethUsdPriceFeed, address _tokenUsdPriceFeed) public reinitializer(2) {
        if (_ethUsdPriceFeed == address(0)) revert InvalidEthUsdPriceFeed();
        if (_tokenUsdPriceFeed == address(0)) revert InvalidTokenUsdPriceFeed();
        priceFeedEthUsd = AggregatorV3Interface(_ethUsdPriceFeed);
        priceFeedTokenUsd = AggregatorV3Interface(_tokenUsdPriceFeed);
    }

    function swapEtherToToken(address token, uint256 minAmount)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        if (msg.value == 0) revert MustSendEther();
        if (minAmount <= 0) revert MinAmountGreaterThanZero();
        if (token != address(0)) revert InvalidTokenAddress();

        // Get the latest price of ETH in USD
        (, int256 ethUsdPrice,,,) = priceFeedEthUsd.latestRoundData();
        if (ethUsdPrice <= 0) revert InvalidEthUsdPrice();

        // Get the latest price of the ERC-20 token in USD
        (, int256 tokenUsdPrice,,,) = priceFeedTokenUsd.latestRoundData();
        if (tokenUsdPrice <= 0) revert InvalidTokenUsdPrice();

        // Calculate the minimum expected amount of tokens based on the price feeds
        uint256 ethUsdPriceUint = uint256(ethUsdPrice);
        uint256 tokenUsdPriceUint = uint256(tokenUsdPrice);
        uint256 minExpectedTokens = (msg.value * ethUsdPriceUint) / tokenUsdPriceUint;

        // Ensure user gets at least the minimum expected tokens
        if (minExpectedTokens < minAmount) revert UnfairExchangeRate();

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = token;

        uint256 deadline = block.timestamp + 15; // 15 seconds from the current block timestamp

        uint256[] memory amounts =
            uniswapRouter.swapExactETHForTokens{value: msg.value}(minAmount, path, msg.sender, deadline);

        if (amounts[1] < minAmount) revert InsufficientOutputAmount();

        emit TokensSwapped(msg.sender, token, msg.value, amounts[1]);

        return amounts[1];
    }

    receive() external payable {
        revert DirectEtherTransfersNotAllowed();
    }

    function updateUniswapRouter(address _newRouter) external onlyOwner {
        if (_newRouter == address(0)) revert InvalidRouterAddress();
        uniswapRouter = IUniswapV2Router02(_newRouter);
    }

    // Admin functions to pause and unpause the contract
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
