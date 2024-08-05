const { expect } = require("chai");
const { ethers, upgrades } = require('hardhat');

const UNISWAP_V2_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'; // UniswapV2Router02 is deployed at 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D on the Ethereum mainnet, and the Ropsten, Rinkeby, Görli, and Kovan testnets.

let ERC20SwapperInstance;
let ERC20SwapperV2Instance;
let owner;
let notOwner;

describe("ERC20Swapper", () => {

  before("get signers", async () => {
    [owner, notOwner] = await ethers.getSigners();
  })

  it('should deploy ERC20Swapper', async () => {
    const ERC20Swapper = await ethers.getContractFactory("ERC20SwapperImpl");

    ERC20SwapperInstance = await upgrades.deployProxy(ERC20Swapper, [UNISWAP_V2_ROUTER], { initializer: 'initialize' });
    expect(ERC20SwapperInstance.target).to.properAddress;
  });

  it('should verify contract owner', async () => {
    const _owner = await ERC20SwapperInstance.owner();
    expect(_owner).eq(owner);
  });

  it('should verify uniswap router address', async () => {
    const uniswapRouter = await ERC20SwapperInstance.uniswapRouter();
    expect(uniswapRouter).eq(UNISWAP_V2_ROUTER);
  });

  it('should Upgrade ERC20SwapperImplV2', async () => {
    const ERC20SwapperImplV2 = await ethers.getContractFactory("ERC20SwapperImplV2");

    ERC20SwapperV2Instance = await upgrades.upgradeProxy(ERC20SwapperInstance.target, ERC20SwapperImplV2);
    expect(ERC20SwapperV2Instance.target).to.properAddress;
  })
  // TODO: unit test coverage...
});