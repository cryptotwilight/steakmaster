// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >0.7.0 <0.9.0;
/**
 * The stake interface represents the stake that will be posted by the provider and either released or slashed by the client 
 */

interface IStake { 
    
    function getOwner() external returns (address _stakeOwner);
    
    function getHolder() external returns (address _stakeHolder);
    
    function getAmount () external returns (uint256 _amount);
    
    function getCurrencyName() external returns (string memory _currencyName);
    
    function getCurrencyContractAddress() external returns (address _erc20ContractAddress);
    
    function getRuleSetName() external returns (string memory _ruleSetName);
    
    function getRuleSetAddress() external returns (address _ruleSetAddress);
    
    function getStartDate() external returns (uint256 _startDate);
    
    function getEndDate()  external returns (uint256 _endDate);
    
    function getDetails() external returns (string memory _stakeDetails);
       
    function getStakeStatus() external returns (string memory _status);
}
