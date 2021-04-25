// "SPDX-License-Identifier: UNLINCENSED"
pragma solidity >=0.7.0 <0.9.0;


interface IStakeMasterGateway {
    
    function getStakeMasterAddress() external view returns (address _stakeMaster);
    
    function getStakeMakerAddress() external view returns (address _stakeMaker);
    
}
