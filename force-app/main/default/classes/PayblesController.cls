public class PayblesController {

    public String financialAccountId { get; private set; }
    private ApexPages.StandardSetController stdController;

    public PayblesController(ApexPages.StandardSetController stdController) {
        // Get Financial_Account__c ID from Paybles__c
        this.stdController = stdController;
        financialAccountId = getFinancialAccountId();
    }

    private String getFinancialAccountId() {
        String financialAccountId;

        // Replace 'OpportunityId' and 'Financial_Account__c' with your actual field names
        List<Paybale__c> payblesList = [SELECT Opportunity__c,Financial_Account__c FROM Paybale__c WHERE Opportunity__c = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];

        if (!payblesList.isEmpty() && payblesList[0].Financial_Account__c != null) {
            financialAccountId = payblesList[0].Financial_Account__c;
        }
        system.debug('financialAccountId ====> ' + financialAccountId);

        return financialAccountId;
    }

    // Add more methods or modify as needed for your specific requirements

}