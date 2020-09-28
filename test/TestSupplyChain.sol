pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./BuyerProxy.sol";



contract TestSupplyChain {

    event debug(address _address);

    // we need some ether to give to the buyer
    uint public initialBalance = 10 ether;

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    // buyItem

    // test for failure if user does not send enough funds
    function testNotEnoughFunds() public {

        // create
        SupplyChain supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        supplyChain.addItem('violao', 1);

        //create proxy contract to act as buyer and send it some ether
        BuyerProxy  buyerProxy = new BuyerProxy(address(supplyChain));
        address(buyerProxy).transfer(3 ether);

        // test for purchasing an item that is not for Sale
        bool result;
        result = buyerProxy.buyItem.gas(200000)(abi.encodeWithSignature("buytem(uint256)", 0));

        // string memory name; 
        // uint sku;
        // uint price;
        // uint state;
        // address seller;
        // address buyer;

        // (name, sku, price, state, seller, buyer) = supplyChain.fetchItem(0);

        // emit debug(buyer);

        Assert.isTrue(result, "buy item should work");

    }

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}
