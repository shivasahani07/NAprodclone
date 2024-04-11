public class SystemExecutedMasterClass {
    
    public class FlowInput {
        @InvocableVariable(label='Record Id' required=true)
        public Id recordId;
        @InvocableVariable(label='actionName' required=true)
        public String actionName;
        @InvocableVariable(label='taskRecordId' required=true)
        public String taskRecordId;
    }
    
    @InvocableMethod(label='ExecuteSystemAction' description='Process records using Apex')
    public static void processRecords(List<FlowInput> flowInputs) {
        String auditResult = '';
        ID auditRecId;
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        API_CreatePartnerAPI.auditwrapper auditwarp = new API_CreatePartnerAPI.auditwrapper();
        for(FlowInput input : flowInputs){
            system.debug('input::'+input);
            auditRecId = input.recordId;
            if(input.actionName == 'SendPayableDetailsToCustomer'){
                auditResponse = SendPayableDetailsToCustomer.sendPayableDetails(input.taskRecordId);
                system.debug('auditResponse::'+acaRec);
                acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
            }
            else if (input.actionName == 'API_SearchPartnersAPI') {
                auditResult = API_SearchPartnersAPI.searchPartners(input.taskRecordId);
                //acaRec.API_Status__c = auditResult;
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
            }
            else if (input.actionName == 'API_CreatePartnerAPI') {
                auditResult= API_CreatePartnerAPI.createPartner(input.taskRecordId);
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
                
            }
            else if (input.actionName == 'API_CreatePaymentScheduleAPI') {
                auditResult = API_CreatePaymentScheduleAPI.createPaymentSchedule(input.taskRecordId);
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
                
            }
            else if (input.actionName == 'API_AddRecalibrationAPI') {
                auditResult = API_AddRecalibrationAPI.addRecalibration(input.taskRecordId);
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
                
            }
            else if (input.actionName == 'API_PennyDropCallout') {
                auditResult = API_PennyDropCallout.processResponseData(input.taskRecordId);
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
                
            }
            else if (input.actionName == 'API_getPennyDropStatusbyBatchId') {
                auditResult = API_getPennyDropStatusbyBatchId.processRequestdata(input.taskRecordId);
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
                
            }
            else if (input.actionName == 'API_updateStatus') {
                auditResult = API_updateStatus.processRequestdata(input.taskRecordId);
                auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
            }
        }
        system.debug('auditResult::'+auditResult);
        system.debug('auditRecId::'+auditRecId);
        acaRec.Id = auditRecId;
        
        if(auditwarp != null){
            acaRec.Request__c = auditwarp.RequestBody;
            acaRec.Response__c =auditwarp.ResponseBody;
            acaRec.Response_Proccessing_DML_Result__c =auditwarp.processingDMLData;
            acaRec.Status__c = 'Completed';
            acaRec.API_Status__c = auditwarp.status;
            
            
            
        }
        if (auditResponse.auditRec != null) {
                acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
                acaRec.Response__c = auditResponse.auditRec.Response__c;
            }
        system.debug('acaRec::'+acaRec);
        update acaRec;
        
    }
    
}