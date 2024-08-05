const { ethers, upgrades } = require('hardhat');
const EthUsdFeed = '0x694AA1769357215DE4FAC081bf1f309aDC325306';
const LinkUsdFeed = '0x42585eD362B3f1BCa95c640FdFf35Ef899212734';

async function main() {

    const proxyAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512'; // Replace with your deployed proxy contract address
    const ERC20SwapperImplV2 = await ethers.getContractFactory('ERC20SwapperImplV2');
    const upgraded = await upgrades.upgradeProxy(proxyAddress, ERC20SwapperImplV2);
    await upgraded.initialize(EthUsdFeed, LinkUsdFeed);
    console.log('ERC20SwapperImpl upgraded at:', instance.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
