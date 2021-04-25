// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >=0.7.0 <0.9.0;

/**
 * The vault is a secure onchain location that holds the value of all the stakes. 
 * Stakes can only be completely withdrawn 
 */ 

interface IVault {
    
    /**
     * makes a deposit into the vault
     */ 
    function deposit(address _stakeAddress) external payable returns (bool _recorded);
     
    /**
     * makes a weithdrawla from the vault of the complete stake amount to the destination address
     */
    function withdraw( address _stakeAddress, address _destination) external returns (uint256 _withdrawnAmount);
    
    /**
     * lists all the deposits held in the vault
     */ 
    function getDepositsHeld() external returns (address [] memory  _stakeAddress, address [] memory source, address [] memory erc20Contract, uint256  []  memory _amount, uint256 []  memory _depositDate);   
    
}
