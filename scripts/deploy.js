async function main() {
    const DynoAvatars = await ethers.getContractFactory("DynoAvatars");
    const DYNO = await ethers.getContractFactory("DYNO");
    const USDC = await ethers.getContractFactory("USDC");
    const stDYNO = await ethers.getContractFactory("stDYNO");
    const DynoStaking = await ethers.getContractFactory("DynoStaking");
    const DynoAuction = await ethers.getContractFactory("DynoAuction");
    const supply = await ethers.utils.parseEther("100000000");
    const amount = await ethers.utils.parseEther("1000000");
    const price = await ethers.utils.parseEther("100");

    // Deployment of the DynoAvatars contract
    const dynoAvatars = await DynoAvatars.deploy("DynoAvatars", "Dyno-A", "https://gateway.pinata.cloud/ipfs/QmRPZMZu4PUmDwecESCwo27dciAqgZFLve7qfu5tnu4R9w/");
    await dynoAvatars.deployed();
    console.log("Contract deployed to address:", dynoAvatars.address);

    // Deployment of the DYNO Token
    const dyno = await DYNO.deploy("DYNO", "DYO", supply);
    await dyno.deployed();
    console.log("Contract deployed to address:", dyno.address);
  
    // Deployment of the USDC Token
    const usdc = await USDC.deploy("US-Dollar", "USDC", supply);
    await usdc.deployed();
    console.log("Contract deployed to address:", usdc.address);

    // Deployment of the stDYNO Token
    const stDyno = await stDYNO.deploy("Staked-DYNO", "stDYNO", supply);
    await stDyno.deployed();
    console.log("Contract deployed to address:", stDyno.address);

    // Deployment of the Auction Smart Contarct
    const dynoAuction = await DynoAuction.deploy(dyno.address, dynoAvatars.address);
    await dynoAuction.deployed();
    console.log("Contract deployed to address:", dynoAuction.address);

    // Deployment of the Staking Smart Contarct
    const dynoStaking = await DynoStaking.deploy(stDyno.address, dynoAvatars.address);
    await dynoStaking.deployed();
    console.log("Contract deployed to address:", dynoStaking.address);
  };
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    });