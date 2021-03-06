// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >=0.7.0 <0.9.0;

import "./IStakeMaker.sol";
import "./support/Stake.sol";


contract StakeMaker is IStakeMaker {
    
    address [] createdStakes; 
    mapping(address=>address[]) stakesByCreator; 

    function createUnregisteredStake(address _owner,
                                        address _holder, 
                                        uint256 _amount, 
                                        string memory _currencyName, 
                                        address _erc20ContractAddress, 
                                        string memory _ruleSetName, 
                                        address _ruleSetAddress,
                                        string memory _details,  
                                        uint256 _startDate, 
                                        uint256 _endDate) override external returns (address _unregisteredStakeAddress){
       
         Stake unregisteredStake = new Stake(address(this), 
                                                _owner, 
                                                _holder, 
                                                _amount, 
                                                _currencyName,  
                                                _erc20ContractAddress, 
                                                _ruleSetName, 
                                                _ruleSetAddress, 
                                                _details, 
                                                "UNREGISTERED", 
                                                address(0));
                                                
        unregisteredStake.setStartDate( _startDate);
        unregisteredStake.setEndDate( _endDate);
        
        createdStakes.push(address(unregisteredStake));
        
        address unregisterStakeAddress = address(unregisteredStake);
        
        stakesByCreator[msg.sender].push(unregisterStakeAddress);
        
        return address(unregisteredStake);
     }
     
     
     function getunregisteredStakes () override external view returns (address [] memory _createdStakes) {
         return stakesByCreator[msg.sender];
     }
     
     function getAllUnregisteredStakes () override external view returns(address [] memory _createdStakes) {
         return createdStakes;
     }
         
}
