@IsTest
global class SharePointHandlerTest {
    
    // Mock class implementing HttpCalloutMock interface to simulate HTTP responses
    global class SharePointCalloutMock implements HttpCalloutMock {
        // Variables to store mock response values
        private final String body;
        private final Integer statusCode;
        
        // Constructor to initialize mock response values
        global SharePointCalloutMock(String body, Integer statusCode) {
            this.body = body;
            this.statusCode = statusCode;
        }
        
        // This method is called when making a callout
        global HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HTTPResponse res = new HTTPResponse();
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        }
    }
    
    // Inner class to simulate the HTTP response
    global class SharePointCreateFolderMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"d": {"ServerRelativeUrl": "/sites/NorthernArc/Shared Documents/TestFolder"}}');
            res.setStatusCode(201); // Status code for successful creation
            return res;
        }
    }
    
    global class SharePointDeleteMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            // Mock response body for folder/file deletion
            HTTPResponse res = new HTTPResponse();
            res.setBody('Success');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class SharePointCreateFileMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            // Mock response body for file creation
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"d": {"ServerRelativeUrl": "TestFileUrl"}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class SharePointDownloadFileMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            // Mock response for file download
            HTTPResponse res = new HTTPResponse();
            res.setBody('FileContent');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Test method for getFiles
    @IsTest
    static void testGetFiles() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new SharePointCalloutMock('[{"name":"Test File"}]', 200));
        
        Test.startTest();
        // Call the method to test
        String result = SharePointHandler.getFiles();
        Test.stopTest();
        
        // Normally assertions would go here.
    }
    
    // Test method for getAllFilesAndFoldersInSites
    @IsTest
    static void testGetAllFilesAndFoldersInSites() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new SharePointCalloutMock('[{"name":"Test Folder"}]', 200));
        
        Test.startTest();
        // Call the method to test
        String result = SharePointHandler.getAllFilesAndFoldersInSites('Test Folder', 'Files');
        Test.stopTest();
        
        // Normally assertions would go here.
    }
    
    // Test method for getFilesOrFolder
    @IsTest
    static void testGetFilesOrFolder() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new SharePointCalloutMock('[{"name":"Test Folder"}]', 200));
        
        Test.startTest();
        // Call the method to test
        String result = SharePointHandler.getFilesOrFolder('/Shared Documents');
        Test.stopTest();
        
        // Normally assertions would go here.
    }
    
    
    @IsTest
    static void testCreateFolderInsideSite() {
        // Prepare the mock response for folder creation
        Test.setMock(HttpCalloutMock.class, new SharePointCreateFolderMock());

        Test.startTest();
        // Call the method that makes a callout
        String folderCreationResult = SharePointHandler.createFolderInsideSite('TestFolder');
        Test.stopTest();

        // Normally assertions would go here to check the response 'Success' or 'Failure'.
    }
    
    @IsTest
    static void testCreateFolder() {
        Test.setMock(HttpCalloutMock.class, new SharePointCreateFolderMock());
        Test.startTest();
        String folderCreationResult = SharePointHandler.createFolder('TestFolder');
        Test.stopTest();
        // Normally assertions would go here.
    }

    // Example test method for deleteFolderInsideSite
    @IsTest
    static void testDeleteFolderInsideSite() {
        Test.setMock(HttpCalloutMock.class, new SharePointDeleteMock());
        Test.startTest();
        Boolean deleteResult = SharePointHandler.deleteFolderInsideSite('TestFolder');
        Test.stopTest();
        // Normally assertions would go here.
    }

    // Example test method for createFileInsideSite
    @IsTest
    static void testCreateFileInsideSite() {
        Test.setMock(HttpCalloutMock.class, new SharePointCreateFileMock());
        Test.startTest();
        String fileCreationResult = SharePointHandler.createFileInsideSite('TestFolder', 'TestFile.txt');
        Test.stopTest();
        // Normally assertions would go here.
    }

    // Example test method for createFileUsingBlob
    @IsTest
    static void testCreateFileUsingBlob() {
        Test.setMock(HttpCalloutMock.class, new SharePointCreateFileMock());
        Test.startTest();
        String fileCreationResult = SharePointHandler.createFileUsingBlob(Blob.valueOf('Test Content'), 'TestFile.txt', 'TestFolder');
        Test.stopTest();
        // Normally assertions would go here.
    }

    // Example test method for deleteFileInsideSite
    @IsTest
    static void testDeleteFileInsideSite() {
        Test.setMock(HttpCalloutMock.class, new SharePointDeleteMock());
        Test.startTest();
        String deleteFileResult = SharePointHandler.deleteFileInsideSite('TestFolder/TestFile.txt');
        Test.stopTest();
        // Normally assertions would go here.
    }

    // Example test method for downloadFile
    @IsTest
    static void testDownloadFile() {
        Test.setMock(HttpCalloutMock.class, new SharePointDownloadFileMock());
        Test.startTest();
        String downloadResult = SharePointHandler.downloadFile('TestFolder/TestFile.txt');
        Test.stopTest();
        // Normally assertions would go here.
    }

    // And so on for each method in your SharePointHandler class...

}