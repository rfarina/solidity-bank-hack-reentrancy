// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/* 
    @dev to catch errors on an address.transfer() function, the
    invocation must be executed on an external function.

    The transfer() function below will be used to perform
    transfers from the bank contract that wants to try/catch
    the invocation.
 */
contract CalledContract {
    function transfer(address payable to, uint value) public {
        // send funds via transfer()
        to.transfer(value);
    }

}

contract Bank {

    CalledContract public externalContract;

    mapping(address => uint256) public depositBalance;

    event DepositMade (
        address intoAccount,
        uint256 value
    );

    event FundsTransmitted (
        address originTx,
        address fromAddress,
        address toAddress,
        uint256 value,
        bool    txsuccess,
        bytes   callData
    );

    event FundsTransmissionFailure (
        address fromAddress,
        address toAddress,
        uint256 value,
        bytes  errorMessage
    );

    event DepositBalanceReduced (
        uint balanceReducedBy,
        uint newDepositBalance
    );

    constructor() {
        externalContract = new CalledContract();
    }

    function deposit(address payable depositor, uint value) external payable {
        /* 
            @dev payable function that accepts deposits from depositor
         */

        // deposit incoming funds
        depositBalance[depositor] += value;

        emit DepositMade(depositor, value);
    }


    function withdraw(address payable withdrawToAddress, uint weiToWithdraw) external {
        
        require(depositBalance[withdrawToAddress] >= weiToWithdraw, 'Not enough ether in depositor balance to withdraw');

        // // send requested funds via transfer()
        // try externalContract.transfer(payable(withdrawToAddress), weiToWithdraw) {

        //     emit FundsTransmitted (
        //         tx.origin,
        //         address(this), 
        //         withdrawToAddress, 
        //         weiToWithdraw, 
        //         true,
        //         bytes("funds sent via transfer()...")
        //     );

        // } catch (bytes memory revertReason) {

        //     emit FundsTransmissionFailure(
        //         address(this), 
        //         withdrawToAddress, 
        //         weiToWithdraw, 
        //         revertReason
        //     );
        // }


        // // send requested funds via send()
        // bool success = withdrawToAddress.send(weiToWithdraw);
        // if (success) {
        //     bytes memory data = bytes("no data with send()...");
            
        //     emit FundsTransmitted (
        //         tx.origin,
        //         address(this), 
        //         withdrawToAddress, 
        //         weiToWithdraw, 
        //         success,
        //         data
        //     );
        // } else {
        //     bytes memory errorMessage = bytes("error on send()...");

        //     emit FundsTransmissionFailure(
        //         address(this), 
        //         withdrawToAddress, 
        //         weiToWithdraw, 
        //         errorMessage);
        // }

        // send funds via call()
        (bool success, bytes memory data) = withdrawToAddress.call{value:weiToWithdraw}("");  // send money to withdrawToAddress B4 deducting depositBalance !!
        if (success) {
            
            emit FundsTransmitted (
                tx.origin,
                address(this), 
                withdrawToAddress, 
                weiToWithdraw, 
                success,
                data
            );
        } else {

            emit FundsTransmissionFailure(
                address(this), 
                withdrawToAddress, 
                weiToWithdraw, 
                bytes("send funds via call() failed...")
            );
        }


        // reduce balance
        depositBalance[withdrawToAddress] -= weiToWithdraw;
        
        emit DepositBalanceReduced(
            weiToWithdraw, 
            depositBalance[withdrawToAddress]
        );
    }
    function getDepositBalance(address depositor) external view returns (uint256) {
        return depositBalance[depositor];
    }

    receive() external payable {
        // allow ether to be posted to this contract's ether balance
    }
}