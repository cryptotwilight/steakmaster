// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./IStakeMaster.sol";
import "./IStake.sol";
import "./support/Stake.sol";
import "./support/IVault.sol";
import "./dependency/IERC20.sol";


contract StakeMaster is IStakeMaster { 


    mapping(address=>IStake[]) stakeByStakeOwnerAddress; 
    
    mapping(address=>IStake[]) stakeByStakeHolderAddress; 

    mapping(address=>IStake) stakeByStakeAddress; 
    
    mapping(address=>bool) stakeRegistrationStatusByStakeAddress; 
    
    mapping(address=>bool) stakeReleaseStatusByStakeAddress; 
    
    mapping(address=>IStake) originalStakeDataByStakeAddress; 
    
    mapping(address=>address) registeredStakeAddressByOriginalStakeAddress; 
    
    mapping(address=>address[]) registeredStakeAddressesByOwner;
    
    mapping(address=>address[]) registeredStakeAddressesByHolder;
    
    mapping(address=>address) stakeAccountByOwner; 
    
    mapping(address=>bool) stakeAccountStatusByOwner; 
    
    mapping(address=>mapping(string=>uint256)) walletMetricsByCategoryByAddress; 

    address administratorAddress; 
    address vaultAddress; 
    IVault vault; 
    
    uint256 postedStakeCount; 
    uint256 releasedStakeCount; 
    uint256 activeStakeCount; 
    
    address [] registeredStakeAddressList; 
    

    constructor(address _administratorAddress, 
                address _vaultAddress){
        vault = IVault(_vaultAddress);
        vaultAddress = _vaultAddress; 
        administratorAddress = _administratorAddress;
    }

    

    function postStake(address _unregisteredStakeAddress ) override payable external returns (address _registeredStakeAddress){
        
        require(!stakeRegistrationStatusByStakeAddress[_unregisteredStakeAddress], 'ps 00 - stake address already registered.' );
        
        // clone the stake - to control the details submitted
        address clonedStakeAddress = clone(_unregisteredStakeAddress);
        
        IStake clonedStake = IStake(clonedStakeAddress);
        
        uint256 stakeAmount = clonedStake.getAmount();
        address erc20ContractAddress = clonedStake.getCurrencyContractAddress();
        
        if(erc20ContractAddress != address(0)) {
            IERC20 ierc20 = IERC20(erc20ContractAddress);
            
            // transfer the required amount to Stake Master
            ierc20.transferFrom(clonedStake.getOwner(), address(this), stakeAmount);
            
            // approve the Vault
            ierc20.approve(vaultAddress, stakeAmount);
        
            // deposit the stake amount into the vault 
            vault.deposit(clonedStakeAddress);
        }
        else {
            // deposit the stake amount into the vault
            vault.deposit{value : stakeAmount}(clonedStakeAddress);
        }
        
        // check the details of the stake are aligned 
        verifyStakeInternal(clonedStakeAddress);  
        
        // register the stake
        registerStake(clonedStakeAddress);
       
        registeredStakeAddressList.push(clonedStakeAddress);
        
        walletMetricsByCategoryByAddress[clonedStake.getOwner()]["tvl"] += clonedStake.getAmount();
        walletMetricsByCategoryByAddress[clonedStake.getHolder()]["tvl"] += clonedStake.getAmount();
        walletMetricsByCategoryByAddress[clonedStake.getOwner()]["svp"] += clonedStake.getAmount();
        walletMetricsByCategoryByAddress[clonedStake.getHolder()]["svh"] += clonedStake.getAmount();
        
        postedStakeCount++; 
        activeStakeCount++;
     
        return clonedStakeAddress; 
    }
    
    function isRegistered(address _stakeAddress) view external returns (bool _registered) {
        return stakeRegistrationStatusByStakeAddress[_stakeAddress];
    }
    
    function verifyStakeInternal(address _stakeAddress) internal returns (bool _valid) {
        IStake stake  = IStake(_stakeAddress);
        
        // check the start date is before the end date
        require (stake.getStartDate() < stake.getEndDate(), 'vsi 01 - start date before end date');
        
        // check the start date has been passed
        require(stake.getStartDate() < block.timestamp, 'vsi 02 - start date has not been reached');
        
        // check the end date has not been passed
        require(stake.getEndDate () > block.timestamp, 'vsi 03 - end date has been passed');
        return true; 
    }
    
    function verifyStake(address _stakeAddress) override external returns (bool _valid){ 
        
        // check the stake is registered
        require(this.isRegistered(_stakeAddress), "vs 00 - stake not registered");
        
        return verifyStakeInternal(_stakeAddress);
    }
    
    function getRegisteredStakeAddress(address _unregisteredStakeAddress) override external view returns (address _registeredStakeAddress) {
        return registeredStakeAddressByOriginalStakeAddress[_unregisteredStakeAddress];
    }
    
    function getStakesHeld(address _holder) override external view returns (address [] memory _stakesHeld){
        return registeredStakeAddressesByHolder[_holder];
    }
    
    function getStakesOwned(address _owner) override external view returns (address [] memory stakesOwned) {
        return registeredStakeAddressesByOwner[_owner];
    }
    

    
    
    function getRegisteredStakeList() override external view returns (address [] memory registeredStakes) {
        return registeredStakeAddressList; 
    }
    
    function releaseStake(address _stakeAddress) override external returns (string memory _releaseStatus){
        require(!stakeReleaseStatusByStakeAddress[_stakeAddress], ' rs 00 - stake already released ');
        
        //get the stake to be released
        IStake stake = stakeByStakeAddress[_stakeAddress];
        
        // make sure it is only the holder calling for the release 
        require(msg.sender == stake.getHolder(), 'rs 01 - holder only operation' );
        
        // withdraw the stake to the owner
        vault.withdraw(_stakeAddress, stake.getOwner());
        
        string memory releaseStatus = "RELEASED";
        
        // update the release status 
        Stake oStake = Stake(_stakeAddress);
        oStake.updateStatus(releaseStatus);
        
        stakeReleaseStatusByStakeAddress[_stakeAddress] = true; 
        
        
        walletMetricsByCategoryByAddress[oStake.getOwner()]["tvl"] -= oStake.getAmount();
        walletMetricsByCategoryByAddress[oStake.getHolder()]["tvl"] -= oStake.getAmount();
        walletMetricsByCategoryByAddress[oStake.getOwner()]["svp"] -= oStake.getAmount();
        walletMetricsByCategoryByAddress[oStake.getHolder()]["svh"] -= oStake.getAmount();
        walletMetricsByCategoryByAddress[oStake.getHolder()]["svrl"] += oStake.getAmount();
        walletMetricsByCategoryByAddress[oStake.getOwner()]["svrt"] += oStake.getAmount();
        
        
        releasedStakeCount++;
        activeStakeCount--;
        
        return releaseStatus; 
    }
 
 
    function getWalletValues() override external view returns (uint256 _totalValueLocked, uint256 _stakeValuePosted, uint256 _stakeValueHeld,  
                                                                uint256 _stakeValueSlashed, uint256 _stakeValueContested, uint256 _stakeValueReleased, 
                                                                uint256 _stakeValueReturned){
        uint256 tvl = walletMetricsByCategoryByAddress[msg.sender]["tvl"];
        uint256 svp = walletMetricsByCategoryByAddress[msg.sender]["svp"];
        uint256 svh = walletMetricsByCategoryByAddress[msg.sender]["svh"];
        uint256 svs = walletMetricsByCategoryByAddress[msg.sender]["svs"];
        uint256 svc = walletMetricsByCategoryByAddress[msg.sender]["svc"];
        uint256 svrl = walletMetricsByCategoryByAddress[msg.sender]["svrl"];
        uint256 svrt = walletMetricsByCategoryByAddress[msg.sender]["svrt"];
        return (tvl, svp, svh, svs, svc, svrl, svrt);
    }

 

    function getActiveStakeCount() override external view returns (uint256 _activeStakeCount){
        return activeStakeCount; 
    }
  
   
    function getPostedStakeCount() override external view returns (uint256 _postedStakeCount){
        return postedStakeCount;
    }
        
    
    function getReleasedStakeCount() override external view returns (uint256 _releasedStakeCount){
        return releasedStakeCount; 

    }
 
    function getSlashFee(address _stakeKey) override external view returns (uint256 _slashFee, string memory _slashFeeCurrency, address _erc20Contract){
        
    }
    
    function getSlashContestFee(address _stakeKey) override external view returns (uint256 slashContestFee, string memory _slashFeeCurrency, address _erc20Contract){
        
    }
    
    function getSlashDisputeSettlementFee(address _stakeKey) override external returns (uint256 slashDisputeSettlementFee, string memory _slashFeeCurrency, address _erc20Contract){
        
    }
  
    function slashStake(address _slashClaim, address _proof, address _stakeKey, uint256 _slashFee) override payable external returns (address _slashKey, string memory slashStatus){
        
    }
  
    function contestSlash(address _stakeKey, uint256 _slashContestFee) override payable external returns (address _slashKey, uint256 timeToLive){
        
    }
    
    function settleSlashDispute(address _slashKey, address _aggreement, uint256 _slashDisputeSettlementFee) override payable external returns (string memory settlementStatus){
        
    }
    
    function registerStake(address _stakeAddress) internal returns (bool _registered) {
        Stake stake = Stake(_stakeAddress);
        stakeByStakeOwnerAddress[stake.getOwner()].push(stake); 
        stakeByStakeHolderAddress[stake.getHolder()].push(stake);
        stakeByStakeAddress[_stakeAddress] = stake; 
        
        registeredStakeAddressesByOwner[stake.getOwner()].push(_stakeAddress);

        registeredStakeAddressesByHolder[stake.getHolder()].push(_stakeAddress); 
        
        registeredStakeAddressByOriginalStakeAddress[stake.getOriginalStakeDataAddress()] = _stakeAddress;
        
        IStake osd = IStake(stake.getOriginalStakeDataAddress());
        originalStakeDataByStakeAddress[_stakeAddress] = osd; 
        stakeRegistrationStatusByStakeAddress[_stakeAddress] = true; 
        return true; 
    }
    
    function clone(address _originalStakeAddress) internal returns (address _clonedStake) {
        IStake originalStake = IStake(_originalStakeAddress);
 
        Stake stake = new Stake(address(this),  originalStake.getOwner(), 
                                originalStake.getHolder(), originalStake.getAmount(), 
                                originalStake.getCurrencyName(), originalStake.getCurrencyContractAddress(), 
                                originalStake.getRuleSetName(), originalStake.getRuleSetAddress(), 
                                originalStake.getDetails(), originalStake.getStakeStatus(), _originalStakeAddress);
        stake.setStartDate( originalStake.getStartDate());
        stake.setEndDate( originalStake.getEndDate());
        return address(stake);
    }

}
