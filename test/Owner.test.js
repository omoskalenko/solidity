const {expect } = require('chai')
const {ethers } = require('hardhat')

describe("Owner",  () => {
  let owner, other_addr;
  let contract;

  beforeEach(async () => {
    [owner, other_addr] = await ethers.getSigners()

    const Contract = await ethers.getContractFactory("Owner",owner) 
    contract = await Contract.deploy()

    await contract.deployed()
  })

  async function sendMoney(sender) {
    const amount = 100;
    const txData = {
      to: contract.address,
      value: amount
    }

    const tx = await sender.sendTransaction(txData);
    await tx.wait()
    return [tx, amount]
  }

  it('should allow send money', async() => {
    const [sendMoneyTx, amount ] = await sendMoney(other_addr);

    await expect(() => sendMoneyTx).to.changeEtherBalance(contract, amount);

    const timestamp = (await ethers.provider.getBlock(sendMoneyTx.blockNumber)).timestamp

    await expect(sendMoneyTx).to.emit(contract, "Paid").withArgs(other_addr.address, amount, timestamp)
  })

  it('should allow owner to withdraw money', async() => {
    const [_,amount ] = await sendMoney(other_addr);

    const tx = await contract.withdraw(owner.address);

   await expect(()=> tx).to.changeEtherBalances([contract, owner], [-amount,amount])
  })

  it('should not allow owner to withdraw money(NEGATIVE)', async() => {
    await sendMoney(other_addr);

    await expect(contract.connect(other_addr).withdraw(other_addr.address)).to.be.revertedWith("you are not an owner!")
  })

})
