// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >0.7.0 <0.9.0;

/**
 * This interface is purely for creating an unregistered stake
 */ 

interface IStakeMaker {
    
    function createUnregisteredStake(address _owner, address _holder, uint256 _amount, string memory _currencyName, 
                                        address _erc20ContractAddress, string memory _ruleSetName, address _ruleSetAddress, 
                                        string memory _details, uint256 _startDate, uint256 _endDate)external returns (address _unregisteredStakeAddress);
                                        
    function getunregisteredStakes () external view returns (address [] memory _createdStakes);
    
    
    function getAllUnregisteredStakes () external view returns(address [] memory _createdStakes);
    
}
