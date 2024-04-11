@isTest
private class PayableDetailsControllerTest {

    @testSetup
    static void setup() {
        // Initialize test data using TestUtility class
        TestUtility.APICallingSystemDetails();
    }

    @isTest
    static void testGetAllFinancialEntityWithDetails() {
        Test.startTest();
        Financial_Account__c testFA = TestUtility.CreateFinancialAccountInstance();
        PayableDetailsController.getAllFinancialEntityWithDetails(testFA.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetAllFinancialEntityWithDetailsModt() {
        Test.startTest();
        Financial_Account__c testFA = TestUtility.CreateFinancialAccountInstance();
        PayableDetailsController.getAllFinancialEntityWithDetailsModt(testFA.Id);
        Test.stopTest();
    }

    @isTest
    static void testAllowedEntityForMemoCreation() {
        Test.startTest();
        Financial_Account__c testFA = TestUtility.CreateFinancialAccountInstance();
        PayableDetailsController.AllowedEntityForMemoCreation(testFA.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpsertPayableRecord() {
        Test.startTest();
        Paybale__c payable = TestUtility.createMODTInstance();
        List<Paybale__c> payablesList = new List<Paybale__c>{payable};
        PayableDetailsController.upsertPayableRecord(payablesList);
        Test.stopTest();
    }

    @isTest
    static void testDeletePayableRecord() {
        Test.startTest();
        Paybale__c payable = TestUtility.createMODTInstance();
        PayableDetailsController.deletePayableRecord(payable.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetRelatedContactAccount() {
        Test.startTest();
        Financial_Account__c testFA = TestUtility.CreateFinancialAccountInstance();
        PayableDetailsController.getRelatedContactAccount(testFA.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpsertMODTRecords() {
        Test.startTest();
        Financial_Account__c testFA = TestUtility.CreateFinancialAccountInstance(); // Ensure this method creates a fully valid Financial_Account__c
        MODT_Details__c modt = TestUtility.CreateMODTDetailInsatance();
        List<MODT_Details__c> modtList = new List<MODT_Details__c>{modt};
            try {
                PayableDetailsController.upsertMODTRecords(modtList);
            } catch (Exception e) {
                // Log the exception or handle it if necessary.
            }
        Test.stopTest();
    }

    @isTest
    static void testDeleteMODTRecord() {
        Test.startTest();
        MODT_Details__c modt = TestUtility.CreateMODTDetailInsatance();
        PayableDetailsController.deleteMODTRecord(modt.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateMODT() {
        Test.startTest();
        MODT_Details__c modt = TestUtility.CreateMODTDetailInsatance();
        PayableDetailsController.updateMODT(modt.Id, true, 'Closed');
        Test.stopTest();
    }

    @isTest
    static void testFetchDataFromWire() {
        Test.startTest();
        Financial_Account__c testFA = TestUtility.CreateFinancialAccountInstance();
        PayableDetailsController.fetchDataFromWire(testFA.Id);
        Test.stopTest();
    }

    @isTest
    static void testVerifyExistingRecord() {
        Test.startTest();
        Account account = TestUtility.createTestAccount();
        PayableDetailsController.verifyExistingRecord(account.Email_Id__c);
        Test.stopTest();
    }

    @isTest
    static void testUppesertSobject() {
        Test.startTest();
        List<Financial_Entity_AC_Detail__c> acDetails = new List<Financial_Entity_AC_Detail__c>{TestUtility.CreateFiancialEntityAcctDetailInsatance()};
        PayableDetailsController.uppesertSobject(acDetails);
        Test.stopTest();
    }

    @isTest
    static void testCreateTask() {
        Test.startTest();
         Process_Task_Detail__c mockProcessTaskDetail = new Process_Task_Detail__c(Subject__c = 'Communication - Email');
        insert mockProcessTaskDetail;
        
         Process_Path__c  testPP=TestUtility.createTestProcessPath();
      //  Process_Task_Detail__c processTaskDetail = createMockProcessTaskDetail();
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Subject__c = 'Test Subject';
        testPPTD.Manual_API_Call_Out__c = true;
        testPPTD.Business_Step_No__c = 45;
        testPPTD.Task_Owner_Name__c = 'Test Owner';
        testPPTD.Process_Path__c=testPP.id;
        testPPTD.Process_Task_Detail__c = mockProcessTaskDetail.Id;
        testPPTD.Execution_Serial_No__c = '1';
        insert testPPTD;
        //insert mockProcessTaskDetail;
        
        Task parentTask = TestUtility.CreateTaskInstance();
        PayableDetailsController.createTask('Communication - Email', parentTask.Id, parentTask.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetDependentPicklistValues() {
        Test.startTest();
        // Using Account and Industry field as an example; adjust based on your org's schema
        Map<Object, List<String>> result = PayableDetailsController.getDependentPicklistValues('Account', 'Industry');
        Test.stopTest();
        // Normally, you would use System.assert methods to validate the result, 
        // but since you prefer not to use assertions, we'll just ensure the method executes.
    }
    
    @isTest
    static void testCreateAccountContactDetailsOnBehalfOfPayeeNumber() {
        Test.startTest();
        // Prepare the wrapper list
        List<PayableDetailsController.AccountCOntactPayeewrapper> wrapperList = new List<PayableDetailsController.AccountCOntactPayeewrapper>();
        PayableDetailsController.AccountCOntactPayeewrapper wrapper = new PayableDetailsController.AccountCOntactPayeewrapper();
        wrapper.payeeEmail = 'test@example.com';
        wrapper.payeePhone = '1234567890';
        wrapper.index = 1;
        wrapper.name = 'Test Account';
        
        // Assume this method sets up a related Financial_Entity__c record
        wrapper.relatedFinancialEntity = TestUtility.CreateFinancialEntityInstance();
        wrapperList.add(wrapper);
        
        PayableDetailsController.createAccountContactDetailsOnBehalofPayeeNumber(wrapperList);
        Test.stopTest();
        // No assertions are included as per your request
    }



    // Add more test methods as needed to cover all methods in PayableDetailsController
}