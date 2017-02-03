/**
 * Description: This is a batch class that identifies dup accounts and merge them
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      11/21/2016                   1.0      Initial Draft
 * Siddharth Pandit      12/24/2017                   1.1      Clean the code, remove debugs
 * Liquid Planner: /space/118974/projects/show/30837040
 * Copyright © Peruto Solutions Inc.
 **/
global with sharing class MergeRecordsBatch implements Database.Batchable<Sobject>, 
                                                       Database.Stateful, Schedulable {
    private List<String> removeSobjList;
    private static Messaging.SingleEmailMessage message;
    private String removeEmails;
    global Database.Querylocator start(Database.BatchableContext BC) {
        removeSobjList = new List<String> ();
        removeEmails = '';
        Integer maxRows = Test.isRunningTest() ? 10 : 50000000;
        return Database.getQueryLocator([ SELECT Id, Email
                                            FROM Lead
                                            WHERE Email <> null
                                            ORDER BY Email
                                            LIMIT :maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
       Set<String> emailExistSet = new Set<String> ();
       for (Lead leadInstance : (List<Lead>) scope ) {
            emailExistSet.add (leadInstance.Email);
       }
       removeEmails += MergeRecordsUtil.mergeRecords (emailExistSet);
       System.debug ('removeEmails ==> '+removeEmails);
    }

    global void finish(Database.BatchableContext BC) {
        if (String.isNotBlank (removeEmails))
            MergeRecordsUtil.sendEmail (removeEmails);
    }

    global void execute(SchedulableContext SC) {
        MergeRecordsBatch mergeRecs = new MergeRecordsBatch();
        Id batchprocessid = Database.executeBatch(mergeRecs, 200);
    }
}