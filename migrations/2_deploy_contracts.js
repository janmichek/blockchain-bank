const Token = artifacts.require("Token")
const dBank = artifacts.require("dBank")

module.exports = async function (deployer) {
  await deployer.deploy(Token)

  //assign token into variable to get its address
  const token = await Token.deployed()

  // pass token address for minting
  await deployer.deploy(dBank, token.address)

  const dbank = await dBank.deployed()

  // change token's owner/minter from deployer to dBank
  await token.passMinterRole(dbank.address)
}
