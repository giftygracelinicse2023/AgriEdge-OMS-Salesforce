trigger OrderPaymentStatusTriggers on AgriEdge_Order__c (after update) {
    Set<Id> ids = new Set<Id>();
    for (AgriEdge_Order__c o : Trigger.new) {
        AgriEdge_Order__c old = Trigger.oldMap.get(o.Id);
        if (old.Payment_Status__c != 'Paid' 
            && o.Payment_Status__c == 'Paid' 
            && o.Customer__c != null) {
            ids.add(o.Id);
        }
    }
    if (!ids.isEmpty()) {
        OrderEmailSender.sendOrderEmail(ids);
    }
}
