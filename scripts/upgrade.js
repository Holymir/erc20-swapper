const { ethers, upgrades } = require('hardhat');
const EthUsdFeed = '0x694AA1769357215DE4FAC081bf1f309aDC325306';
const LinkUsdFeed = '0x42585eD362B3f1BCa95c640FdFf35Ef899212734';

async function main() {

    const proxyAddress = '0xB88599047de09c0078017baA5BD0B412900E789c'; // Replace with your deployed proxy contract address
    const ERC20SwapperImplV2 = await ethers.getContractFactory('ERC20SwapperImplV2');
    const upgraded = await upgrades.upgradeProxy(proxyAddress, ERC20SwapperImplV2);
    await upgraded.initialize(EthUsdFeed, LinkUsdFeed);
    console.log('ERC20SwapperImpl upgraded at:', upgraded.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
