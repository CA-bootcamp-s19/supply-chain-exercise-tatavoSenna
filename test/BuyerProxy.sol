pragma solidity ^0.5.0;



contract BuyerProxy {

    event debug(address _address);

    address supplyChainAddress;

    constructor (address _address) public {
        supplyChainAddress = _address;
    }

    function buyItem(bytes memory _calldata) public returns (bool result) {
        (result, ) = supplyChainAddress.call.value(1 ether)(_calldata);
    }

    function () external payable {
    }
}