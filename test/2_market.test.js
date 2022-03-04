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
            assert.equal(item.status.toString(), '0') // enum -> follow by index
        })

        it("2.2 Buy Item", async () => {
            await market.list(tokenId, web3.utils.toWei('0.1', 'ether'))

            // Fail
            await market.buyItem(tokenId, {from: accounts[1], value: web3.utils.toWei('0', 'ether')}).should.be.rejected;

            // Success
            await market.buyItem(tokenId, {from: accounts[1], value: web3.utils.toWei('0.1', 'ether')})
            const item = await market.items(tokenId)

            assert.equal(item.owner, accounts[1])
            assert.equal(item.status.toString(), '1')
        })

        it("2.3 Sell Item", async () => {
            // Fail
            await market.sellItem(tokenId, web3.utils.toWei('0.2', 'ether'), {from: accounts[0]}).should.be.rejected;
            await market.sellItem(tokenId, web3.utils.toWei('0', 'ether'), {from: accounts[1]}).should.be.rejected;

            // Success
            await nft.approve(market.address, tokenId, {from: accounts[1]})
            await market.sellItem(tokenId, web3.utils.toWei('0.2', 'ether'), {from: accounts[1]});
            const item = await market.items(tokenId)

            assert.equal(item.owner, accounts[1])
            assert.equal(item.price, web3.utils.toWei('0.2', 'ether'))
            assert.equal(item.status.toString(), '0')
        })

        it("2.4 UnList item", async () => {
            // Fail
            await market.unSellItem(tokenId, {from: accounts[0]}).should.be.rejected;

            // Success
            await market.unSellItem(tokenId, {from: accounts[1]})
            const item = await market.items(tokenId)

            assert.equal(item.owner, accounts[1])
            assert.equal(item.status.toString(), '3')
        })

        it("2.5 Offer Item", async () => {
            // Fail
            await market.offerItem(tokenId, {from: accounts[2], value: web3.utils.toWei('0', 'ether')}).should.be.rejected;

            // Success
            await market.offerItem(tokenId, {from: accounts[2], value: web3.utils.toWei('0.1', 'ether')});
            await market.offerItem(tokenId, {from: accounts[2], value: web3.utils.toWei('0.2', 'ether')}).should.be.rejected;
            const itemOffer = await market.itemOffers(tokenId, accounts[2]);

            assert.equal(itemOffer.tokenId, tokenId)
            assert.equal(itemOffer.price, web3.utils.toWei('0.1', 'ether'))
            assert.equal(itemOffer.offerBy, accounts[2])
        })

        it("2.6 Cancel Offer Item", async () => {
            // Fail
            await market.cancelOfferItem(tokenId, {from: accounts[3]}).should.be.rejected;

            // Success
            await market.cancelOfferItem(tokenId, {from: accounts[2]})
            const itemOffer = await market.itemOffers(tokenId, accounts[2]);

            assert.equal(itemOffer.tokenId.toNumber(), 0)
        })

        it('2.7 Accept Offer Item', async () => {
            await market.offerItem(tokenId, {from: accounts[2], value: web3.utils.toWei('0.1', 'ether')});

            // Fail
            await market.acceptOfferItem(tokenId, accounts[2], {from: accounts[3]}).should.be.rejected

            // Success
            await nft.approve(market.address, tokenId, {from: accounts[1]})
            await market.acceptOfferItem(tokenId, accounts[2], {from: accounts[1]})
            const item = await market.items(tokenId)
            const itemOffer = await market.itemOffers(tokenId, accounts[2])

            assert.equal(item.owner, accounts[2])
            assert.equal(item.price, web3.utils.toWei('0.1', 'ether'))
            assert.equal(item.status.toString(), '1')

            assert.equal(itemOffer.tokenId.toNumber(), 0)
        })
    })
});
