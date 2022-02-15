const BasicNft = artifacts.require("BasicNft");

module.exports = async function (deployer) {
    deployer.deploy(BasicNft, "Hong Hanh", "HHH");
};
