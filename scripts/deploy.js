const { network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    const name = "ERC777Coin";
    const symbol = "ECC";

    const arguments = [name, symbol];

    const erc777Coin = await deploy("ERC777Bonding", {
        from: deployer,
        args: arguments,
        logs: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    // only verify the code when not on development chains as hardhat
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying...");
        await verify(erc777Coin.address, arguments);
    }
    log("erc777Coin deployed successfully at:", erc777Coin.address);
    log("-----------------------------------------");
};

module.exports.tags = ["all", "erc777Coin"];
