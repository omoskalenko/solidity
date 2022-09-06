const {expect } = require('chai')
const {ethers } = require('hardhat')

describe("Payments",  () => {
  let acc1, acc2;
  let payments;

  beforeEach(async () => {
    [acc1, acc2] = await ethers.getSigners()

    const Payments = await ethers.getContractFactory("Payments",acc1) 
    payments = await Payments.deploy()

    await payments.deployed()
  })

  it('should be deployed', () => {
    expect(payments.address).to.be.properAddress
  })

  it('should have 0 ether by default', async () => {
    const balance = await payments.currentBalance()
    expect(balance).equal(0)
  })

  it('should be possible to send funds', async () => {
    const sum =100
    const msg = 'hello'
    const tx = await payments.connect(acc2).pay(msg, { value: 100 })

    await expect(() => tx).to.changeEtherBalances([acc2, payments], [-sum, sum])

    await tx.wait()

    const newPayment = await payments.getPayment(acc2.address, 0)
    expect(newPayment.message).to.eq(msg)

  })

  
})
