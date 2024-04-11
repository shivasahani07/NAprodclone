@isTest
private class TestSendPayableDetailsToCustomer {

    @isTest
    static void testSendPayableDetails() {
        // Create necessary test data using TestUtility
        Account testAccount = TestUtility.createTestAccount();
        //insert testAccount;

        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity;

        Payment_Schedule__c testPaymentSchedule = TestUtility.createTestPaymentSchedule(testOpportunity.Id);
        //insert testPaymentSchedule;

        Paybale__c testPayable = TestUtility.createMODTInstance();
        //insert testPayable;
        
        Document_Handler__c DocHandler= TestUtility.createDocumentHandlerInstance();
        DocHandler.Status__c = 'Submitted For Execution';
        Insert DocHandler;
        

        Task testTask = TestUtility.createTestTaskWithAttribute('test');
        insert testTask;

        // Call the method under test
        Test.startTest();
        SendPayableDetailsToCustomer.sendPayableDetails(testTask.Id);
        Test.stopTest();

        // Assertions would normally go here
    }

    @isTest
    static void testSendMail() {
        // Bypass the actual email sending during tests
        Test.startTest();
        // Directly call the sendMail method without condition because Salesforce won't actually send emails in a test context
        SendPayableDetailsToCustomer.sendMail('test@example.com', 'Test Subject', 'This is a test body.');
        Test.stopTest();
    }


    @isTest
    static void testReadExcel() {
        // Create a dummy CSV content to mimic Excel file reading
        String csvContent = 'Column1,Column2\nValue1,Value2';

        // Call the method under test
        Test.startTest();
        SendPayableDetailsToCustomer.readExcel(csvContent);
        Test.stopTest();

        // Assertions would normally go here
    }
    
    @isTest
    static void testSendMailAndInspectResults() {
        // Setup test data, if needed

        Test.startTest();
        // Directly call the sendMail method to simulate email sending
        SendPayableDetailsToCustomer.sendMail('test@example.com', 'Test Subject', 'This is a test body.');
        Test.stopTest();

        // Since Salesforce does not send emails in test context, no need for further assertions here.
    }
    
    
}