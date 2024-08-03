// scripts/upgrade.js
async function main() {
    const { ethers, upgrades } = require('hardhat');

    const proxyAddress = '0xbC50f3D3314aC6e4073853B2FF84C1E621D9dd27'; // Replace with your deployed proxy contract address
    const ERC20SwapperImplV2 = await ethers.getContractFactory('ERC20SwapperImplV2');
    const instance = await upgrades.upgradeProxy(proxyAddress, ERC20SwapperImplV2);

    console.log('ERC20SwapperImpl upgraded at:', instance);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
