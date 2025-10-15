trigger AccountTrigger on Account (before insert, before update, after insert) {

    // Example 1: Before Insert or Update → Mark High-Value Accounts
    if (Trigger.isBefore) {
        for (Account acc : Trigger.new) {
            
            // Example condition: if Annual Revenue > 5 Million
            if (acc.AnnualRevenue != null && acc.AnnualRevenue > 5000000) {
                acc.Description = 'High-Value Account';
                acc.Rating = 'Hot';
            } else {
                acc.Description = 'Regular Account';
                acc.Rating = 'Warm';
            }

            // Example: Auto-set Industry if blank
            if (String.isBlank(acc.Industry)) {
                acc.Industry = 'Not Specified';
            }
        }
    }

    // Example 2: After Insert → Create a related Task for Account Manager
    if (Trigger.isAfter && Trigger.isInsert) {
        List<Task> taskList = new List<Task>();

        for (Account acc : Trigger.new) {
            if (acc.AnnualRevenue != null && acc.AnnualRevenue > 5000000) {
                Task t = new Task(
                    WhatId = acc.Id,
                    Subject = 'Welcome Call for High-Value Account',
                    Description = 'Reach out to the new high-value customer.',
                    Status = 'Not Started',
                    Priority = 'High',
                    OwnerId = acc.OwnerId,
                    ActivityDate = Date.today().addDays(1)
                );
                taskList.add(t);
            }
        }

        if (!taskList.isEmpty()) {
            insert taskList;
        }
    }
}