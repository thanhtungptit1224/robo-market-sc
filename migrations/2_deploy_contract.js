const {deployProxy} = require('@openzeppelin/truffle-upgrades');
const Nft           = artifacts.require('Nft');
const Market        = artifacts.require('Market');

module.exports = async function (deployer, network, accounts) {
    console.log('Nft deploy information:', network, accounts[0]);

    const nftInstance = await deployProxy(Nft, {deployer});
    console.table({Nft: nftInstance.address})

    const marketInstance = await deployProxy(Market, [nftInstance.address], {deployer})
    console.table({Market: marketInstance.address})
}