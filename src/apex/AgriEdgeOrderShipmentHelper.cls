public class AgriEdgeOrderShipmentHelper {
    public static void processOrderStatusChange(List<AgriEdge_Order__c> orders) {
        List<AgriEdge_Shipment__c> insertList = new List<AgriEdge_Shipment__c>();
        List<AgriEdge_Shipment__c> updateList = new List<AgriEdge_Shipment__c>();

        Set<Id> ids = new Set<Id>();
        for (AgriEdge_Order__c o : orders) {
            ids.add(o.Id);
        }
        Map<Id, AgriEdge_Shipment__c> existing = new Map<Id, AgriEdge_Shipment__c>();
        for (AgriEdge_Shipment__c s : [
            SELECT Id, AgriEdge_Order__c, Status__c
            FROM AgriEdge_Shipment__c
            WHERE AgriEdge_Order__c IN :ids
        ]) {
            existing.put(s.AgriEdge_Order__c, s);
        }
        for (AgriEdge_Order__c o : orders) {
            if (o.Order_Status__c == 'Processing' && !existing.containsKey(o.Id)) {
                insertList.add(new AgriEdge_Shipment__c(
                    AgriEdge_Order__c = o.Id,
                    Tracking_Number__c = 'TRK_' + o.Id,
                    Status__c = 'Pending'
                ));
            }
            if ((o.Order_Status__c == 'Shipped' || o.Order_Status__c == 'Delivered')
                && existing.containsKey(o.Id)) {

                AgriEdge_Shipment__c s = existing.get(o.Id);
                s.Status__c = (o.Order_Status__c == 'Shipped') ? 'In Transit' : 'Delivered';
                updateList.add(s);
            }
        }
        if (!insertList.isEmpty()) insert insertList;
        if (!updateList.isEmpty()) update updateList;
    }
}
