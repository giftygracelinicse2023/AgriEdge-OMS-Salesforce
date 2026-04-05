public class OrderStatusUpdater {
    public static void updateOrderStatus(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) return;
        List<AgriEdge_Order__c> orders = [
            SELECT Id, Order_Status__c
            FROM AgriEdge_Order__c
            WHERE Id IN :orderIds AND Order_Status__c = 'New'
        ];
        for (AgriEdge_Order__c o : orders) {
            o.Order_Status__c = 'Processing';
        }
        if (!orders.isEmpty()) update orders;
    }
}
