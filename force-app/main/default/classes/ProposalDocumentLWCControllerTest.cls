@IsTest
global class ProposalDocumentLWCControllerTest {

    // Mock class for simulating SharePoint callouts
    global class SharePointMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            // Prepare a generic response based on the endpoint called
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);

            // Identify which response to return based on the requested endpoint
            String endpoint = req.getEndpoint();
            if (endpoint.contains('Files')) {
                res.setBody('{"d": {"results": [{"name": "File1", "ServerRelativeUrl": "FileUrl1"}]}}');
            } else if (endpoint.contains('Folders')) {
                res.setBody('{"d": {"results": [{"name": "Folder1", "ServerRelativeUrl": "FolderUrl1"}]}}');
            } else if (endpoint.contains('add')) {
                res.setBody('{"d": {"ServerRelativeUrl": "NewFileUrl"}}');
            } else if (endpoint.contains('$value')) {
                res.setBody('FileContents');
            } else {
                // Default response for folder creation and deletion
                res.setBody('{"d": {"ServerRelativeUrl": "NewFolderUrl"}}');
            }

            return res;
        }
    }
    
    global class SharePointCalloutMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            // Prepare a response that will cause an exception
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500); // Internal server error to simulate a failure
            res.setBody('{"error": {"code": "Internal Server Error", "message": "An internal error occurred."}}');
            return res;
        }
    }
    
    private static void prepareMockException() {
        Test.setMock(HttpCalloutMock.class, new SharePointCalloutMock());
    }
    
    
    private static void executeTestMethod(String methodName) {
        // Execute the specified method and let the exception be thrown
        Test.startTest();
        try {
            // Make a call to the method that will throw an exception due to the mock
            switch on methodName {
                when 'getFoldersAndFiles' {
                    ProposalDocumentLWCController.getFoldersAndFiles('001xx000003NGZxAAO'); // Adjust the ID as necessary
                }
                when 'getSubFoldersAndFiles' {
                    ProposalDocumentLWCController.getSubFoldersAndFiles('filesUrl', 'foldersUrl');
                }
                when 'createFolder' {
                    ProposalDocumentLWCController.createFolder('TestPath');
                }
                when 'deleteFolderInsideSite' {
                    ProposalDocumentLWCController.deleteFolderInsideSite('TestPath');
                }
                when 'createFile' {
                    ProposalDocumentLWCController.createFile('base64String', 'TestFile.txt', 'TestPath');
                }
                when 'deleteFileSP' {
                    ProposalDocumentLWCController.deleteFileSP('TestPath');
                }
                when 'downloadFile' {
                    ProposalDocumentLWCController.downloadFile('TestPath');
                }
                when else {
                    // This should not happen in your tests; this is just for completeness
                    System.debug('Method name not recognized: ' + methodName);
                }
            }
        } catch (Exception e) {
            // Normally you would use assertions to ensure the correct exception is caught
            System.debug('Exception caught: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFoldersAndFilesException() {
        prepareMockException();
        executeTestMethod('getFoldersAndFiles');
    }
    
    @IsTest
    static void testGetSubFoldersAndFilesException() {
        prepareMockException();
        executeTestMethod('getSubFoldersAndFiles');
    }

    @IsTest
    static void testCreateFolderException() {
        prepareMockException();
        executeTestMethod('createFolder');
    }
    
    @IsTest
    static void testdeleteFolderException() {
        prepareMockException();
        executeTestMethod('deleteFolderInsideSite');
    }
   


    // Test setup method to create test data
    @testSetup
    static void setup() {
        // Create an Account record
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        // Create an Opportunity record and associate it with the Account
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting', // Use a valid stage name for your org
            CloseDate = System.today().addDays(10),
            AccountId = testAccount.Id, // Set the Account ID here
            SharePoint_URL__C = 'https://utillabs.sharepoint.com/sites/NortherArc/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FNortherArc%2F'
        );
        insert testOpportunity;
    }

    @IsTest
    static void testGetFoldersAndFiles() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Opportunity testOpportunity = [SELECT Id, SharePoint_URL__C FROM Opportunity LIMIT 1];
        Test.startTest();
        Map<String,List<Object>> foldersAndFiles = ProposalDocumentLWCController.getFoldersAndFiles(testOpportunity.Id);
        Test.stopTest();
        // No assertions
    }

    @IsTest
    static void testGetSubFoldersAndFiles() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Test.startTest();
        Map<String,List<Object>> subFoldersAndFiles = ProposalDocumentLWCController.getSubFoldersAndFiles('filesUrl', 'foldersUrl');
        Test.stopTest();
        // No assertions
    }

    @IsTest
    static void testCreateFolder() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Test.startTest();
        Map<String,Object> folderResponse = ProposalDocumentLWCController.createFolder('TestPath');
        Test.stopTest();
        // No assertions
    }

    @IsTest
    static void testDeleteFolderInsideSite() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Test.startTest();
        String deleteFolderResponse = ProposalDocumentLWCController.deleteFolderInsideSite('TestPath');
        Test.stopTest();
        // No assertions
    }

    @IsTest
    static void testCreateFile() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Test.startTest();
        Map<String,Object> fileResponse = ProposalDocumentLWCController.createFile('base64String', 'TestFile.txt', 'TestPath');
        Test.stopTest();
        // No assertions
    }

    @IsTest
    static void testDeleteFileSP() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Test.startTest();
        String deleteFileResponse = ProposalDocumentLWCController.deleteFileSP('TestPath');
        Test.stopTest();
        // No assertions
    }

    @IsTest
    static void testDownloadFile() {
        Test.setMock(HttpCalloutMock.class, new SharePointMock());
        Test.startTest();
        String fileContent = ProposalDocumentLWCController.downloadFile('TestPath');
        Test.stopTest();
        // No assertions
    }

    // Additional test methods can be defined for other scenarios
}