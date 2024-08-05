// scripts/deploy.js

const UNISWAP_V2_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
const { ethers, upgrades } = require('hardhat');



const EthUsdFeed = '0x694AA1769357215DE4FAC081bf1f309aDC325306';
const LinkUsdFeed = '0x42585eD362B3f1BCa95c640FdFf35Ef899212734';



async function main() {
    const ERC20SwapperImpl = await ethers.getContractFactory('ERC20SwapperImpl');
    const instance = await upgrades.deployProxy(ERC20SwapperImpl, [UNISWAP_V2_ROUTER], { initializer: 'initialize' });
    console.log('ERC20SwapperImpl deployed to:', instance.target);


    const ERC20SwapperImplV2 = await ethers.getContractFactory('ERC20SwapperImplV2');
    const upgraded = await upgrades.upgradeProxy(instance, ERC20SwapperImplV2);
    await upgraded.initialize(EthUsdFeed, LinkUsdFeed);
    console.log('ERC20SwapperImplV2 upgraded at:', upgraded.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
