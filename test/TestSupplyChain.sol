pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./AccountProxy.sol";


contract TestSupplyChain {

    event debug(address _address);
    
    uint public initialBalance = 10 ether;
    AccountProxy sellerProxy;
    AccountProxy buyerProxy;
    SupplyChain supplyChainContract;
    uint testSku;
    uint constant testItemPrice = 10;

    function beforeAll() public {
        // deploy supplyChain contract
        supplyChainContract = SupplyChain(DeployedAddresses.SupplyChain());

        // create proxy contract to act as seller and add an item to sell at sku 0
        sellerProxy = new AccountProxy(address(supplyChainContract));
        sellerProxy.callTargetContract(abi.encodeWithSignature("addItem(string,uint256)", "guitar", testItemPrice), 0);
        testSku = 0;

        // create proxy contract to act as buyer and send it some ether
        buyerProxy = new AccountProxy(address(supplyChainContract));
        address(buyerProxy).transfer(1 ether);
    }

    // buyItem

    // test for failure if user does not send enough funds
    function testNotEnoughFundsMustRevert() public {

        uint lowerBuyValue = testItemPrice - 2;

        // try to buy sending less wei than the item price
        bool result;
        result = buyerProxy.callTargetContract(abi.encodeWithSignature("buyItem(uint256)", testSku), lowerBuyValue);
        Assert.isFalse(result, "buy item with not enough funds should not work");

    }

    // test for purchasing an item that is not for Sale
    function testPurchaseNotForSaleMustRevert() public {

        uint nonExistentSku = 100;
        bool result;

        //try to buy item not yet added
        result = buyerProxy.callTargetContract(abi.encodeWithSignature("buyItem(uint256)", nonExistentSku), testItemPrice);
        Assert.isFalse(result, "Buy non added item should not work");

    }

    // shipItem

    // test for trying to ship an item that is not marked Sold
    function testShipItemNotSold() public {

        bool result;

        // Seller cannot ship if not sold
        result = sellerProxy.callTargetContract(abi.encodeWithSignature("shipItem(uint256)", testSku), 0);
        Assert.isFalse(result, "Can't ship item not yet sold");
        
    }

    // test for calls that are made by not the seller
    function testOnlySellerCanShip() public {

        bool result;

        // create proxy contract to act as an account that is different from the seller
        AccountProxy accountProxy = new AccountProxy(address(supplyChainContract));

        // Buy the test item
        result = buyerProxy.callTargetContract(abi.encodeWithSignature("buyItem(uint256)", testSku), testItemPrice);
        Assert.isTrue(result, "buy item with enough funds should work");

        // non seller account tries to ship and should fail
        result = accountProxy.callTargetContract(abi.encodeWithSignature("shipItem(uint256)", testSku), 0);
        Assert.isFalse(result, "Only seller can ship");

    }

    // receiveItem

    // test trying to rececive an item not yet Shipped
    function testReceiveNonShippedMustFail() public {
        bool result;

        // Receive the test item before shiping
        result = buyerProxy.callTargetContract(abi.encodeWithSignature("receiveItem(uint256)", testSku), 0);
        Assert.isFalse(result, "Can't receive item not yet shipped");

    }

    // test calling the function from an address that is not the buyer
    function testOnlyBuyerCanReceive() public {
        bool result;

        // Ship the item
        result = sellerProxy.callTargetContract(abi.encodeWithSignature("shipItem(uint256)", testSku), 0);
        Assert.isTrue(result, "Seller ships an sold item must work");

        // create proxy contract to act as an account that is different from the buyer
        AccountProxy accountProxy = new AccountProxy(address(supplyChainContract));

        result = accountProxy.callTargetContract(abi.encodeWithSignature("receiveItem(uint256)", testSku), 0);
        Assert.isFalse(result, "Only buyer can receive");

        result = accountProxy.callTargetContract(abi.encodeWithSignature("receiveItem(uint256)", testSku), 0);
        Assert.isFalse(result, "Buyer must be able to receive shipped item");

    }

}
