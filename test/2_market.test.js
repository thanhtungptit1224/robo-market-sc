const web3 = require("web3");
require('chai').use(require('chai-as-promised')).should();

const Nft    = artifacts.require("Nft");
const Market = artifacts.require("Market");

let nft;
let market;

before(async () => {
    nft    = await Nft.deployed();
    market = await Market.deployed(nft.address);
})

contract("Market", async (accounts) => {

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

    describe("2. Test Feature", async () => {
        let mintResult;
        let tokenId;

        before(async () => {
            mintResult = await nft.mint(accounts[0], 'url')
            tokenId    = mintResult.logs[0].args.tokenId.toNumber()
        })

        it("2.1 Listing", async () => {
            // Fail
            await market.list(tokenId, web3.utils.toWei('0', 'ether')).should.be.rejected;
            await market.list(tokenId, web3.utils.toWei('0.1', 'ether'), {from: accounts[1]}).should.be.rejected;
            await market.list(tokenId, web3.utils.toWei('0.1', 'ether')).should.be.rejected;

            // Success
            await nft.approve(market.address, tokenId)
            await market.list(tokenId, web3.utils.toWei('0.1', 'ether'));
            const item = await market.items(tokenId)

            assert.equal(item.tokenId, tokenId)
            assert.equal(item.owner, accounts[0])
            assert.equal(item.price, web3.utils.toWei('0.1', 'ether'))
            // assert.equal(item.status.toString(), 'LIST')
        })
    })
});
