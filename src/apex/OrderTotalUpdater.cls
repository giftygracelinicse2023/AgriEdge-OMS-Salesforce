public class OrderTotalUpdater {
    public static void updateOrderTotal(Set<Id> orderIds) {
        Map<Id, Decimal> totals = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT AgriEdge_Order__c o, SUM(Total_Price__c) t
            FROM AgriEdge_OrderItem__c
            WHERE AgriEdge_Order__c IN :orderIds
            GROUP BY AgriEdge_Order__c
        ]) {
            totals.put((Id)ar.get('o'), (Decimal)ar.get('t'));
        }
        List<AgriEdge_Order__c> orders = [
            SELECT Id, Total_Amount__c, Payment_Status__c
            FROM AgriEdge_Order__c
            WHERE Id IN :orderIds
        ];
        for (AgriEdge_Order__c o : orders) {
            o.Total_Amount__c = totals.containsKey(o.Id) ? totals.get(o.Id) : 0;
            o.Payment_Status__c = (o.Total_Amount__c > 0) ? 'Pending' : 'Paid';
        }
        update orders;
    }
}
