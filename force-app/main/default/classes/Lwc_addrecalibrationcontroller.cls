public with sharing class Lwc_addrecalibrationcontroller {

    @AuraEnabled
    public static NuScoreOppwrapper CreateAddRecalibrationtask(String accId){
        NuScoreOppwrapper NuScoreOppwrap = new NuScoreOppwrapper();
        try {

            List<Opportunity> ExistingOppRec = [Select Id, Name from Opportunity Where AccountId =:accId and IsClosed = false And type ='Payment Schedule Creation'];
            if(ExistingOppRec.size() >0){
                NuScoreOppwrap.OppRec = ExistingOppRec[0];
                NuScoreOppwrap.Oppstatus = 'Existing NuScore PS Opportunity';
            }
            else {
                Account AccRec = [Select Name, Id From account Where Id=:accId];
                Opportunity NuScoreOpp = new Opportunity();
                NuScoreOpp.Name = AccRec.Name +'-' + String.valueof(system.today());
                NuScoreOpp.StageName = 'New';
                NuScoreOpp.CloseDate = system.today().adddays(1);
                NuScoreOpp.Type = 'Recalibration Invoice Creation';
                NuScoreOpp.AccountId = accId;
                Insert NuScoreOpp;
                NuScoreOppwrap.OppRec = NuScoreOpp;
                NuScoreOppwrap.Oppstatus = 'New NuScore Recalibration Opportunity';
            }
            

        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            NuScoreOppwrap.OppRec = null;
            NuScoreOppwrap.Oppstatus = e.getMessage();
            
        }
        return NuScoreOppwrap;
    }

    public class NuScoreOppwrapper{
        @AuraEnabled
        public Opportunity OppRec;
        @AuraEnabled
        public String Oppstatus;
    }
}