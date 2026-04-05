public class OrderEmailSender {
    public static void sendOrderEmail(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }
        List<AgriEdge_Order__c> orders = [
            SELECT Id, Name, Total_Amount__c, Payment_Status__c, Order_Status__c, 
                   Customer__c, CreatedDate, Shipping_Address__c, Discounted_Total__c
            FROM AgriEdge_Order__c
            WHERE Id IN :orderIds
        ];
        Set<Id> accountIds = new Set<Id>();
        for (AgriEdge_Order__c order : orders) {
            if (order.Customer__c != null) {
                accountIds.add(order.Customer__c);
            }
        }
        Map<Id, List<String>> accountEmails = new Map<Id, List<String>>();
        for (Contact contact : [
            SELECT Email, AccountId FROM Contact 
            WHERE AccountId IN :accountIds AND Email != null
        ]) {
            if (!accountEmails.containsKey(contact.AccountId)) {
                accountEmails.put(contact.AccountId, new List<String>());
            }
            accountEmails.get(contact.AccountId).add(contact.Email);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (AgriEdge_Order__c order : orders) {
            if (accountEmails.containsKey(order.Customer__c)) {

                String body = 'Dear Customer,<br/><br/>'
                    + 'Your order has been updated:<br/><br/>'
                    + '<b>Order:</b> ' + order.Name + '<br/>'
                    + '<b>Status:</b> ' + order.Order_Status__c + '<br/>'
                    + '<b>Total:</b> ' + order.Total_Amount__c + '<br/>'
                    + '<b>Payment:</b> ' + order.Payment_Status__c + '<br/>'
                    + '<b>Address:</b> ' + order.Shipping_Address__c + '<br/><br/>'
                    + 'Thank you!';

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(accountEmails.get(order.Customer__c));
                mail.setSubject('Order Update');
                mail.setHtmlBody(body);

                emails.add(mail);
            }
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
