### [solidity-bank-hack-reentrancy](https://github.com/rfarina/solidity-bank-hack-reentrancy)


## **April 2022**


# OVERVIEW

Bank-hack is a Solidity application that simulates a reentrancy attack which occurred against The Dao in 2016. The simplicity of the attack was to fund the DAO’s deposit account with 1 ether, then request the withdrawal of the same 1 ether balance, which according to the contract was legitimate. Providing there was enough ether in the requesting contract’s deposit account, the DAO would send the requested ether to the requesting contract and subsequently reduce its deposit balance accordingly. 

However, a security flaw that went unnoticed allowed the attacking contract to recursively invoke the withdraw function and have it send 1 ether for each invocation until the victim contract’s balance was depleted! This occurred because the victim contract did not reduce the attacker’s deposit balance until _after_ it sent the funds. Recognizing this security vulnerability, the attacking contract was able to invoke the withdrawal function repeatedly until the victim contract’s account balance was nearly depleted! This hack is infamously known as the Reentracy Hack.

The purpose of this application is to recreate the reentrancy attack using a victim Bank contract, and an attacker BankHacker contract. The attack takes place by invoking the BankHacker “makeDeposit()” function. This function will deposit 1 ether into the bank, then immediately withdraw it legitimately. However, when the Bank contract sends the 1 ether withdrawal to the attacking contract, it hits the “receive()” function. The “receive()” function automatically adds to the BankHacker contract balance, and then invokes the Bank contract’s “withdraw()” function again, provided the Bank contract balance is >= 1 ether. This loop continues until the Bank contract account balance is effectively depleted.

To avoid this security flaw, it has been well established that contracts should reduce the deposit balance first, then send the funds. This will allow the Bank contract to avoid this type of attack. Another approach to avoiding this issue is to implement the use of a reentrancy guard, such as provided by OpenZeppelin. You can read more about this at [https://blog.openzeppelin.com/reentrancy-after-istanbul/](https://blog.openzeppelin.com/reentrancy-after-istanbul/).

Bank-hack was developed using Solidity and the Truffle Suite, and is deployed to a local Ganache Blockchain. Bank-hack can also be deployed to the Ethereum Blockchain on Mainnet once security audits have been completed and the application is shown to be production ready.

All functional testing was performed manually in the Truffle Console using the web3 javascript API.  Unit tests were implemented with the mocha framework and chai assertion library.


# Goals

Simulate The Dao Reentrancy attack using Solidity and the Truffle Suite


## **Dependencies**

Node.js:[ https://nodejs.org/en/](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbjFpNFNQUjNCdlNZeldkUHV0MV96VW9CNEdvd3xBQ3Jtc0tsWFUyVTE2MFByV19HZmV3eXdQV2hwTXp6MU45QkJteGpKX1BoQmZDb1E4UmxmT3QxTF9CSGp0SHVQSlQzOVpkbDJFNm1vdjNOTUltQi0yYnV1MWpqLS1yWTB3ZUp3ci12ZzRCb2oydmhieS00SmxWbw&q=https%3A%2F%2Fnodejs.org%2Fen%2F) (recommended v14.16.0)

Truffle:[ https://www.trufflesuite.com/](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbHEtZW9IamRub1RUYVlKSkVpdWVaaWo4andLZ3xBQ3Jtc0tsT0dsQ0pJUW1IX202MlBFenZ3YWVCcUFqOFhPbFdmdGtRRmFIS2RQRWExNGRIb1hxekxNY3J3dXhCM3hMY1VPS1RlbjFnYjY4dlk0Qk8talZoWnAyNlBNeFhVdTF3b01QR1E3QmZwamxwM0VYT2hpaw&q=https%3A%2F%2Fwww.trufflesuite.com%2F) (recommended v5.5.0)

Ganache:[ https://www.trufflesuite.com/ganache](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbFdsRTJTYzNUU1lVamhxU2ZoMy13bE5oeEExQXxBQ3Jtc0tuMDF5MEpTSy1NNjZzakNJeDdtQ0Zqb0wzTjZ6UmtnVmphN2N5RndyRlNwZ1ZEM2lzZk5MeHVEbzFwYUVFZzkyeFZUV3ZJeTZIQ2Frdl9Cc095SUN6aHB3cFNLbzN4aVpYSXBJclB5VUt2aThUcUJyUQ&q=https%3A%2F%2Fwww.trufflesuite.com%2Fganache)

Metamask: [https://metamask.io/](https://metamask.io/)


## **Installation**

git clone [git@github.com](mailto:git@github.com):rfarina/solidity-bank-hack-reentrancy.git solidity-bank-hack-reentrancy

npm install -g truffle@5.5.0

npm install

Download, Install and run ganache to establish the Blockchain for local testing

[https://trufflesuite.com/ganache/](https://trufflesuite.com/ganache/)


## **Test truffle installation**

truffle version (should result in the following):

Truffle v5.5.0 (core: 5.5.0)

Solidity - ^0.8.11 (solc-js)

Node v14.16.0

Web3.js v1.5.3


## **Compilation**

_Make sure ganache is started_

truffle compile


## **Unit Testing**

truffle test


## **Deployment to Ganache**

truffle migrate ---reset (should result in Accounts created and Contracts deployed to Ganache)


# Attributions

Original idea from “Mastering Ethereum-Building Smart Contracts and DApps”, by Andreas M. Antonopoulos and Dr. Gavin Wood

**_End of Document_**
