/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestMergeRecordsBatch {

    static testMethod void coverMergeRecordsBath() {
        // create test records
        List<Relationship_Obj__c> custSettingData = new List<Relationship_Obj__c> ();
        Relationship_Obj__c relObj = new Relationship_Obj__c (Name = 'Attachment',
                                                            Relationship_Name__c = 'ParentId');
        custSettingData.add (relObj);
        Relationship_Obj__c relObj2 = new Relationship_Obj__c (Name = 'Task',
                                                            Relationship_Name__c = 'WhoId');
        custSettingData.add (relObj2);
        insert custSettingData;
        Lead newLead = new Lead (LastName = 'test', Email ='test@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No', 
                                Message__c = 'test1', mkto2__Lead_Score__c = 3);
        insert newLead;
        Task task = new Task (Subject = 'Test Sub', Priority = 'Medium', WhoId = newLead.Id);
        insert task;

        Attachment attach = new Attachment ();
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = newLead.id;
        insert attach;

        Lead newLead2 = new Lead (LastName = 'test2', Email ='test@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No',
                                Message__c = 'test2', mkto2__Lead_Score__c = 6);
        insert newLead2;

        Lead newLead15 = new Lead (LastName = 'test15', Email ='test@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes',
                                Message__c = 'test15', mkto2__Lead_Score__c = 9);
        insert newLead15;

        Lead newLead16 = new Lead (LastName = 'test16', Email ='test@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes',
                                Message__c = 'test16', mkto2__Lead_Score__c = 6);
        insert newLead16;

        Lead newLead3 = new Lead (LastName = 'test3', Email ='test1@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'No',
                                Message__c = 'test3', mkto2__Lead_Score__c = 5);
        insert newLead3;

        Lead newLead4 = new Lead (LastName = 'test4', Email ='test1@perkuto.com', Company = 'Test',
                                ResellerID__c = 2, ActiveAccount__c = 'Yes',
                                Message__c = 'test4', mkto2__Lead_Score__c = 4);
        insert newLead4;

        Lead newLead5 = new Lead (LastName = 'test5', Email ='test2@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes',
                                Message__c = 'test5', mkto2__Lead_Score__c = 4);
        insert newLead5;

        Lead newLead6 = new Lead (LastName = 'test6', Email ='test2@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No',
                                Message__c = 'test6', mkto2__Lead_Score__c = 4);
        insert newLead6;

        Lead newLead7 = new Lead (LastName = 'test7', Email ='test3@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'Yes',
                                Message__c = 'test7', mkto2__Lead_Score__c = 4);
        insert newLead7;

        Lead newLead8 = new Lead (LastName = 'test8', Email ='test3@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No',
                                Message__c = 'test8', mkto2__Lead_Score__c = 4);
        insert newLead8;

        Lead newLead9 = new Lead (LastName = 'test9', Email ='test4@perkuto.com', Company = 'Test',
                                ResellerID__c = 577, ActiveAccount__c = 'Yes',
                                Message__c = 'test9', mkto2__Lead_Score__c = 4);
        insert newLead9;

        Lead newLead10 = new Lead (LastName = 'test10', Email ='test4@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'No',
                                Message__c = 'test10', mkto2__Lead_Score__c = 4);
        insert newLead10;

        Lead newLead11 = new Lead (LastName = 'test11', Email ='test5@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'Yes',
                                Message__c = 'test11', mkto2__Lead_Score__c = 4);
        insert newLead11;

        Lead newLead12 = new Lead (LastName = 'test12', Email ='test5@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'No',
                                Message__c = 'test12', mkto2__Lead_Score__c = 5);
        insert newLead12;

        Lead newLead13 = new Lead (LastName = 'test13', Email ='test6@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes',
                                Message__c = 'test13', mkto2__Lead_Score__c = 4);
        insert newLead13;

        Lead newLead14 = new Lead (LastName = 'test14', Email ='test6@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No',
                                Message__c = 'test14', mkto2__Lead_Score__c = 5);
        insert newLead14;

        Test.startTest();
            MergeRecordsBatch mergeRecords = new MergeRecordsBatch ();
            string schTime = '0 0 * * 1-12 ? *';
            system.schedule('mergeRecords', schTime, mergeRecords);
            Id batchprocessid = Database.executeBatch (mergeRecords, 200);
        Test.stopTest();
            for (Lead leadInstance : [SELECT Id, Message__c FROM Lead]) {
                if (leadInstance.Id.equals (newLead4.Id))
                    System.assertEquals ('test4//test3', leadInstance.Message__c);
                if (leadInstance.Id.equals (newLead8.Id))
                    System.assertEquals ('test8//test7', leadInstance.Message__c);
                if (leadInstance.Id.equals (newLead8.Id))
                    System.assertEquals ('test8//test7', leadInstance.Message__c);
            }
    }
}