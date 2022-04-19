const Bank = artifacts.require("Bank");
const BankHacker = artifacts.require("BankHacker");

module.exports = async function (deployer) {
  await deployer.deploy(Bank);
  const bank = await Bank.deployed();
  console.log(`Bank address: ${bank.address}`);

  await deployer.deploy(BankHacker,bank.address);
};