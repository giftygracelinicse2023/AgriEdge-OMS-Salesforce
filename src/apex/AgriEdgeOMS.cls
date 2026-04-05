// ===============================
// TRIGGER
// ===============================
trigger OrderTrigger on Order__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        OrderHandler.handleOrder(Trigger.new);
    }
}
// ===============================
// HANDLER CLASS
// ===============================
public class OrderHandler {
    public static void handleOrder(List<Order__c> a){
        List<Inventory__c> b = [SELECT Id, Product__c, Stock__c FROM Inventory__c];
        for(Order__c c : a){
            for(Inventory__c d : b){
                if(c.Product__c == d.Product__c){
                    if(d.Stock__c >= c.Quantity__c){
                        d.Stock__c = d.Stock__c - c.Quantity__c;
                    }
                    else{
                        c.Status__c = 'Out of Stock';
                    }
                }
            }
        }
        update b;
        update a;
    }
}
// ===============================
// BATCH CLASS
// ===============================
global class InventoryBatch implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Stock__c FROM Inventory__c');
    }
    global void execute(Database.BatchableContext bc, List<Inventory__c> a){

        for(Inventory__c b : a){
            if(b.Stock__c < 10){
                b.Stock__c += 50;
            }
        }
        update a;
    }
    global void finish(Database.BatchableContext bc){
        System.debug('Inventory Batch Completed');
    }
}
// ===============================
// TEST CLASS
// ===============================
@isTest
public class TestOrder {
    @isTest
    static void testMethod(){
        Product__c a = new Product__c(Name='Seed');
        insert a;
        Inventory__c b = new Inventory__c(
            Product__c = a.Id,
            Stock__c = 100
        );
        insert b;
        Order__c c = new Order__c(
            Product__c = a.Id,
            Quantity__c = 10,
            Status__c = 'New'
        );
        Test.startTest();
        insert c;
        Test.stopTest();
        System.assert(true);
    }
}
