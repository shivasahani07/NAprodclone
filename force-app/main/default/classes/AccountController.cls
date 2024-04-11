public without sharing class AccountController{
    @AuraEnabled
    public static Id createTaskForSearch(String searchByString, String subject){
        Task newTask = new Task();
        newTask.Attribute1__c = searchByString;
        newTask.Status = 'Open';
        newTask.Subject = subject;
        List<Process_Path_Task_Detail__c> details = [SELECT Id
                                                     FROM Process_Path_Task_Detail__c
                                                     WHERE Process_Task_Detail__r.Subject__c = :subject
                                                     LIMIT 1];

        // Only proceed if there is exactly one record found
        if (!details.isEmpty()){
            newTask.Process_Path_Task_Detail__c = details[0].Id;
        } else{
            // Handle the case where no matching record is found
            // You might throw an exception or simply not set the Process_Path_Task_Detail__c field
        }
        insert newTask;
        return newTask.Id;
    }

    @AuraEnabled
    public static Account getAccountFromAudit(Id taskId){
        List<API_Callout_Audit__c> auditRecord = [SELECT Task_ID__c
                                            FROM API_Callout_Audit__c
                                            WHERE Task_ID__c = :taskId AND API_Status__c = 'Success'
                                            LIMIT 1];
        System.debug('auditRecord == >' + auditRecord);

        if (auditRecord.size() >0){
            Task taskRecord = [SELECT Attribute1__c
                               FROM Task
                               WHERE Id = :taskId
                                WITH SYSTEM_MODE LIMIT 1];
            if (taskRecord != null){
                String[] parts = taskRecord.Attribute1__c.split(':');
                String searchType = parts[0];
                String searchValue = parts[1].trim();

                if ('companyName'.equalsIgnoreCase(searchType)){
                    return [SELECT Id, Name, CIN_No__c, Email_Id__c, Phone, Short_Key__c
                            FROM Account
                            WHERE Name = :searchValue
                            LIMIT 1];
                } else if ('cin'.equalsIgnoreCase(searchType)){
                    return [SELECT Id, Name, CIN_No__c, Email_Id__c, Phone, Short_Key__c
                            FROM Account
                            WHERE CIN_No__c = :searchValue
                            LIMIT 1];
                }
            }
        }
            return null;
        
    }

    @AuraEnabled
    public static String updateAccount(String accountId, String email, String phone, String apiKey){
        List<Account> accounts = [SELECT Id, Name, Email_Id__c, Phone, Short_Key__c, Account_Status__c, Product_Bussiness_Line__c, RecordTypeId
                                  FROM Account
                                  WHERE Id = :accountId
                                  LIMIT 1];
        RecordType AccountNuScoreRT = [SELECT BusinessProcessId, Description, Id, Name, SobjectType
                                       FROM RecordType
                                       where SobjectType = 'Account' AND Name = 'Business Team NU Score'
                                       LIMIT 1];

        if (!accounts.isEmpty()){
            Account acc = accounts[0];
            acc.Email_Id__c = email;
            // Only update if a value is provided
            if (String.isNotBlank(phone))
                acc.Phone = phone;
            if (String.isNotBlank(apiKey))
                acc.Short_Key__c = apiKey;
            acc.Product_Bussiness_Line__c = 'NU Score';
            acc.Account_Status__c = 'Created';
            acc.RecordTypeId = AccountNuScoreRT.Id;
            update acc;
            createPartnerAPItask('Create Partner Callout - Nimbus', null, acc.Id );

            List<Opportunity> existingOpps = [SELECT Id
                                              FROM Opportunity
                                              WHERE AccountId = :acc.Id
                                              LIMIT 1];
            if (existingOpps.isEmpty()){
                //List<Process_Attribute__c> PAlist = [Select Id, name  from Process_Attribute__c where Sobject_RecordType_Name__c = 'NU Score Payment Schedule Creation' LIMIT 1];
                // No existing opportunity found, create a new one
                Opportunity NuScoreOpp = new Opportunity();
                NuScoreOpp.Name = acc.Name + '-' + String.valueof(system.today());
                NuScoreOpp.StageName = 'New';
                NuScoreOpp.CloseDate = system.today().adddays(1);
                NuScoreOpp.Type = 'Payment Schedule Creation';
                NuScoreOpp.AccountId = acc.Id;
                //NuScoreOpp.Process_Attribute__c = PAlist[0].Id;
                insert NuScoreOpp;
            }

            return 'success';
        } else{
            throw new AuraHandledException('No matching account found.');
        }
    }

    @AuraEnabled(cacheable = true)
    public static Account findAccount(String searchKey, String searchField){
        String query = 'SELECT Id, Name, CIN_No__c, Email_Id__c, Phone, Short_Key__c FROM Account WHERE ' + searchField + ' = :searchKey LIMIT 1';
        List<Account> accounts = Database.query(query);
        return accounts.isEmpty() ? null : accounts[0];
    }

    @AuraEnabled
    public static void createPartnerAPItask(String Subject, string searchByString, String WhatId){
        Task newTask = new Task();
        if (searchByString != null){
            newTask.Attribute1__c = searchByString;
        }
        newTask.Status = 'Open';
        newTask.Subject = subject;
        newTask.WhatId = WhatId;
        List<Process_Path_Task_Detail__c> Pptdetails = [SELECT Id
                                                     FROM Process_Path_Task_Detail__c
                                                     WHERE Process_Task_Detail__r.Subject__c = :subject
                                                     LIMIT 1];

        // Only proceed if there is exactly one record found
        if (!Pptdetails.isEmpty()){
            newTask.Process_Path_Task_Detail__c = Pptdetails[0].Id;
        } else{
            // Handle the case where no matching record is found
            // You might throw an exception or simply not set the Process_Path_Task_Detail__c field
        }
        insert newTask;
    }

    @AuraEnabled
    public static Id createTaskAfterSearch(String subject, Id whatId){
        Task newTask = new Task();
        newTask.Subject = subject;
        newTask.WhatId = whatId;
        // Set other necessary Task fields
        insert newTask;
        return newTask.Id;
    }

}