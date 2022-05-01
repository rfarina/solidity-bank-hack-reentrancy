const Bank = artifacts.require("Bank");
const BankHacker = artifacts.require("BankHacker");

module.exports = async function (deployer, network, accounts) {

  // Deploy Bank
  await deployer.deploy(Bank);
  
  // Populate Bank contract initial balance
  const bank = await Bank.deployed();
  await bank.initializeBalance({from:accounts[0], value:'5000000000000000000'}); // 5 ether

  
  // Deploy BankHacker, passing in instance of Bank
  await deployer.deploy(BankHacker,bank.address);
  
  // Populate BankHacker initial balance
  const hack = await BankHacker.deployed();
  // await hack.initializeBalance({from:accounts[0], value:'10000000000000000000'});// 10 ether

  // Run the hack
  let response = await hack.makeDeposit({from:accounts[1],value:'1000000000000000000'});
  console.log(`Response from hack.makeDeposit\n ${JSON.stringify(response, null, 2)}`);

  // let response2 = await hack.withdraw();
  // console.log(`Response from hack.withdraw\n ${JSON.stringify(response2, null, 2)}`);


};