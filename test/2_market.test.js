require('chai').use(require('chai-as-promised')).should();

const Nft    = artifacts.require("Nft");
const Market = artifacts.require("Market");

let nft;
let market;

before(async () => {
    nft    = await Nft.deployed();
    market = await Market.deployed(nft.address);
})

contract("Market", (accounts) => {

    describe('1. Deployment', async () => {
        it('1.1 Deploys Successfully', async () => {
            const address = await market.address

            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })

        it("1.2 Initial Success", async () => {
            const owner      = await nft.owner()
            const nftAddress = await market.nftAddress()

            assert.equal(owner, accounts[0])
            assert.equal(nftAddress, nft.address)
        });
    })
});
