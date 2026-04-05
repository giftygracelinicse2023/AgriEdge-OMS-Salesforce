trigger OrderItemTrigger on AgriEdge_OrderItem__c (after insert, after update) {
    Set<Id> ids = new Set<Id>();
    for (AgriEdge_OrderItem__c i : Trigger.new) {
        if (i.AgriEdge_Order__c != null) {
            ids.add(i.AgriEdge_Order__c);
        }
    }
    if (!ids.isEmpty()) {
        OrderStatusUpdater.updateOrderStatus(ids);
        OrderTotalUpdater.updateOrderTotal(ids);
    }
}
