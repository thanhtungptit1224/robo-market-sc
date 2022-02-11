const {deployProxy, upgradeProxy}   = require('@openzeppelin/truffle-upgrades');
const Nft                           = artifacts.require('Nft');

module.exports = async function (deployer, network, accounts) {
    console.log('Nft deploy information:', network, accounts[0]);

    const nftInstance = await deployProxy(Nft, {deployer});
    console.table({Nft: nftInstance.address})
}