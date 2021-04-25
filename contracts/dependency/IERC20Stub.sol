// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";


contract IERC20Stub is IERC20  {
    
    uint256 totalSupplyAmount = 100000000000000;
    mapping(address=>uint256) balancesByAccountAddress; 
    mapping(address=>mapping(address=>bool)) spenderApprovalsByOwner;
    mapping(address=>mapping(address=>uint256)) spenderLimitByOwner; 
    
    address[] ownersWithApprovals; 
    address[] ownersWithTransfers; 
    address[] knownSpenders; 
    
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() override external view returns (uint256){
        return totalSupplyAmount;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) override external view returns (uint256){
        return balancesByAccountAddress[account];
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) override external returns (bool){
        address owner = msg.sender;
        uint256 obalance = balancesByAccountAddress[owner];
        require(obalance >= amount, "00 t -insufficient balance");
        uint256 rbalance = balancesByAccountAddress[recipient];
        obalance -= amount;
        balancesByAccountAddress[owner] = obalance;
        rbalance += amount;
        balancesByAccountAddress[recipient] = rbalance; 
        emit Transfer(owner, recipient, amount);
        return true; 
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) override external view returns (uint256){
        return spenderLimitByOwner[owner][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) override external returns (bool){
        address owner = msg.sender; 
        spenderLimitByOwner[owner][spender] = amount; 
        spenderApprovalsByOwner[owner][spender] = true; 
        ownersWithApprovals.push(owner);
        knownSpenders.push(spender);
        emit Approval(owner, spender, amount);
        return true; 
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool){
        address owner = sender;
        address spender = msg.sender; 
        if(owner == spender){
            return this.transfer(recipient, amount);
        }
        require(spenderApprovalsByOwner[owner][spender], "01 tf - approval required");
        require(spenderLimitByOwner[owner][spender] >= amount, '02 tf - higher approval limit required');
        uint256 obalance = balancesByAccountAddress[owner];
        require(obalance >= amount, "03 tf - insufficient balance");
        uint256 rbalance = balancesByAccountAddress[recipient];
        obalance -= amount;
        balancesByAccountAddress[sender] = obalance;
        rbalance += amount;
        balancesByAccountAddress[recipient] = rbalance; 
        ownersWithTransfers.push(owner);
        knownSpenders.push(spender);
        emit Transfer(owner, recipient, amount);
        return true; 
    }

    function mint(address _owner)  external returns (uint256 _amountMinted) {
        uint256 bal = 1000000;
        balancesByAccountAddress[_owner] = bal ; 
        totalSupplyAmount -= bal;
        return balancesByAccountAddress[_owner];
    }

    function  getKnownSpenders() external view returns(address[] memory _knownSpenders) {
        return knownSpenders;
    }
    
    function  getOwnersWithTransfers() external view returns(address[] memory _ownersWithTransfers) {
        return ownersWithTransfers;
    }
    
    function  getownersWithApprovals() external view returns(address[] memory _ownersWithApprovals) {
        return ownersWithApprovals;
    }
}
