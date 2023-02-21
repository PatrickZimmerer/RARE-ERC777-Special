const { network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    const name = "ERC777BondingCoin";
    const symbol = "ECC";
    const defaultOperators = new Array();

    const arguments = [name, symbol, defaultOperators];

    const erc777bondingCoin = await deploy("ERC777Bonding", {
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
        await verify(erc777bondingCoin.address, arguments);
    }
    log(
        "erc777bondingCoin deployed successfully at:",
        erc777bondingCoin.address
    );
    log("-----------------------------------------");
};

module.exports.tags = ["all", "erc777bondingCoin"];
