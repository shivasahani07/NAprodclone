public without sharing class paymentscheduleController {

    @AuraEnabled
    public static RelatedWrapper getTaskRelatedDetails(String taskId){
        Opportunity OppRec = new Opportunity();
        RelatedWrapper Relwrap = new RelatedWrapper();
        Map<String, List<String>> picklistValueMap = new Map<String, List<String>>();

        try{
            Task tas = [SELECT AccountId,Id,RecordTypeId,Status,Subject,WhatId FROM Task where Id=: taskId];
            if(tas.WhatId != null && String.valueOf(tas.WhatId).startsWith('006')){
                OppRec = [Select id, Name, AccountId, Account.name, stageName, recordTypeId From Opportunity where Id =:tas.WhatId ];
                Relwrap.taskOppdetails = oppRec;
                List<Payment_schedule__c> paymentrecordwithchild = [SELECT Billing_Frequency__c,Billing_Period__c,Ceiling_Price__c,Cost_Price_Type__c,Floor_Price__c,Id,Model_Build_Price__c,Model_Recalibration_Price__c,Name,Opportunity__c,validity_End_Date__c,validity_start_Date__c, floor_period__c, Ceiling_Period__c,
                                                                    (SELECT End_Value__c,Id,Name,Payment_Schedule__c,Price_Structure_Reset_Frequency__c,Price_Structure_Type__c,Rate__c,Start_Value__c FROM Price_Structures__r order By Name ASC)
                                                                    FROM Payment_Schedule__c where Opportunity__c =: tas.WhatId ];

                if(paymentrecordwithchild.size() > 0){
                    Relwrap.paymentrecordwithchild = paymentrecordwithchild;
                }
                else{
                    Relwrap.paymentrecordwithchild = null;
                }
            }
            else{
                Relwrap.taskOppdetails = null;
            }



            picklistValueMap.put('Billing_Frequency', Utility.getPicklistValueSet('Payment_Schedule__c','Billing_Frequency__c'));
            picklistValueMap.put('Cost_Price_Type', Utility.getPicklistValueSet('Payment_Schedule__c','Cost_Price_Type__c'));
            picklistValueMap.put('Price_Structure_Reset_Frequency', Utility.getPicklistValueSet('Price_Structure__c','Price_Structure_Reset_Frequency__c'));
            picklistValueMap.put('Price_Structure_Type', Utility.getPicklistValueSet('Price_Structure__c','Price_Structure_Type__c'));
            //picklistValueMap.put('Cost_Price_Type', Utility.getPicklistValueSet('Payment_Schedule__c','Cost_Price_Type__c'));
            Relwrap.picklistMap = picklistValueMap;

        }
        catch(Exception e){
            System.debug('The error has occured due to ====> ' + e.getmessage());
        }
        return Relwrap;

    }

    @AuraEnabled
    public static RelatedWrapper getTaskRelatedDetailsForRecal(String taskId){
        Opportunity OppRec = new Opportunity();
        Opportunity PaymentScheduleOppRec = new Opportunity();
        RelatedWrapper Relwrap = new RelatedWrapper();
        Map<String, List<String>> picklistValueMap = new Map<String, List<String>>();

        try{
            Task tas = [SELECT AccountId,Id,RecordTypeId,Status,Subject,WhatId FROM Task where Id=: taskId];
            if(tas.WhatId != null && String.valueOf(tas.WhatId).startsWith('006')){
                OppRec = [Select id, Name, AccountId, Account.name, stageName, recordTypeId From Opportunity where Id =:tas.WhatId ];
                Relwrap.taskOppdetails = oppRec;

                if(OppRec != null){
                    PaymentScheduleOppRec = [Select id, Name, AccountId, Account.name, stageName, recordTypeId From Opportunity 
                                            where AccountId =:OppRec.AccountId and Type = 'Payment Schedule Creation'];
                    if (PaymentScheduleOppRec != null) {
                        List<Payment_schedule__c> paymentrecordwithchild = [SELECT Billing_Frequency__c,Billing_Period__c,Ceiling_Price__c,Cost_Price_Type__c,Floor_Price__c,Id,Model_Build_Price__c,Model_Recalibration_Price__c,Name,Opportunity__c,
                                                                            validity_End_Date__c,validity_start_Date__c, floor_period__c, Ceiling_Period__c,New_Recalibration_Price__c,
                                                                    (SELECT End_Value__c,Id,Name,Payment_Schedule__c,Price_Structure_Reset_Frequency__c,Price_Structure_Type__c,Rate__c,Start_Value__c FROM Price_Structures__r order By Name ASC)
                                                                    FROM Payment_Schedule__c where Opportunity__c =: PaymentScheduleOppRec.Id ];

                        Relwrap.paymentrecordwithchild = paymentrecordwithchild;
                    }    
                }
                
            }
        }
        catch(Exception e){
                System.debug('The error has occured due to ====> ' + e.getmessage());
            }
            return Relwrap;

        }

    @AuraEnabled
    public static Payment_Schedule__c Submitpaymentschedule(Payment_Schedule__c PsRecord){
        System.debug('PsRecord ====> ' + PsRecord);
        //PsRecord.Task_Id__c = String.valueOf(PsRecord.Task_Id__c);
        upsert PsRecord;
        return PsRecord;
    }
    @AuraEnabled
    public static string SubmitPriceStructure(List<Price_Structure__c> PSRecord){
        upsert PSRecord;
        return 'SUCCESS';

    }

    public class RelatedWrapper{
        @AuraEnabled
        public Opportunity taskOppdetails;
        @AuraEnabled
        public  Map<String, List<String>> picklistMap;
        @AuraEnabled
        public List<Payment_schedule__c> paymentrecordwithchild;
    }

}