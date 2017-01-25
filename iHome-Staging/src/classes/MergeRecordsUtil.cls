/**
 * Description: This is a utility class that contains methods used in MergeRecordsBatch
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      11/21/2016                   1.0      Initial Draft
 * Siddharth Pandit      12/24/2017                   1.1      Clean the code, remove debugs
                                                               added additional logic to exclude
                                                               leads from the process
 * Liquid Planner: /space/118974/projects/show/30837040
 * Copyright © Peruto Solutions Inc.
 **/
public with sharing class MergeRecordsUtil {
    private static final String STR_SELECT = 'Select';
    private static final String STR_SPACE = ' ';
    private static final String STR_INIT = '';
    private static final String STR_COMMA = ',';
    private static final String STR_LEAD = 'Lead';
    private static final String STR_CONTACT = 'Contact';
    private static final String STR_FROM = 'FROM';
    private static final String STR_ID = 'Id';
    private static final String STR_WHERE = 'WHERE';
    private static final String STR_COLON = ':';
    private static final String STR_EMAIL = 'Email';
    private static final String STR_Name = 'Name';
    private static final String STR_BODY = 'Body';
    private static final String STR_NEWLINE = '\n';
    private static final String STR_RID = 'ResellerID__c';
    private static final String STR_ACCACTIVE = 'ActiveAccount__c';
    private static final String STR_CLIENTID = 'ClientID__c';
    private static final String STR_ATTACHMENT = 'Attachment';
    private static final String STR_CONTDOCLINK = 'ContentDocumentLink';
    private static final String STR_LEADHISTORY = 'LeadHistory';
    private static final String STR_MSG = 'Message__c';
    private static final String STR_FIVEONEONE = '511';
    private static final String STR_FIVESEVENSEVEN = '577';
    private static final String STR_SEVENTWOFIVE = '725';
    private static final String STR_TWO = '2';
    private static final String STR_NO = 'no';
    private static final String STR_LEADSCORE = 'mkto2__Lead_Score__c';
    private static final String STR_MASTER = 'master';
    private static final String STR_DUP = 'dup';
    private static final String STR_YES = 'yes';
    private static final String STR_IN = 'IN';
    private static final String STR_PARENTID = 'ParentId';
    private static final String STR_CONTDOCID = 'ContentDocumentId';
    private static final String STR_SEPARATE = '//';
    private static Map<String, Sobject> masterObjTempMap;
    private static final String STR_CREATEDDATE = 'CreatedDate';
    private static final String STR_ORDERBY = 'ORDER BY';
    private static final String STR_DESC = 'DESC';
    private static final String STR_CONVERTEDFILTER = ' AND IsConverted = false';
    private static Boolean flag = false;
    private static String affPrtnrSts ='Affiliate_Partner_Status__c';
    private static String mslPrtnrSts ='MLS_Partner_Status__c';
    private static String resPrtnrSts ='Reseller_Partner_Status__c';
    private static String STR_NONE = 'None';

    // A method that returns query on lead
    public static String retrieveLeadQuery (Set<String> existEmailSet) {
        String queryStr = STR_SELECT + STR_SPACE;
        for (Schema.FieldSetMember field : getLeadFields ()) {
            queryStr += field.getFieldPath() + STR_COMMA + STR_SPACE;
        }
        queryStr += STR_ID + STR_SPACE + STR_FROM + STR_SPACE + STR_LEAD + STR_SPACE +
                    STR_WHERE + STR_SPACE + STR_EMAIL + STR_SPACE + STR_IN + STR_COLON +
                    'existEmailSet'+ STR_CONVERTEDFILTER + STR_SPACE+ STR_ORDERBY+ STR_SPACE+
                    STR_CREATEDDATE+ STR_SPACE+ STR_DESC;
        return queryStr;
    } // End method

    // A method that calls the custom setting for lead fields
    public static List<Schema.FieldSetMember> getLeadFields() {
        return SObjectType.Lead.FieldSets.MergeLeadFields.getFields();
    }

    // A method that returns list of matching records
    private static List<Sobject> fetchMatchingRecords (Set<String> existEmailSet) {
        return Database.query (retrieveLeadQuery (existEmailSet));
    }

    // A method that validates if ACC Active value is same in both the accounts or not
    private static Boolean difAccActiveVal (Sobject prevObj, Sobject newObj) {
        return (!String.valueOf (newObj.get (STR_ACCACTIVE))
                .equalsIgnoreCase (String.valueOf (prevObj.get (STR_ACCACTIVE))));
    } // End method

    // Following methods are to check RID and Account Active field
    public static Boolean compareLeadScore (Sobject prevObj, Sobject newObj) {
        Integer prevObjScore = prevObj.get (STR_LEADSCORE) != null ?
                               Integer.valueOf (prevObj.get (STR_LEADSCORE)) : 0;
        Integer newObjScore = newObj.get (STR_LEADSCORE) != null ?
                              Integer.valueOf (newObj.get (STR_LEADSCORE)) : 0;
        if (prevObjScore == newObjScore)
            return (Datetime.valueOf (prevObj.get (STR_CREATEDDATE)) > 
                    Datetime.valueOf (newObj.get (STR_CREATEDDATE)));
        return (prevObjScore > newObjScore);
    }

    private static Boolean checkAccActiveYes (Sobject objInstance) {
        return STR_YES.equalsIgnoreCase (String.valueOf (objInstance.get (STR_ACCACTIVE)));
    }

    private static Boolean checkRIDFiveSevenSeven (Sobject objInstance) {
        return STR_FIVESEVENSEVEN.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    private static Boolean checkRIDFiveOneOne (Sobject objInstance) {
        return STR_FIVEONEONE.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    private static Boolean checkRIDSevenTwoFive (Sobject objInstance) {
        return STR_SEVENTWOFIVE.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    private static Boolean checkRIDTwo (Sobject objInstance) {
        return STR_TWO.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    // A method that returns a map of two records master and duplicate
    private static Map<String, Sobject> checkRIDForPaids (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> objTypeMap = new Map<String, Sobject> ();
        if (checkRIDFiveOneOne (prevObj) && !checkRIDTwo (newObj) &&
            !checkRIDSevenTwoFive (newObj) && !checkRIDFiveSevenSeven (newObj) &&
            !checkRIDFiveOneOne (newObj)) {
            objTypeMap.put (STR_MASTER, prevObj);
            objTypeMap.put (STR_DUP, newObj);
        } else
        if (checkRIDFiveOneOne (newObj) && !checkRIDTwo (prevObj) &&
            !checkRIDSevenTwoFive (prevObj) && !checkRIDFiveSevenSeven (prevObj) &&
            !checkRIDFiveOneOne (prevObj)) {
            objTypeMap.put (STR_MASTER, newObj);
            objTypeMap.put (STR_DUP, prevObj);
        }
        return objTypeMap;
    }

    // A method to validate none of the records paid
    private static Map<String, Sobject> checkNoPaidRID (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> objTypeMap = new Map<String, Sobject> ();
        if ((checkRIDTwo (prevObj) || checkRIDSevenTwoFive (prevObj) ||
            checkRIDFiveSevenSeven (prevObj)) && !checkRIDTwo (newObj) && 
            !checkRIDSevenTwoFive (newObj) && !checkRIDFiveSevenSeven (newObj) &&
            !checkAccActiveYes (newObj)) {
            objTypeMap.put (STR_MASTER, prevObj);
            objTypeMap.put (STR_DUP, newObj);
        } else
        if ((checkRIDTwo (newObj) || checkRIDSevenTwoFive (newObj) ||
            checkRIDFiveSevenSeven (newObj)) && !checkRIDTwo (prevObj) && 
            !checkRIDSevenTwoFive (prevObj) && !checkRIDFiveSevenSeven (prevObj) &&
            !checkAccActiveYes (prevObj)) {
            objTypeMap.put (STR_MASTER, newObj);
            objTypeMap.put (STR_DUP, prevObj);
        }
        return objTypeMap;
    }

    // A method that returns a map of two records with higher lead score as master
    private static Map<String, Sobject> getHigherLeadScore (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> sobjMap = new Map<String, Sobject> ();
        if (compareLeadScore (prevObj, newObj)) {
            sobjMap.put (STR_MASTER, prevObj); 
            sobjMap.put (STR_DUP, newObj);
        } else
        if (compareLeadScore (newObj, prevObj)) {
            sobjMap.put (STR_MASTER, newObj); 
            sobjMap.put (STR_DUP, prevObj);
        }
        return sobjMap;
    }

    // A method that merges a non active lead to the lead with high score when multiple actives
    private static Sobject mergeWithHighScore (Sobject objInstance) {
        Sobject leadWithHighScore = objInstance;
        if (!masterObjTempMap.containsKey (String.valueOf (objInstance.get (STR_EMAIL))))
            masterObjTempMap.put (String.valueOf (objInstance.get (STR_EMAIL)), objInstance);
        else {
            Sobject prevInstance =
                    masterObjTempMap.get (String.valueOf (objInstance.get (STR_EMAIL)));
            if (!String.valueOf (prevInstance.get (STR_ID))
                .equals (String.valueOf (objInstance.get (STR_ID))) &&
            compareLeadScore (prevInstance, objInstance)) {
                leadWithHighScore = prevInstance;
            } else {
                masterObjTempMap.put (String.valueOf (objInstance.get (STR_EMAIL)),
                                        objInstance);
            }
        }
        return leadWithHighScore;
     }

    // A method that returns a map of two records master and duplicate
    private static Map<String, Sobject> checkRIDwithAccActive (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> sobjMap = new Map<String, Sobject> ();
        if (checkRIDFiveOneOne (prevObj) && checkRIDFiveOneOne (newObj)) {
            if (checkAccActiveYes (prevObj) && checkAccActiveYes (newObj))
                return null;
            if (difAccActiveVal (prevObj, newObj)) {
                flag = true;
                if (checkAccActiveYes (newObj)) {
                    sobjMap.put (STR_MASTER, newObj); 
                    sobjMap.put (STR_DUP, prevObj);
                } else {
                    sobjMap.put (STR_MASTER, prevObj); 
                    sobjMap.put (STR_DUP, newObj);
                }
            } else {
                sobjMap = getHigherLeadScore (prevObj, newObj);
            }
        }
        System.debug ('sobjMap ==> '+sobjMap);
        return sobjMap;
    } // End method

    // A method that would check the RID is null and make high lead score as master
    private static Map<String, Sobject> mergeNonActiveRecs (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> sobjMap = new Map<String, Sobject> ();
        if (!checkRIDFiveOneOne (prevObj) && !checkRIDFiveOneOne (newObj) &&
            !checkRIDSevenTwoFive (prevObj) && !checkRIDSevenTwoFive (newObj) &&
            !checkRIDFiveSevenSeven (prevObj) && !checkRIDFiveSevenSeven (newObj) &&
            !checkRIDTwo (prevObj) && !checkRIDTwo (newObj)) {
             sobjMap = getHigherLeadScore (prevObj, newObj);
        }
        return sobjMap;
    }

    // A method that replaces Master Lead with higher lead score when multiple active leads
    private static Sobject mergeHighScoreLead (Sobject objInstance) {
        if (masterObjTempMap.containsKey (String.valueOf (objInstance.get (STR_EMAIL))))
            return masterObjTempMap.get (String.valueOf (objInstance.get (STR_EMAIL)));
        else
            return objInstance;
    } // End method

    // A method that validates the fields are blank
    private static Boolean doNotMerge (Sobject objInstance) {
        if ((String.isNotBlank (String.valueOf (objInstance.get (affPrtnrSts))) &&
            !STR_NONE.equals (String.valueOf (objInstance.get (affPrtnrSts)))) ||
            (String.isNotBlank (String.valueOf (objInstance.get (mslPrtnrSts))) &&
            !STR_NONE.equals (String.valueOf (objInstance.get (mslPrtnrSts)))) ||
            (String.isNotBlank (String.valueOf (objInstance.get (resPrtnrSts))) &&
            !STR_NONE.equals (String.valueOf (objInstance.get (resPrtnrSts)))))
            return true;
            return false;
    }

    // A method that checks dups and merge them
    public static List<String> mergeRecords (Set<String> emailSet) {
        emailSet.remove (null);
        System.debug ('emailSet ==> '+emailSet);
        List<Sobject> existingObjList = fetchMatchingRecords (emailSet);
        Map<String, Sobject> recIdObjMap = new Map<String, Sobject> ();
        List<String> strListToReturn = new List<String> ();
        Map<String, String> dupIdMasterIdMap = new Map<String, String> ();
        Sobject masterRec, dupRec;
        Map<String, Sobject> masterObjMapToUpdate = new Map<String, Sobject> ();
        masterObjTempMap = new Map<String, Sobject> ();
        List<Sobject> dupObjListToDel = new List<Sobject> ();
        Map<String, String> emailClIdMap = new Map<String, String> ();
        Set<String> doNotDelIdSet = new Set<String> ();
        for (Sobject objInstance : existingObjList) {
            if (checkAccActiveYes (objInstance)) mergeWithHighScore (objInstance);
            if (doNotMerge (objInstance)) doNotDelIdSet.add (objInstance.Id);
            Map<String, Sobject> strSobjMap;
            System.debug ('objInstance ==> '+objInstance);
            if (recIdObjMap.containsKey (String.valueOf (objInstance.get (STR_EMAIL)))) {
                Sobject prevObj = recIdObjMap.get (String.valueOf (objInstance.get (STR_EMAIL)));
                strSobjMap = checkRIDwithAccActive (prevObj, objInstance);
                System.debug ('strSobjMap1 ==> '+strSobjMap);
                if (strSobjMap == null || strSobjMap.isEmpty ()) {
                    strSobjMap = checkRIDForPaids (prevObj, objInstance);
                    flag = strSobjMap.isEmpty();
                    System.debug ('strSobjMap2 ==> '+strSobjMap);
                }
                if (strSobjMap == null || strSobjMap.isEmpty ()) {
                    strSobjMap = checkNoPaidRID (prevObj, objInstance);
                    flag = strSobjMap.isEmpty();
                    System.debug ('strSobjMap3 ==> '+strSobjMap);
                }
                if (strSobjMap == null || strSobjMap.isEmpty ()) {
                    strSobjMap = mergeNonActiveRecs (prevObj, objInstance);
                    flag = strSobjMap.isEmpty();
                    System.debug ('strSobjMap4 ==> '+strSobjMap);
                }
                if (strSobjMap != null && !strSobjMap.isEmpty ()) {
                    masterRec = flag ? mergeHighScoreLead (strSobjMap.get (STR_MASTER)) :
                                strSobjMap.get (STR_MASTER); // Assigning to high score lead
                    dupRec = strSobjMap.get (STR_DUP);
                    System.debug ('masterRec ==> '+masterRec);
                    System.debug ('dupRec ==> '+dupRec);
                    String uniqueKey = String.valueOf (masterRec.get (STR_EMAIL)).toLowerCase();
                    if (!doNotDelIdSet.contains (String.valueOf (dupRec.get (STR_ID)))) {
                        masterObjMapToUpdate.put (uniqueKey, mergeFieldValues (masterRec, dupRec));
                        dupObjListToDel.add (dupRec);
                        strListToReturn.add (String.valueOf (dupRec.get (STR_EMAIL)+ STR_COMMA+ 
                                STR_SPACE+ String.valueOf (dupRec.get (STR_CLIENTID))));
                        dupIdMasterIdMap.put (String.valueOf (dupRec.get (STR_ID)),
                                                String.valueOf (masterRec.get (STR_ID)));
                    }
                }
            }
            else
                recIdObjMap.put (String.valueOf (objInstance.get (STR_EMAIL)), objInstance);
        }
        System.debug ('dupIdMasterIdMap ==> '+dupIdMasterIdMap);
        updateChildren (dupIdMasterIdMap); updateMasterObj (masterObjMapToUpdate);
        deleteDups (dupObjListToDel);
        return strListToReturn;
    } // End method

    // A method that calls another one to update child records
    private static void updateChildren (Map<String, String> dupMasterIdMap) {
        if (!dupMasterIdMap.isEmpty ())
            updateChildRecords (dupMasterIdMap);
    }

    // A method that updates master record
    private static void updateMasterObj (Map<String, Sobject> masterObjMap) {
        if (!masterObjMap.isEmpty ())
            Database.update (masterObjMap.values(), false);
    }

    // A method that deletes dup
    private static void deleteDups (List<Sobject> listDups) {
        if (!listDups.isEmpty ())
            Database.delete (listDups, false);
    }

    // A method to create new attachments, files and history records under master records
    private static void createChildRecords (Map<String, String> dupIdMasterIdMap, String objName,
                                            String relName) {
        List<Sobject> objListToCreate = new List<Sobject> ();
        Set<String> dupIdSet = dupIdMasterIdMap.keySet ();
        String queryStr = retrieveChildQuery (objName, relName) + 'dupIdSet';
        if (STR_ATTACHMENT.equalsIgnoreCase (objName)) {
            for (Attachment attInstance : Database.query (queryStr)) {
                Attachment att = new Attachment (Name = attInstance.Name, Body = attInstance.Body,
                                ParentId = dupIdMasterIdMap.get (attInstance.ParentId));
                objListToCreate.add (att);
            }
        }
        if (STR_CONTDOCLINK.equalsIgnoreCase (objName)) {
            for (ContentDocumentLink conDocLink : Database.query (queryStr)) {
                System.debug ('conDocLink ==> '+conDocLink);
                ContentDocumentLink contDoc = 
                    new ContentDocumentLink (ContentDocumentId = conDocLink.ContentDocumentId, 
                            LinkedEntityId = dupIdMasterIdMap.get (conDocLink.LinkedEntityId));
                objListToCreate.add (contDoc);
            }
        }
        System.debug ('objListToCreate ==> '+objListToCreate);
        if (!objListToCreate.isEmpty ()) insert objListToCreate;
    }

    // A method that returns a query for child objects
    private static String retrieveChildQuery (String objName, String relName) {
        String queryStr = STR_SELECT+ STR_SPACE+ STR_ID+ STR_COMMA+ STR_SPACE+ relName;
        queryStr+= STR_ATTACHMENT.equalsIgnoreCase (objName)? 
                   STR_COMMA+ STR_SPACE+ STR_Name + STR_COMMA+ STR_SPACE+ STR_BODY : '';
        queryStr+= STR_SPACE+ STR_FROM+ STR_SPACE+
                            objName + STR_SPACE + STR_WHERE + STR_SPACE + 
                            relName+ STR_SPACE+ STR_IN + STR_COLON ;
        return queryStr;
    }
    // A method to merge child records
    public static void updateChildRecords (Map<String, String> dupIdMasterIdMap) {
        System.debug ('dupIdMasterIdMap ==> '+dupIdMasterIdMap);
        List<Sobject> objListToUpdate = new List<Sobject> ();
        Set<String> dupIdSet = dupIdMasterIdMap.keySet ();
        for (Relationship_Obj__c relObj : getRelatedObjs ()) {
            if (STR_ATTACHMENT.equalsIgnoreCase (relObj.Name) ||
                STR_CONTDOCLINK.equalsIgnoreCase (relObj.Name)) {// Checking if obj is attachement
                createChildRecords (dupIdMasterIdMap, relObj.Name, relObj.Relationship_Name__c);
                continue;
            } 
            String queryStr = retrieveChildQuery (relObj.Name, relObj.Relationship_Name__c) +
                                'dupIdSet';
            System.debug ('queryStr ==> '+queryStr);
            for (Sobject objInstance : Database.query (queryStr)) {
                String dupKey = String.valueOf (objInstance.get (relObj.Relationship_Name__c));
                objInstance.put (relObj.Relationship_Name__c,
                                dupIdMasterIdMap.get (dupKey));
                objListToUpdate.add (objInstance);
            } // End for
        }
        if (!objListToUpdate.isEmpty ())
            update objListToUpdate;
    }

    // A method that returns custom setting data
    private static List<Relationship_Obj__c> getRelatedObjs () {
        return Relationship_Obj__c.getall().values();
    }

    // A method that merges the nonblank fields based off the master record
    private static Sobject mergeFieldValues (Sobject masterObj, Sobject dupObj) {
        for (Schema.FieldSetMember leadFields : getLeadFields()) {
            String fieldName = leadFields.getFieldPath ();
            if (STR_MSG.equalsIgnoreCase (fieldName) &&
                String.isNotBlank (String.valueOf(dupObj.get (fieldName)))) { // Message field concatenation
                String msg = masterObj.get (fieldName) == null? '': 
                            String.valueOf (masterObj.get (fieldName)) + STR_SEPARATE;
                msg += dupObj.get (fieldName);
                masterObj.put (fieldName, msg);
                continue;
            }
            if (masterObj.get (fieldName) == null && dupObj.get (fieldName) != null)
                masterObj.put (fieldName, dupObj.get (fieldName));
        }
        return masterObj;
    }

    // A method that sends email
    public static void sendEmail (List<String> removedObjList) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // Set recipients to two contact IDs.
        // Replace IDs with valid record IDs in your org.
        String emails = System.Label.MergeRecordsEmail.replaceAll (' ', '');
        List<String> emailList = emails.split (';');
        message.toAddresses = emailList;
        message.optOutPolicy = 'FILTER';
        message.subject = 'List of deleted records in merge';
        message.plainTextBody = System.Label.MergeRecordsMsg+ STR_COLON+ STR_NEWLINE+ STR_NEWLINE;
        message.plainTextBody += 'Email;  ClientId'+ STR_NEWLINE;
        for (String delRecord : removedObjList)
             message.plainTextBody += delRecord + STR_NEWLINE;
        Messaging.SingleEmailMessage[] messages = 
        new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        } 
    }
}