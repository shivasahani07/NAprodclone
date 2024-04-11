global class API_updateStatus {
    
    public static httpresponse updateStatusByTransactionId(String transactionId){
        // Specify the URL with the query parameter
        String url = 'https://nimbusdev.northernarc.com/n-disbursement/api/updateStatus?transactionId='+transactionId;
        
        // Create an HTTP request object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response;
        try {
            response = http.send(request);
            // Check if the request was successful
            if (response.getStatusCode() == 200) {
                System.debug('Response Body: ' + response.getBody());
            } else {
                // Handle error response
                System.debug('Error Response: ' + response.getBody());
            }
        } catch (Exception e) {
            // Handle exception
            System.debug('Exception: ' + e.getMessage());
        }
        return response;
    }
    
    public static string processRequestdata(string taskRecordId){
        auditwrapper auditwarp = new auditwrapper();
        PeenyDropStatusWrapper wrapperResponse = new PeenyDropStatusWrapper();
        string bankDetailsSFDXId;
        HttpResponse response;
        task taskRec = [Select id, Attribute1__c from Task Where Id = :taskRecordId];
        if (taskRec	 != null && taskRec.Attribute1__c !=null){
            bankDetailsSFDXId=taskRec.Attribute1__c;
            Financial_Entity_AC_Detail__c backDetails=[SELECT id,Name,Verification_Status__c,TransactionId__c,BatchId__c FROM Financial_Entity_AC_Detail__c WHERE Id=:bankDetailsSFDXId];
            response = updateStatusByTransactionId(backDetails.TransactionId__c);
            if (response != null && response.getStatusCode() == 200) {
                wrapperResponse = (PeenyDropStatusWrapper) JSON.deserialize(response.getBody(), PeenyDropStatusWrapper.class);
                try {
                    Financial_Entity_AC_Detail__c updateBankDetailsStatus = new Financial_Entity_AC_Detail__c();
                    // Updating bank details status
                    updateBankDetailsStatus.Verification_Status__c = wrapperResponse.status;
                    updateBankDetailsStatus.id = bankDetailsSFDXId;
                    //updateBankDetailsStatus.TransactionId__c=wrapperResponse.transactionId;
                    update updateBankDetailsStatus;
                    auditwarp.ResponseBody =string.valueof(response.getBody());
                    auditwarp.status = Label.AuditAPIStatus;
                } catch(Exception e){
                    System.debug('Exception occurred: ' + e.getMessage());
                    System.debug('Exception occurred at line Number: ' + e.getlineNumber());
                    auditwarp.CallOutApiProcessResult= e.getMessage();
                }
            } else {
                // Handle error response
                System.debug('Error Response: ' + response.getBody());
                auditwarp.ResponseBody = response.getBody();
                auditwarp.status = Label.AuditAPIFailedStatus;
            }
        }
        
        return JSON.serialize(auditwarp);
    }
    
    Public class auditwrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody; 
        public string CallOutApiProcessResult;
    }
    
    public class PeenyDropStatusWrapper {
        public String status;
        public String timestamp;
        public String message;
        public List<String> errors;
    }
}