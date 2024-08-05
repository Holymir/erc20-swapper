# Overview

The proxy for the implementation is currently deployed at the address: `0xB88599047de09c0078017baA5BD0B412900E789c`.

While the contract is comprehensive and meets most of the task requirements, there is potential for simplification and optimization to make it more gas-efficient.

# ERC20 Swapper Implementation

This project implements a Solidity smart contract for swapping Ether to ERC20 tokens using the UniswapV2Router02. It utilizes OpenZeppelin's upgradeable proxy pattern for easy upgrades and incorporates best practices for security and gas efficiency.

## Features

-   **Token Swaps**: Allows users to swap Ether for specified ERC20 tokens using Uniswap V2.
-   **Ownership and Pausability**: Includes ownership control and the ability to pause contract operations.
-   **Upgradeable**: Leverages OpenZeppelin's upgradeable proxy pattern for future improvements without deploying a new contract.

## Prerequisites

Ensure you have the following installed:

-   [Node.js](https://nodejs.org/en/)
-   [Hardhat](https://hardhat.org/)
-   [OpenZeppelin Upgrades Plugin](https://docs.openzeppelin.com/upgrades-plugins)

## Installation

1. Clone the repository:

    ```sh
    git clone https://github.com/holymir/erc20-swapper.git
    cd erc20-swapper
    ```

2. Install dependencies:

    ```sh
    npm install
    ```

3. Compile the contracts:

    ```sh
    npx hardhat compile
    ```

## Deployment

To deploy the proxy and initialize the contract:

1. Deploy the initial implementation and proxy:

    ```javascript
    const {ethers, upgrades} = require("hardhat");

    async function main() {
        const ERC20Swapper = await ethers.getContractFactory("ERC20SwapperImpl");
        const instance = await upgrades.deployProxy(ERC20Swapper, ["0xUniswapRouterAddress"], {initializer: "initialize"});
        await instance.deployed();
        console.log("ERC20Swapper deployed to:", instance.target);
    }

    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
    ```

    Replace `0xUniswapRouterAddress` with the actual Uniswap V2 router address.

    ```sh
    $ npx hardhat vars set MAIN_KEY
    $ npx hardhat vars set ETHERSCAN_API_KEY
    $ npx hardhat vars set INFURA_API_KEY
    $ npx hardhat run ./scripts/deploy.js --network sepolia
    ```

## Upgrading

To upgrade the contract to a new implementation:

1.  Upgrade the proxy to the new implementation and call initializer if necessary:

        ```javascript
        async function main() {
            const proxyAddress = "0xYourProxyAddress";
            const NewImplementation = await ethers.getContractFactory("ERC20SwapperImplV2");

            // Upgrade the contract at the proxy address to the new implementation
            const upgraded = await upgrades.upgradeProxy(proxyAddress, NewImplementation);
            console.log("Proxy upgraded to:", upgraded.target);

            // Initialize the new implementation if necessary
            await upgraded.initialize("[0xNewValueOrParameters]...");
        }

        main()
            .then(() => process.exit(0))
            .catch((error) => {
                console.error(error);
                process.exit(1);
            });
        ```

    ```sh
    $ npx hardhat run ./scripts/upgrade.js --network sepolia
    ```

## Usage

### Contract Functions

-   **swapEtherToToken**: Swaps Ether for the specified ERC20 token.

    ```solidity
    function swapEtherToToken(address token, uint256 minAmount) external payable returns (uint256);
    ```

-   **pause**: Pauses the contract.

    ```solidity
    function pause() external onlyOwner;
    ```

-   **unpause**: Unpauses the contract.

    ```solidity
    function unpause() external onlyOwner;
    ```

-   **updateUniswapRouter**: Updates the Uniswap router address.

    ```solidity
    function updateUniswapRouter(address newRouter) external onlyOwner;
    ```

### Events

-   **TokensSwapped**: Emitted when tokens are swapped.

    ```solidity
    event TokensSwapped(address indexed user, address indexed token, uint256 amountIn, uint256 amountOut);
    ```

## Security Considerations

-   **Reentrancy Guard**: The contract includes the `nonReentrant` modifier to prevent reentrancy attacks.
-   **Input Validation**: Input parameters are validated to avoid erroneous transactions.
-   **Custom Errors**: Custom errors are used for gas-efficient error handling.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

```

```
