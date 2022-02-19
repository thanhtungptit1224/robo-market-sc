require('chai').use(require('chai-as-promised')).should();

const Nft = artifacts.require("Nft") ;
let nft;

before(async () => {
    nft = await Nft.deployed();
})

contract("Nft" , (accounts) => {

    describe('deployment', async () => {
        it('deploys successfully', async () => {
            const address = await nft.address

            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })

        it("Initial Success" , async () => {
            const name   = await nft.name()
            const symbol = await nft.symbol()
            const owner  = await nft.owner()

            assert.equal(name, "Robox")
            assert.equal(symbol, "RBX")
            assert.equal(owner, accounts[0])
        });
    })
});
