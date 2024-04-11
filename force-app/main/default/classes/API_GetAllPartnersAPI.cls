public class API_GetAllPartnersAPI{
    // Method to get all partners using the provided API endpoint and data
    // meta recods Done by name =getAllPartners
    public static void getAllPartners(){
        NUScoreCreds__mdt webCreds = NUScoreCreds__mdt.getInstance('getAllPartners');
        system.debug('webCreds--->' + webCreds);
        String endpoint = webCreds.endpoint__c;
        system.debug('webCreds.endpoint__c--->' + webCreds.endpoint__c);
        String apiKey = webCreds.apiKey__c;
        system.debug('webCreds.apiKey__c--->' + webCreds.apiKey__c);
        String groupKey = webCreds.groupKey__c;
        system.debug('webCreds.groupKey__c--->' + webCreds.groupKey__c);

        // String endpoint = 'https://stage.northernarc.com/it/api/nuscore/getAllPartners';
        // String apiKey = '90ddb154c765c1d49dc2e1a1e7b235573aa85fe751e2f814bef4c28ad1e8c92e';
        // String groupKey = 'SERV_SALES_FORCE';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('API-KEY', apiKey);
        request.setHeader('GROUP-KEY', groupKey);
        system.debug('request--->' + request);
        // Send the request
        Http http = new Http();
        HttpResponse response = http.send(request);

        // Parse and handle the response
        if (response.getStatusCode() == 200){
            String responseBody = response.getBody();
            // Parse the JSON response body as needed
            System.debug('Response body: ' + responseBody);
            List<partnerlistwrapper> partnerwrapperList = (List<partnerlistwrapper>)System.JSON.deserialize(responseBody, List<partnerlistwrapper>.class);
            System.debug('partnerwrapperList ====> ' + partnerwrapperList);
            createPartner_SF(partnerwrapperList);

        } else{
            // String returneddummyresponse = Utility.getpartnerAPIStaticResponse();
            // List<partnerlistwrapper> partnerwrapperList = (List<partnerlistwrapper>) System.JSON.deserialize(returneddummyresponse, List<partnerlistwrapper>.class);
            // System.debug('partnerwrapperList ====> ' + partnerwrapperList);
            // createPartner_SF(partnerwrapperList);
            // System.debug('Failed to get all partners. Status code: ' + response.getStatusCode());
        }
    }

    Public static void createPartner_SF(List<partnerlistwrapper> partnerwrapperList){

        List<Account> PartnerList = new List<Account>();
        for (partnerlistwrapper partnerlistwrap : partnerwrapperList){
            System.debug('partnerlistwrap.name ===> ' + partnerlistwrap.name);
            Account partnerRec = new Account();
            partnerRec.External_ID__c = partnerlistwrap.entity_id;
            partnerRec.CustomerID__c = partnerlistwrap.entity_id;
            partnerRec.Name = partnerlistwrap.name;
            partnerRec.CIN_No__c = partnerlistwrap.cin;
            partnerRec.email_Id__c = partnerlistwrap.email;
            partnerRec.Phone = partnerlistwrap.phone;
            if (partnerlistwrap.name != null){
                PartnerList.add(partnerRec);
            }
        }
        System.debug('PartnerList ====> ' + PartnerList);

        if (PartnerList.size() > 0){
            upsert PartnerList;

            Schema.SObjectField ftoken = Account.Fields.External_ID__c;
            Database.UpsertResult[] srList = Database.upsert (PartnerList, ftoken, false);
            for (Database.UpsertResult sr : srList){
                if (sr.isSuccess()){
                    // Operation was successful
                } else{
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()){
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());

                    }
                }
            }
        }
    }

    public class partnerlistwrapper{
        public String entity_id;
        public String name;
        public String cin;
        public String email;
        public String phone;

    }

}