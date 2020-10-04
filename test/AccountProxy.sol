pragma solidity ^0.5.0;


contract AccountProxy {

    event debug(address _address);

    address targetContract;

    constructor (address contractAddress) public {
        targetContract = contractAddress;
    }

    function callTargetContract(bytes memory _calldata, uint _value) public returns (bool result) {
        (result, ) = targetContract.call.value(_value)(_calldata);
    }

    function () external payable {
    }
}