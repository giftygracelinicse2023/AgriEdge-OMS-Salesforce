trigger AgriEdgeOrderTrigger on AgriEdge_Order__c (after insert, after update) {
    if (AgriEdgeOrderTriggerHelper.isTriggerExecuted) return;
    AgriEdgeOrderTriggerHelper.isTriggerExecuted = true;
    List<AgriEdge_Order__c> listOrders = new List<AgriEdge_Order__c>();
    List<AgriEdge_Order__c> updates = new List<AgriEdge_Order__c>();
    List<Id> failed = new List<Id>();

    for (AgriEdge_Order__c o : Trigger.new) {
        AgriEdge_Order__c old = Trigger.isUpdate ? Trigger.oldMap.get(o.Id) : null;
        Boolean changed = (old == null || 
                          o.Payment_Status__c != old.Payment_Status__c || 
                          o.Order_Status__c != old.Order_Status__c);
        if (changed) listOrders.add(o);
        if (o.Payment_Status__c == 'Pending') {
            updates.add(new AgriEdge_Order__c(Id=o.Id, Order_Status__c='Processing'));
        }
        if (o.Payment_Status__c == 'Failed') {
            updates.add(new AgriEdge_Order__c(Id=o.Id, Order_Status__c='Canceled'));
            failed.add(o.Id);
        }
    }
    if (!updates.isEmpty()) update updates;
    if (!failed.isEmpty()) {
        delete [SELECT Id FROM AgriEdge_OrderItem__c WHERE AgriEdge_Order__c IN :failed];
        delete [SELECT Id FROM AgriEdge_Shipment__c WHERE AgriEdge_Order__c IN :failed];
    }
    if (!listOrders.isEmpty()) {
        AgriEdgeOrderShipmentHelper.processOrderStatusChange(listOrders);
    }
    AgriEdgeOrderTriggerHelper.isTriggerExecuted = false;
}
