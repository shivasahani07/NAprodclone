@isTest
private class lwc_Handledocuments_ControllerTest {
    
    @isTest
    static void testGetDocumentHandler() {
        Process_Task_Detail__c testPTD =TestUtility.createPTDinstance();
        insert testPTD;
        Process_Path__c  testPP=TestUtility.createProcessPAthInstance();
        insert	testPP;
        Process_Path_Task_Detail__c  testPPTD=TestUtility.createPPTD();
        testPPTD.Process_Path__c=testPP.id;
        testPPTD.Business_Step_No__c=3;
        testPPTD.Execution_Serial_No__c='4';
        testPPTD.Task_Owner_Type__c='System';
        testPPTD.Task_Owner_Name__c='Test Task Owner';
        testPPTD.Process_Task_Detail__c=testPTD.id;
        insert testPPTD;	
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask;
        
        // Call the method to test
        lwc_Handledocuments_Controller.wrapperHandler result = lwc_Handledocuments_Controller.getDocumentHandler(testTask.Id, 'ExtendedSObjectRecordId','documentsharingTaskId');
        
        // Perform assertions
        //System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUpsertDocumentHandler() {
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        // Call the method to test
        List<Document_Handler__c> result = lwc_Handledocuments_Controller.UpsertDocumentHandler(new List<Document_Handler__c>{testDH}, 'Insert/UpsertDocHandler');
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testInsertTaskforReview() {
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        // Call the method to test
        Document_Handler__c result = lwc_Handledocuments_Controller.insertTaskforReview(testDH);
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUploadFile() {
        // Call the method to test
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        
        lwc_Handledocuments_Controller.UploadWrapper result = lwc_Handledocuments_Controller.uploadFile('base64String', 'testFile.txt',testDH.id,'uploadedTaskId');
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUpdateDhStatus() {
       
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        //testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask;
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        // Call the update_dh_status method with the test records
        lwc_Handledocuments_Controller.deviation_reviewer_wrapper result = lwc_Handledocuments_Controller.update_dh_status(testDH, testTask.Id, 'Completed');
        
        // Retrieve the updated records
        Document_Handler__c updatedDhRecord = [SELECT Id, Status__c FROM Document_Handler__c WHERE Id = :testDH.Id LIMIT 1];
        Task updatedTaskRecord = [SELECT Id, Status FROM Task WHERE Id = :testTask.Id LIMIT 1];
        
        // Assert that the records were updated as expected
        
    }
    
    @isTest
    static void testUpsertDocHandlerCreateDeviation() {
        // Create a test Process_Attribute_Dcoument_Detail__c record
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Process_Attribute_Dcoument_Detail__c testPADD = new Process_Attribute_Dcoument_Detail__c();
        testPADD.Document_Metadata__c=testDMD.id;
        testPADD.Deviation_Approver_Type__c='User';
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        testDH.Process_Attribute_Dcoument_Detail__c=testPADD.id;
        testDH.Status__c='Submitted for Deviation Approval';
        insert testDH;
        lwc_Handledocuments_Controller.upsertDocHandler_CreateDeviation(new List<Document_Handler__c>{testDH});
        
        // Retrieve the updated records
        Document_Handler__c updatedDHRecord = [SELECT Id, Status__c FROM Document_Handler__c WHERE Id = :testDH.Id LIMIT 1];
        // Task updatedTaskRecord = [SELECT Id, Status FROM Task WHERE Review_Record_Id__c = :testDH.Id LIMIT 1];
        
        
    }
    
}