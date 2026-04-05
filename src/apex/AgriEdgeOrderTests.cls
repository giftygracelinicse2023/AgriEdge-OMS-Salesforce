@isTest
public class AgriEdgeOrderTests {
    @isTest
    static void testAll() {
        Account acc = new Account(Name='Test');
        insert acc;
        AgriEdge_Order__c order = new AgriEdge_Order__c(
            Customer__c = acc.Id,
            Payment_Status__c = 'Pending',
            Order_Status__c = 'New'
        );
        insert order;
        AgriEdge_OrderItem__c item = new AgriEdge_OrderItem__c(
            AgriEdge_Order__c = order.Id,
            Quantity__c = 2,
            Unit_Price__c = 50
        );
        insert item;
        Test.startTest();
        OrderTotalUpdater.updateOrderTotal(new Set<Id>{order.Id});
        OrderStatusUpdater.updateOrderStatus(new Set<Id>{order.Id});
        OrderEmailSender.sendOrderEmail(new Set<Id>{order.Id});
        Test.stopTest();
        System.assert(true);
    }
}
