// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.7.0 <0.9.0;

import "../IStake.sol";

contract Stake is IStake { 
    
    address stakeAdministrator; 
    address owner; 
    address holder; 
    uint256 amount; 
    string currencyName; 
    address erc20ContractAddress; 
    string ruleSetName; 
    address ruleSetAddress;
    uint256 startDate; 
    uint256 endDate; 
    string details;
    string status; 
    address originalStakeDataAddress; 
    bool isSED; 
    bool isSSD; 
    
    constructor(address _stakeAdministrator,
                address _owner, 
                address _holder, 
                uint256 _amount, 
                string memory _currencyName, 
                address _erc20ContractAddress, 
                string memory _ruleSetName, 
                address _ruleSetAddress, 
                string memory _details, 
                string memory _status, 
                address _originalStakeDataAddress){
             
        stakeAdministrator = _stakeAdministrator;
        owner = _owner; 
        holder = _holder; 
        amount = _amount; 
        currencyName = _currencyName; 
        erc20ContractAddress = _erc20ContractAddress;
        ruleSetName = _ruleSetName;
        ruleSetAddress = _ruleSetAddress;
        details = _details; 
        status = _status; 
        originalStakeDataAddress = _originalStakeDataAddress; 
    }
    function getOwner() override external view returns (address _stakeOwner){
        return owner; 
    }
    
    function getHolder() override  external view returns (address _stakeHolder){
        return holder; 
    }
    
    function getAmount () override external view returns (uint256 _amount){
        return amount; 
    }
    
    function getCurrencyName() override external view returns (string memory _currencyName){
        return currencyName;
    }

    function getCurrencyContractAddress() override external view returns (address _erc20ContractAddress) {
        return erc20ContractAddress;
    }

    function getRuleSetName() override external view returns (string memory _ruleSetName){
        return ruleSetName;
    }
    
    function getRuleSetAddress() override external view returns (address _ruleSetAddress) {
        return ruleSetAddress;
    }
    
    function getStartDate() override external view returns (uint256 _startDate){
        return startDate; 
    }
    
    function getEndDate()  override external view returns (uint256 _endDate){
        return endDate; 
    }
    
    function getDetails() override external view returns (string memory _stakeDetails){
        return details; 
    }
       
    function getStakeStatus()override  external view returns (string memory _status){
        return status; 
    }
    
    function getOriginalStakeDataAddress() external view returns (address _originalStakeDataAddress) {
        return originalStakeDataAddress; 
    }
    
    function updateStatus(string memory _status ) external  returns (bool _updated) {
        administratorOnly();
        status = _status;
        return true; 
    }
    
    function setStartDate(uint256 _startDate) external returns (bool _set) {
        administratorOnly();
        require(!isSSD, 'ssd 00  - start date already set');
        startDate = _startDate;
        isSSD = true; 
        return isSSD; 
    }
    
    function setEndDate(uint256 _endDate)  external returns (bool _set) {
        administratorOnly();
        require(!isSED, 'sed 00 - end date already set');
        endDate = _endDate; 
        isSED == true; 
        return isSED; 
    }
    
    function administratorOnly()  internal view returns (bool _isAdmin) {
        require(msg.sender == stakeAdministrator, "us 00 - administrator only");
        return true; 
    }
}
