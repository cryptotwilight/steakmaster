// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >=0.7.0 <0.9.0;


interface IStakeMaster { 
    
    
    /**
     * postStake is called by the party that wishes to carry the risk 
     */ 
    function postStake(address _stake ) payable external returns (address _registeredStake);
    
    /**
     *  verify is called by anyone that wishes to verify the stake. It will check the dates on the stake 
     *  and whether the stake is registered. It will roll back if any of the details are not valid 
     */ 
    function verifyStake(address _stake) external returns (bool _valid);
    
    /**
     * releaseStake is called by the party that holds the stake 
     */
    function releaseStake(address _stake) external returns (string memory _releaseStatus);
  
    /**
     * get the registered stake address for an unregistered stake
     */ 
    function getRegisteredStakeAddress(address _unregisteredStakeAddress) external returns (address _registeredStakeAddress);
    
    /**
     * get stakes held by the presented holder address
     */
    function getStakesHeld(address _holder) external view returns (address [] memory _stakesHeld);
    
    /**
     * get stakes owned by the owner address
     */
    function getStakesOwned(address _owner) external view returns (address [] memory _stakesOwned);
    
    /**
     * get the number of posted stakes
     */
    function getPostedStakeCount() external returns (uint256 _postedStakeCount);
        
    /**
     * get the number fo released stakes 
     */ 
    function getReleasedStakeCount() external returns (uint256 _releasedStakeCount);

    /**
     * get the number of active stakes
     */ 
    function getActiveStakeCount() external returns (uint256 _activeStakeCount);
    
    /**
     * returns the metrics for the wallet 
     */ 
    function getWalletValues() external returns (uint256 _totalValueLocked, uint256 _stakeValuePosted, uint256 _stakeValueHeld, uint256 _stakeValueSlashed, uint256 _stakeValueContested, uint256 _stakeValueReleased, 
                                                                uint256 _stakeValueReturned);
    
    /** 
     * get complete list of registered stakes 
     */ 
    function getRegisteredStakeList() external view returns (address [] memory registeredStakes);
    
    /**
     * get slash Fee returns the cost to slash the stake 
     */ 
    function getSlashFee(address _stake) external view returns (uint256 _slashFee, string memory _slashFeeCurrency, address _erc20Contract);
    
    /**
     * get Slash Contest Fee is the fee necessary to contest a slash event
     */ 
    function getSlashContestFee(address _stake) external view returns (uint256 slashContestFee, string memory _slashFeeCurrency, address _erc20Contract);
    
    /**
     * this returns the fee necessary to settle a slash dispute raised by the system 
     */ 
    function getSlashDisputeSettlementFee(address _stake) external returns (uint256 slashDisputeSettlementFee, string memory _slashFeeCurrency, address _erc20Contract);
  
    /** Slashing */
  
    /**
     * slashStake is called by the party holding the stake in the event that the terms of the agreement have been violated. The owner of the stake is given 1 hour to contest the slash for a fee
     */ 
    function slashStake(address _slashClaim, address _proof, address _stake, uint256 _slashFee) payable external returns (address _slashKey, string memory slashStatus);
    
    /** 
     * slashContest is called by the owner of the stake. This gives a period of 24 hours for the slash to be settled. If it is not settled by then  
     */ 
    function contestSlash(address _stake, uint256 _slashContestFee) payable external returns (address _slashKey, uint256 timeToLive);
    
    /**
     * this is called by both parties to settle the slash dispute, both parties have to pay a fee to settle. THe aggreement is the set of rules to be followed in executing the slash
     */ 
    function settleSlashDispute(address _slash, address _aggreement, uint256 _slashDisputeSettlementFee) payable external returns (string memory settlementStatus);
    
}
