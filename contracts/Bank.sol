// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Bank {

    mapping(address => uint256) public depositBalance;

    event DepositMade (
        address intoAccount,
        uint256 value
    );

    event Withdrawal (
        address fromAccount,
        uint256 value,
        address origin,
        bool txResult,
        bytes callData
    );

    function deposit(address payable depositor, uint value) external payable {
        /* 
            @dev payable function that accepts deposits from depositor
         */

        // deposit incoming funds
        depositBalance[depositor] += value;

        emit DepositMade(depositor, value);
    }

    function withdraw(address payable withdrawToAddress, uint weiToWithdraw) external {
        // send funds from depositBalance[msg.sender] to msg.sender
        require(depositBalance[withdrawToAddress] >= weiToWithdraw, 'Not enough ether in depositor balance to withdraw');

        (bool result, bytes memory data) = withdrawToAddress.call{value:weiToWithdraw}("");  // send money to withdrawToAddress B4 deducting depositBalance !!
        depositBalance[withdrawToAddress] -= weiToWithdraw;

        emit Withdrawal(
            withdrawToAddress, 
            weiToWithdraw,
            tx.origin,
            result,
            data
        );
    }
    function getDepositBalance(address depositor) external view returns (uint256) {
        return depositBalance[depositor];
    }

    receive() external payable {
        // allow ether to be posted to contract ether balance
    }
}