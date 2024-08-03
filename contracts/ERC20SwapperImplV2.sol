// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface ERC20Swapper {
    function swapEtherToToken(address token, uint256 minAmount) external payable returns (uint256);
}

interface IUniswapV2Router02 {
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function WETH() external pure returns (address);
}

contract ERC20SwapperImplV2 is Initializable, ERC20Swapper, PausableUpgradeable, OwnableUpgradeable {
    address private uniswapRouterAddress;

    IUniswapV2Router02 public uniswapRouter;

    event TokensSwapped(address indexed user, address token, uint256 amountIn, uint256 amountOut);

    function initialize(address _uniswapRouterAddress) public initializer {
        __Pausable_init();
        __Ownable_init(msg.sender);
        uniswapRouterAddress = _uniswapRouterAddress;
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
    }

    function callMeBaby() public pure returns (uint256) {
        return 2;
    }

    function callMeBaby2() public pure returns (string memory) {
        return "YAMKS";
    }

    function swapEtherToToken(address token, uint256 minAmount)
        external
        payable
        override
        whenNotPaused
        returns (uint256)
    {
        require(msg.value > 0, "Must send Ether");
        require(minAmount > 0, "minAmount must be greater than 0");

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = token;

        uint256 deadline = block.timestamp + 15; // 15 seconds from the current block timestamp

        uint256[] memory amounts =
            uniswapRouter.swapExactETHForTokens{value: msg.value}(minAmount, path, msg.sender, deadline);

        require(amounts[1] >= minAmount, "Insufficient output amount");

        emit TokensSwapped(msg.sender, token, msg.value, amounts[1]);

        return amounts[1];
    }

    receive() external payable {
        revert("Do not send Ether directly");
    }

    function updateUniswapRouter(address _newRouter) external onlyOwner {
        uniswapRouterAddress = _newRouter;
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
    }

    // Admin functions to pause and unpause the contract
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
