public class WelcomeLetterController {
    public static Financial_Account__c fa_Record{get;set;}
    public WelcomeLetterController(){
        system.debug('inside the construction');
        Id financialAccountId = 'a05Bl000003J05pIAC';
        getFinancialDetails(financialAccountId);
    }
    
    public static void getFinancialDetails(Id financialAccountId){
        fa_Record = [SELECT Id,Name,Sanctioned_Amount__c,Account_Name__r.Phone,
                     Sanction_Date__c,Installment__c,Installment_Amount__c,
                     Installment_Due_On__c 
                     From Financial_Account__c 
                     Where Id =: financialAccountId];
        system.debug('fa_Record::'+fa_Record);
    }
}