// scripts/deploy.js

const UNISWAP_V2_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
const { ethers, upgrades } = require('hardhat');

async function main() {
    const ERC20SwapperImpl = await ethers.getContractFactory('ERC20SwapperImpl');
    const instance = await upgrades.deployProxy(ERC20SwapperImpl, [UNISWAP_V2_ROUTER], { initializer: 'initialize' });
    console.log('ERC20SwapperImpl deployed to:', instance.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
