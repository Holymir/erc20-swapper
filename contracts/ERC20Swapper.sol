// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
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

error InvalidRouterAddress();
error MustSendEther();
error MinAmountGreaterThanZero();
error InvalidTokenAddress();
error InsufficientOutputAmount();
error DirectEtherTransfersNotAllowed();

contract ERC20SwapperImpl is IERC20Swapper, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    IUniswapV2Router02 public uniswapRouter;

    event TokensSwapped(address indexed user, address token, uint256 amountIn, uint256 amountOut);

    function initialize(address _uniswapRouterAddress) public initializer {
        if (_uniswapRouterAddress == address(0)) {
            revert InvalidRouterAddress();
        }
        __Pausable_init();
        __Ownable_init(msg.sender);
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
    }

    function swapEtherToToken(address token, uint256 minAmount)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        if (msg.value <= 0) revert MustSendEther();
        if (minAmount <= 0) revert MinAmountGreaterThanZero();
        if (token == address(0)) revert InvalidTokenAddress();

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

    // Admin functions to set the DEX router address
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
