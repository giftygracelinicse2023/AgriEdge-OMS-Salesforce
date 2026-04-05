public with sharing class OrderTaskCreator {
    @InvocableMethod
    public static void createTaskForNewOrder(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) return;
        List<User> platformUsers = [SELECT Id FROM User WHERE Profile.Name = 'Platform 1' LIMIT 10];
        if (platformUsers.isEmpty()) return;
        List<Task> tasks = new List<Task>();
        for (Id orderId : orderIds) {
            for (User user : platformUsers) {
                tasks.add(new Task(
                    Subject = 'New Order Created',
                    Description = 'Create Order Item record',
                    WhatId = orderId,
                    OwnerId = user.Id,
                    Status = 'Not Started',
                    Priority = 'High'
                ));
            }
        }
        if (!tasks.isEmpty()) insert tasks;
    }
}
