const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const UNISWAP_V2_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';



module.exports = buildModule("deployModule", (d) => {

  // const ERC20SwapperImpl = await ethers.getContractFactory('ERC20SwapperImpl');
  // const instance = await upgrades.deployProxy(ERC20SwapperImpl, [UNISWAP_V2_ROUTER], { initializer: 'initialize' });
  // await instance.deployed();

  // console.log('ERC20SwapperImpl deployed to:', instance);

  const contract = d.contract("ERC20SwapperImpl", [UNISWAP_V2_ROUTER], { initializer: 'initialize' });

  return { contract };
});
