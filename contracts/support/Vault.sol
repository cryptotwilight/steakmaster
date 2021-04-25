// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2; 

import "../dependency/IERC20.sol";
import "./IVault.sol";
import "../IStake.sol";

contract Vault is IVault { 
    
    struct Deposit {
        address stakeAddress; 
        address source; 
        address erc20Contract; 
        uint256 amount;
        uint256 depositDate; 
    }
    
    mapping(address=>Deposit) depositByStakeAddress; 
    address [] stakeAddresses; 
    mapping(address=>bool) depositedStatusByStakeAddress; 
    mapping(address=>bool) withdrawnStatusByStakeAddress; 
    
    /**
     * depostis the funds for the stake into the vault
     * A stake can only be deposited once and withdrawn once i.e. a stake can not be reused 
     */
    function deposit(address _stakeAddress) override external payable returns (bool _recorded){
        require(!depositedStatusByStakeAddress[_stakeAddress], "d 00 - already deposited ");
        IStake stake = IStake(_stakeAddress);
        address _erc20ContractAddress = stake.getCurrencyContractAddress(); 
        
        
            uint256 _amount = stake.getAmount(); 
            address _source = stake.getOwner();
        if(_erc20ContractAddress != address(0)) {    
            // approve the spend
            IERC20 ierc20 = IERC20(_erc20ContractAddress);
            
            // transfer teh funds into the vault
            ierc20.transferFrom(_source, address(this), _amount); 
        }
        else {
            require(msg.value >= _amount, "d 01 insufficient ETH deposit");
        }
        Deposit memory l_deposit = Deposit({ stakeAddress : _stakeAddress,
                                    source : _source,
                                    erc20Contract : _erc20ContractAddress,
                                    amount : _amount,
                                    depositDate : block.timestamp});
                                    
        depositByStakeAddress[_stakeAddress] = l_deposit; 
        depositedStatusByStakeAddress[_stakeAddress] = true; 
        stakeAddresses.push(_stakeAddress);
        return true;
    }
    /**
     * withdraws the funds for the stake from the vault
     */
    function withdraw( address _stakeAddress, address _destination) override external returns (uint256 _withdrawnAmount){
        require(withdrawnStatusByStakeAddress[_stakeAddress] == false, 'w 00 - stake already withdrawn');
        // set the status to withdrawn to prevent reentry
        withdrawnStatusByStakeAddress[_stakeAddress] = true; 
        
        Deposit memory d = depositByStakeAddress[_stakeAddress];
        IERC20 ierc20 = IERC20(d.erc20Contract);
        ierc20.transfer(_destination, d.amount); 
        
        return d.amount; 
    }
    
     address [] sAddresses;
     address [] sources;
     address [] erc20s;
     uint256 [] amounts; 
     uint256 [] depositDates;
 
    /**
     * returns the deposits that are currently held
     */
    function getDepositsHeld() override  external returns (address [] memory  _stakeAddress, address [] memory _sources, address [] memory _erc20Contracts, uint256  []  memory _amounts, uint256 []  memory _depositDates) {
       
       sAddresses = new address[](0);
       sAddresses = new address[](0);
       sAddresses = new address[](0);
       amounts = new uint256[](0);
       depositDates = new uint256[](0);
       
        for(uint x = 0 ; x < stakeAddresses.length; x++){
            address sa = stakeAddresses[x];
            if(withdrawnStatusByStakeAddress[sa] == false) {
                Deposit memory d = depositByStakeAddress[sa];
                sAddresses.push(d.stakeAddress);
                sources.push(d.source);
                erc20s.push(d.erc20Contract);
                amounts.push(d.amount);
                depositDates.push(d.depositDate);
            }
        }
        
        return (sAddresses, sources, erc20s, amounts, depositDates);
    }
    
    
}
