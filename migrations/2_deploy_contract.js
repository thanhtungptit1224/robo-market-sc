const Nft = artifacts.require('Nft');

module.exports = async function (deployer) {
    const nftInstance = await deployer.deploy(Nft);
    console.log(nftInstance);
}