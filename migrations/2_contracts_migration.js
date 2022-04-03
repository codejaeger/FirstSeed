const erc20Token = artifacts.require("./erc20Token.sol");
const SeedChain = artifacts.require("./SeedChain.sol");

module.exports = function(deployer) {
    deployer.deploy(erc20Token, 10000, "TokaSeed Token", 18, "TokaSeed");
    deployer.deploy(SeedChain);
};