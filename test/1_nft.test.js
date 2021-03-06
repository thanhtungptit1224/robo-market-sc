require('chai').use(require('chai-as-promised')).should();

const Nft = artifacts.require("Nft");
let nft;

before(async () => {
    nft = await Nft.deployed();
})

contract("Nft", (accounts) => {

    describe('1. Deployment', async () => {
        it('1.1 Deploys Successfully', async () => {
            const address = await nft.address

            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })

        it("1.2 Initial Success", async () => {
            const name   = await nft.name()
            const symbol = await nft.symbol()
            const owner  = await nft.owner()

            assert.equal(name, "Robox")
            assert.equal(symbol, "RBX")
            assert.equal(owner, accounts[0])
        });
    })

    describe('2. Test Feature', async () => {
        it("2.1 Mint and burn NFT", async () => {
            const mintResult = await nft.mint(accounts[0], 'url')
            const tokenId    = mintResult.logs[0].args.tokenId.toNumber()
            const url        = await nft.tokenURI(tokenId)
            let balance      = await nft.balanceOf(accounts[0])

            assert.equal(1, tokenId)
            assert.equal(1, balance.toNumber())
            assert.equal(url, "url")

            await nft.burn(tokenId)
            balance = await nft.balanceOf(accounts[0])

            assert.equal(0, balance.toNumber())
        })
    })

});
