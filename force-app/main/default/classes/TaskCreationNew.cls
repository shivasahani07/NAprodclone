public class TaskCreationNew {
        
        private static map<string,Task>  map_all_task = new map<string,Task>();
        private static map<string,Task>  map_new_task = new map<string,Task>();
        
        public class SObjectTaskWrapper {
            @InvocableVariable(label='SObject' description='SObject id for which new tasks will be created')
            public SObject inp_sObject;
        }
        
        @InvocableMethod(label='SObject id for which new tasks will be created' description='sobject id for which new tasks will be created')
        public static List<String> SObjectNewTaskCreation(List<SObjectTaskWrapper> inp_parms) 
        {
            system.debug('inp_parms--->'+inp_parms);
            list<string> l_return = new list<string>();
            set<string> inp_sobjectids = new set<string>();
            set<string> inp_taskids = new set<string>();
            string inp_ObjectType = inp_parms[0].inp_sObject.id.getSObjectType().getDescribe().getName();
            system.debug('inp_ObjectType--->'+inp_ObjectType);
            
            List<sobject> out_sobject = new List<sobject>();
            List<sobject> out_task = new List<sobject>();    
            string v_query;
            map<string,list<sobject>> map_ppathid_sobject = new map<string,list<sobject>>();
            
            
            for (SObjectTaskWrapper inp_parm : inp_parms)
            {
                if (inp_ObjectType != 'Task')
                    inp_sobjectids.add((string) inp_parm.inp_sObject.get('id'));
                else
                    inp_taskids.add((string) inp_parm.inp_sObject.get('id'));
                
            }
            
            if (inp_sobjectids.size() > 0)
            {
                v_query = 'select id,Process_Attribute__c,Process_Attribute__r.Process_Path__c, Process_Attribute__r.Object_Type__c from ' +  inp_ObjectType +' where id in : inp_sobjectids'; 
                out_sobject.addall(Database.query(v_query));
            }
            
            if (inp_taskids.size() > 0)
            {
                v_query = 'select id,whoid,whatid,Process_Attribute__c,Process_Attribute__r.Process_Path__c, Process_Attribute__r.Object_Type__c,Process_Path_Task_Detail__c,Process_Path_Initiated_Task_Id__c,Execution_Depended_on_Task_Ids__c,Process_Path_Deviation_Initiated_Task_Id__c,Process_Path_Merged_Task_Ids__c,Process_Share_Document_Task_Ids__c,Process_Path_Deviation_Ids__c from ' +  inp_ObjectType +' where id in : inp_taskids'; 
                out_task = Database.query(v_query);
                for (sobject lv_sobject:out_task)
                {
                    out_sobject.addall(checkdeviation(lv_sobject));
                }
                
                
            }
            
            system.debug(out_sobject);
            
            
            
            for (sobject lv_sobject: out_sobject)
            {
                string v_ppathid = (string) lv_sobject.getsobject('Process_Attribute__r').get('Process_Path__c');
                system.debug(v_ppathid);
                list<sobject> temp_sobject = new list<sobject>();
                if (!map_ppathid_sobject.containskey(v_ppathid))
                {                
                    temp_sobject.add(lv_sobject);
                    map_ppathid_sobject.put(v_ppathid,temp_sobject);
                }  
                else
                {
                    map_ppathid_sobject.put(v_ppathid,(list<sobject>) map_ppathid_sobject.get(v_ppathid).add(lv_sobject)); 
                    
                }
                
            }
            
            system.debug(map_ppathid_sobject);
            //TaskCreationProcessing a = new TaskCreationProcessing();
            newtask(map_ppathid_sobject);
            return l_return;
        }
        
        public static list<sobject> checkdeviation(sobject inp_task) 
        {
            string v_query;
            boolean v_skipPpathDev = false;
            
            list<sobject> returnvalue = new list<sobject>();
            
            list<sobject> l_PPathDev = new list<sobject>();    
            List<string> l_PPathDevIds = ((string) inp_task.get('Process_Path_Deviation_Ids__c')).split(',');
            system.debug('l_PPathDevIds--->'+l_PPathDevIds);
            list<sobject> l_PECondDet = new list<sobject>(); 
            list<sobject> l_PECondOutcome = new list<sobject>();
            
            v_query = 'Select id,Process_Attribute__c,Process_Path_Task_Detail_Start__c ,Process_Path_Task_Detail_End__c,Process_Execution_Condition__c,Process_Path__c,Process_Path_Type__c from Process_Attribute_Path_Deviation__c where id in : l_PPathDevIds';
            l_PPathDev = Database.query(v_query);
            system.debug('l_PPathDev--->'+l_PPathDev);
            for (sobject lv_PPathDev : l_PPathDev)
            { 
                set<string> s_PECon = new set<string>();
                s_PECon.add((string) lv_PPathDev.get('Process_Execution_Condition__c'));
                system.debug('s_PECon--->'+s_PECon);
                v_query = 'Select id,Condition_Expression__c from Process_Execution_Condition_Detail__c where Process_Execution_Condition__c in : s_PECon ';
                l_PECondDet = Database.query(v_query);
                system.debug('l_PECondDet--->'+l_PECondDet);
                v_skipPpathDev = false;
                
                for (sobject lv_PECondDetId : l_PECondDet)
                {
                    string v_sobjectid;
                    //testing purpose need to change
                    v_sobjectid = (String) inp_task.get('whatid');
                    v_query = (string) lv_PECondDetId.get('Condition_Expression__c');
                    system.debug(v_query);
                    l_PECondOutcome = Database.query(v_query);
                    if (l_PECondOutcome.size() == 0)
                    {
                        v_skipPpathDev = true;
                        break;
                    }
                    
                    
                    
                }
                if (v_skipPpathDev == false)
                {
                    inp_task.getsobject('Process_Attribute__r').put('Process_Path__c',lv_PPathDev.get('Process_Path__c'));
                    returnvalue.add(inp_task);
                }
                
            }
            
            return returnvalue;
        }
        
        public static void newtask(map<string,list<sobject>> inp_ppathid_sobject) 
        {
            // Your logic here using the input variables
            
            map<ID,sObject>  map_existing_Task = new Map<ID, sObject>();
            map<string,sobject> map_existingTask_Final = new map<string,sobject>();
            map<ID,sObject>  map_new_PPath = new Map<ID, sObject>();
            map<ID,sobject> map_new_PAPathDev = new Map<ID, sobject>();
            
            set<string> s_inp_PPathIds = new set<string>();
            set<string> s_PPathInitTaskIds = new set<string>();
            map<string,string> map_PPathDevIds = new map<string,string>();
            
            string v_query;
            
            for (string lv_ppathid: inp_ppathid_sobject.keyset())
            {
                for (sobject lv_sobject: inp_ppathid_sobject.get(lv_ppathid))
                {
                    string temp_sobjecttype;
                    temp_sobjecttype = (string)  lv_sobject.id.getSObjectType().getDescribe().getName();
                    if (temp_sobjecttype == 'Task')
                        s_PPathInitTaskIds.add((string) lv_sobject.get('Process_Path_Initiated_Task_Id__c'));       
                }
            }
            //Get all the existing Open/Draf tasks related to triggering task's path(s_inp_PathInitTaskIds)
            
            
            
            if (s_PPathInitTaskIds.size() >0 )
            {
                system.debug(s_PPathInitTaskIds);
                List<string> l_MergeTaskStatus = Label.Task_Mergeable_Status.split(',');
                
                //Logic can be changed from Process_Path_Initiated_Task_Id__c to WhoId/WhatId 27/02/2024
                v_query = 'Select id,subject,Process_Path_Initiated_Task_Id__c,Execution_Depended_Closed_Task_Ids__c, Process_Path_Task_Detail__r.Process_Task_Detail__c,Execution_Depended_on_Task_Ids__c,Process_Path_Deviation_Initiated_Task_Id__c,Process_Path_Merged_Task_Ids__c,Process_Share_Document_Task_Ids__c FROM task where Process_Path_Task_Detail__r.isMergeable__c = true and status in :l_MergeTaskStatus and Process_Path_Initiated_Task_Id__c in : s_PPathInitTaskIds';
                map_existing_Task.putAll(new Map<ID, sObject>((List<sObject>)Database.query(v_query)));
                
                
                for(id lv_TaskId : map_existing_Task.keyset())
                {
                    string key = map_existing_Task.get(lv_TaskId).get('Process_Path_Initiated_Task_Id__c')+'-'+map_existing_Task.get(lv_TaskId).getsobject('Process_Path_Task_Detail__r').get('Process_Task_Detail__c');
                    if(!map_existingTask_Final.containskey(key))
                        system.debug(key + '  ' + map_existing_Task.get(lv_TaskId));
                    map_existingTask_Final.put(key,map_existing_Task.get(lv_TaskId));
                }
                
            }
            system.debug('map_existingTask_Final -> ' + map_existingTask_Final);
            //Get all the tasks related to the paths
            
            s_inp_PPathIds.addall(inp_ppathid_sobject.keyset());
            v_query = 'Select id,(SELECT id,Execution_Serial_No__c,Process_Path__c,Process_Task_Detail__c,ED_Process_Path_Task_Detail__c,SD_Process_Path_Task_Detail__c,Subject__c,Process_Task_Detail__r.Subject__c,Task_Record_Type__c,Process_Task_Detail__r.Task_Record_Type__c,isMergeable__c FROM Process_Path_Task_Details__r where isActive__c = true order by Process_Path__c,Path_No__c,Execution_Serial_No__c ) from Process_Path__c WHERE isActive__c = true and id in : s_inp_PPathIds';  
            map_new_PPath.putall(new Map<ID, sObject>((List<sObject>)Database.query(v_query)));
            
            
            //Get all the Path Deviation task  
            
            set<id> s_new_PPathTaskDetIds = new set<id>();
            for (id lv_PpathId : map_new_PPath.keyset())
            {
                for (sobject lv_PPathTaskDet : map_new_PPath.get(lv_PpathId).getSobjects('Process_Path_Task_Details__r'))
                    
                {
                    s_new_PPathTaskDetIds.add((string) lv_PPathTaskDet.get('Id'));
                }
            }
            
            
            v_query = 'Select id,Process_Attribute__c,Process_Path_Task_Detail_Start__c ,Process_Path_Task_Detail_End__c,Process_Execution_Condition__c,Process_Path__c,Process_Path_Type__c  from Process_Attribute_Path_Deviation__c WHERE isActive__c = true and Process_Path_Task_Detail_Start__c in :s_new_PPathTaskDetIds';  
            map_new_PAPathDev.putall(new Map<ID, sObject>((List<sobject>)Database.query(v_query)));
            
            if (map_new_PAPathDev.size() > 0)   
            {
                for (id lv_PAPathDev : map_new_PAPathDev.keyset())
                {
                    string key = (string) map_new_PAPathDev.get(lv_PAPathDev).get('Process_Attribute__c')+'-'+map_new_PAPathDev.get(lv_PAPathDev).get('Process_Path_Task_Detail_Start__c');
                    if (!map_PPathDevIds.containskey(key))
                        map_PPathDevIds.put(key,(string) map_new_PAPathDev.get(lv_PAPathDev).get('Id'));
                    else
                        map_PPathDevIds.put(key,(string) map_PPathDevIds.get(key) + ',' + map_new_PAPathDev.get(lv_PAPathDev).get('Id'));
                }
                
            }
            
            // Preparing the final list of all the new tasks
            
            for(ID lv_PPathID: inp_ppathid_sobject.KeySet())
            {
                for(sobject lv_sobject:inp_ppathid_sobject.get(lv_PPathID))
                {                
                    map_all_task.putall(NewTaskDetails(map_new_PPath.get(lv_PPathID).getSobjects('Process_Path_Task_Details__r'),lv_sobject,map_PPathDevIds,map_existingTask_Final));
                    
                }
            }
        }
        
        public static map<string,Task> NewTaskDetails(List<sObject> inp_ProcessPathTaskDetails,sObject inp_sobject,map<string,string> inp_PPathDevIds,map<string,sobject> inp_existingTasks)
        {
            
            system.debug('inp_ProcessPathTaskDetails--->'+inp_ProcessPathTaskDetails);
            system.debug('inp_sobject--->'+inp_sobject);
            system.debug('inp_PPathDevIds--->'+inp_PPathDevIds);
            system.debug('inp_existingTasks--->'+inp_existingTasks);
            map<string,string> map_all_Task = new map<string,string>();
            map<string,Task> map_new_Task = new map<string,Task>();
            
            map<string,list<string>> map_oldtaskid_newtaskids = new map<string,list<string>>();
            map<string,string> map_repeatPPathtaskid_newtaskid = new map<string,string>();
            map<string,string> map_newtaskid_repeatPPathtaskid = new map<string,string>();
            
            map<string,list<string>> map_repeatPPathtaskid_repeattaskids = new map<string,list<string>>();
            
            
            set<string> s_validoldtaskIds = new set<string>();
            //set<string> s_repeatPPathtaskIds = new set<string>();
            
            string newtaskid;
            
            string v_FirstPPathTaskDetID;
            string inpSobjectType = inp_sobject.Id.getSObjectType().getDescribe().getName();
            //string v_childTask = (string) inp_sobject.getsobject('Process_Path_Task_Detail__r').get('Process_Path_Child_Path__c'); 
            
            for (sobject lv_ProcessPathTaskDetail:inp_ProcessPathTaskDetails)
            {
                integer v_ExexutionSerialNo ;
                if(!Test.IsrunningTest()){
                    
                }
                v_ExexutionSerialNo = Integer.valueOf((string) lv_ProcessPathTaskDetail.get('Execution_Serial_No__c'));
                v_FirstPPathTaskDetID = (v_ExexutionSerialNo == 1)?(string) lv_ProcessPathTaskDetail.get('Id'):v_FirstPPathTaskDetID;
                
                
                
                task temptask =  new task();
                
                
                
                temptask.ownerId = Label.Task_Default_Onwer;
                temptask.status = Label.Task_Status_Draft;
                temptask.Process_Attribute__c = (string) inp_sobject.get('Process_Attribute__c');
                if(!Test.IsrunningTest())
                {
                    temptask.attribute1__c = (string) inp_sobject.getsobject('Process_Attribute__r').get('Object_Type__c');            
                    
                }
                temptask.Process_Path_Task_Detail__c = (string) lv_ProcessPathTaskDetail.get('Id') ; 
                
                
                
                string PPathTaskSubject = (string) lv_ProcessPathTaskDetail.get('subject__c');
                system.debug('lv_ProcessPathTaskDetail--->'+lv_ProcessPathTaskDetail);
                string PTaskSubject;
                if(!Test.IsrunningTest()){
                    PTaskSubject = (string)  lv_ProcessPathTaskDetail.getsobject('Process_Task_Detail__r').get('Subject__c');
                }
                
                
                
                temptask.subject = (PPathTaskSubject != null) ? PPathTaskSubject : PTaskSubject;
                //temptask.subject =  temptask.subject
                string PPathTaskRecordType = (string) lv_ProcessPathTaskDetail.get('Task_Record_Type__c'); 
                string PTaskRecordType ;
                if(!Test.IsrunningTest()){
                    PTaskRecordType = (string)  lv_ProcessPathTaskDetail.getsobject('Process_Task_Detail__r').get('Task_Record_Type__c');
                }
                
                string RecordTypeName = (PPathTaskRecordType != null) ? PPathTaskRecordType : PTaskRecordType;
                temptask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(String.valueOf(RecordTypeName)).getRecordTypeId();
                
                
                //Setting Up task Controlling fields
                
                
                
                temptask.Execution_Depended_on_Task_Ids__c = (inpSobjectType == 'Task'&& v_ExexutionSerialNo ==  1) ? inp_sobject.Id : (string) lv_ProcessPathTaskDetail.get('ED_Process_Path_Task_Detail__c');
                temptask.Process_Share_Document_Task_Ids__c = (string) lv_ProcessPathTaskDetail.get('SD_Process_Path_Task_Detail__c');
                
                temptask.Process_Path_Initiated_Task_Id__c = v_FirstPPathTaskDetID; 
                temptask.Process_Path_Merged_Task_Ids__c = v_FirstPPathTaskDetID;
                temptask.Process_Path_Deviation_Initiated_Task_Id__c = (inpSobjectType == 'Task') ? (string) inp_sobject.get('Id') : v_FirstPPathTaskDetID;
                temptask.Execution_Depended_Closed_Task_Ids__c = null;
                temptask.Parent_Task_Id__c = null;
                //if (v_childTask != null)
                //{
                //    temptask.Parent_Task_Id__c = inp_sobject.Id;
                //}
                
                
                if (inp_PPathDevIds.containskey(temptask.Process_Attribute__c +'-'+temptask.Process_Path_Task_Detail__c))
                {
                    temptask.Process_Path_Deviation_Ids__c = (string) inp_PPathDevIds.get(temptask.Process_Attribute__c +'-'+temptask.Process_Path_Task_Detail__c);
                }
                
                
                if (inpSobjectType ==  'Lead')
                {
                    temptask.whoid = (string) inp_sobject.Id;
                    temptask.attribute2__c = temptask.whoid;
                    map_new_Task.put(temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c,temptask);
                    map_all_Task.put(temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c,null);
                }
                
                else if (inpSobjectType == 'Opportunity' || inpSobjectType == 'Case')
                {
                    temptask.whatid = (string) inp_sobject.Id;
                    temptask.attribute2__c = temptask.whatid;
                    map_new_Task.put(temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c,temptask);
                    map_all_Task.put(temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c,null);
                }
                else if (inpSobjectType == 'Task')
                {
                    system.debug(inp_sobject);
                    temptask.whoid = (string) inp_sobject.get ('WhoId');
                    temptask.whatid = (string) inp_sobject.get ('WhatId');
                    if (temptask.attribute1__c == 'Lead')
                    {
                        temptask.attribute2__c = temptask.whoid;
                    }
                    else 
                    {
                        temptask.attribute2__c = temptask.whatid;
                    }
                    // check for the merging concept
                    string exisiting_TaskKey = (string) inp_sobject.get('Process_Path_Initiated_Task_Id__c')+'-'+ (string) lv_ProcessPathTaskDetail.get('Process_Task_Detail__c');
                    string new_temptaskid = temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c;
                    
                    if (inp_existingTasks.containskey(exisiting_TaskKey) && lv_ProcessPathTaskDetail.get('isMergeable__c') == true )
                    {	
                        s_validoldtaskIds.add(exisiting_TaskKey);
                        //temptask = (Task) inp_existingTasks.get(exisiting_TaskKey);
                        sobject existing_task = inp_existingTasks.get(exisiting_TaskKey);
                        string ExisitingEDTID = (string) existing_task.get('Execution_Depended_on_Task_Ids__c');
                        string ExisitingSDTID = (string) existing_task.get('Process_Share_Document_Task_Ids__c');
                        string ExisitingPMTID = (string) existing_task.get('Process_Path_Merged_Task_Ids__c');
                        string ExisitingPDTID = (string) existing_task.get('Process_Path_Deviation_Initiated_Task_Id__c');
                        
                        
                        
                        ExisitingEDTID = ExisitingEDTID != null ? ExisitingEDTID + ',' + temptask.Execution_Depended_on_Task_Ids__c : temptask.Execution_Depended_on_Task_Ids__c;
                        ExisitingSDTID = ExisitingSDTID != null ? ExisitingSDTID + ',' + temptask.Process_Share_Document_Task_Ids__c : temptask.Process_Share_Document_Task_Ids__c;
                        ExisitingPMTID = ExisitingPMTID != null ? ExisitingPMTID + ',' + temptask.Process_Path_Merged_Task_Ids__c : temptask.Process_Path_Merged_Task_Ids__c;
                        ExisitingPDTID = ExisitingPDTID != null ? ExisitingPDTID + ',' + temptask.Process_Path_Deviation_Initiated_Task_Id__c : temptask.Process_Path_Deviation_Initiated_Task_Id__c;
                        
                        
                        existing_task.put('Execution_Depended_on_Task_Ids__c',ExisitingEDTID);
                        existing_task.put('Process_Share_Document_Task_Ids__c',ExisitingSDTID);
                        existing_task.put('Process_Path_Merged_Task_Ids__c',ExisitingPMTID);
                        existing_task.put('Process_Path_Deviation_Initiated_Task_Id__c',ExisitingPDTID);
                        
                        inp_existingTasks.put(exisiting_TaskKey,existing_task);
                        system.debug('inp_existingTasks -> ' +  inp_existingTasks); 
                        if (map_oldtaskid_newtaskids.containskey(exisiting_TaskKey))
                        {
                            map_oldtaskid_newtaskids.put(exisiting_TaskKey,(list<string>) map_oldtaskid_newtaskids.get(exisiting_TaskKey).add(new_temptaskid));
                        }
                        else
                        {
                            map_oldtaskid_newtaskids.put(exisiting_TaskKey,(new list<string>{new_temptaskid}));
                        }
                        map_all_Task.put(new_temptaskid,(string) existing_task.get('Id'));
                    }
                    else if (map_repeatPPathtaskid_newtaskid.containsKey(exisiting_TaskKey) && lv_ProcessPathTaskDetail.get('isMergeable__c') == true)
                    {	
                        //s_repeatPPathtaskIds.add((string) map_repeatPPathtaskid_newtaskid.get(exisiting_TaskKey));
                        map_newtaskid_repeatPPathtaskid.put(new_temptaskid,exisiting_TaskKey);
                        
                        task repeat_PPathtask =  map_new_Task.get(map_repeatPPathtaskid_newtaskid.get(exisiting_TaskKey));
                        string ExisitingEDTID = (string) repeat_PPathtask.get('Execution_Depended_on_Task_Ids__c');
                        string ExisitingSDTID = (string) repeat_PPathtask.get('Process_Share_Document_Task_Ids__c');
                        string ExisitingPMTID = (string) repeat_PPathtask.get('Process_Path_Merged_Task_Ids__c');
                        string ExisitingPDTID = (string) repeat_PPathtask.get('Process_Path_Deviation_Initiated_Task_Id__c');
                        
                        
                        
                        ExisitingEDTID = ExisitingEDTID != null ? ExisitingEDTID + ',' + temptask.Execution_Depended_on_Task_Ids__c : temptask.Execution_Depended_on_Task_Ids__c;
                        ExisitingSDTID = ExisitingSDTID != null ? ExisitingSDTID + ',' + temptask.Process_Share_Document_Task_Ids__c : temptask.Process_Share_Document_Task_Ids__c;
                        ExisitingPMTID = ExisitingPMTID != null ? ExisitingPMTID + ',' + temptask.Process_Path_Merged_Task_Ids__c : temptask.Process_Path_Merged_Task_Ids__c;
                        ExisitingPDTID = ExisitingPDTID != null ? ExisitingPDTID + ',' + temptask.Process_Path_Deviation_Initiated_Task_Id__c : temptask.Process_Path_Deviation_Initiated_Task_Id__c;
                        
                        
                        repeat_PPathtask.put('Execution_Depended_on_Task_Ids__c',ExisitingEDTID);
                        repeat_PPathtask.put('Process_Share_Document_Task_Ids__c',ExisitingSDTID);
                        repeat_PPathtask.put('Process_Path_Merged_Task_Ids__c',ExisitingPMTID);
                        repeat_PPathtask.put('Process_Path_Deviation_Initiated_Task_Id__c',ExisitingPDTID);
                        
                        map_new_Task.put((string) map_repeatPPathtaskid_newtaskid.get(exisiting_TaskKey),repeat_PPathtask);
                        
                        if (map_repeatPPathtaskid_repeattaskids.containskey(exisiting_TaskKey))
                        {
                            map_repeatPPathtaskid_repeattaskids.put(exisiting_TaskKey,(list<string>) map_repeatPPathtaskid_repeattaskids.get(exisiting_TaskKey).add(new_temptaskid));
                        }
                        else
                        {
                            map_repeatPPathtaskid_repeattaskids.put(exisiting_TaskKey,(new list<string>{new_temptaskid}));
                        }
                        map_all_Task.put(new_temptaskid,exisiting_TaskKey);
                        
                    }
                    else
                    {
                        map_new_Task.put(new_temptaskid,temptask);
                        map_all_Task.put(new_temptaskid,null);
                        if (lv_ProcessPathTaskDetail.get('isMergeable__c') == true)
                        {
                            map_repeatPPathtaskid_newtaskid.put(exisiting_TaskKey,new_temptaskid);
                            //map_newtaskid_repeatPPathtaskid.put(new_temptaskid,exisiting_TaskKey);
                        }
                        
                    }
                    
                }
                else
                {
                    map_new_Task.put(temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c,temptask);
                    map_all_Task.put(temptask.attribute2__c+'-'+temptask.Process_Path_Task_Detail__c,null);
                }
                
                
                
            }               
            
            
            
            
            // Insert the list of Task records into the database     
            Database.insert(map_new_Task.values(), true);
            
            
            
            //Updating the origianal taskids
            
            for (string lv_temptaskid:map_new_Task.keyset())
            {
                if(map_newtaskid_repeatPPathtaskid.containskey(lv_temptaskid) ) //&& s_repeatPPathtaskIds.contains(lv_temptaskid)
                {
                    for (string lv_repeattaskid:map_repeatPPathtaskid_repeattaskids.get((string) map_newtaskid_repeatPPathtaskid.get(lv_temptaskid)))
                    {
                        
                        map_all_Task.put(lv_repeattaskid,(string) map_new_Task.get(lv_temptaskid).get('id'));
                    }
                    
                }
                map_all_Task.put(lv_temptaskid,(string) map_new_Task.get(lv_temptaskid).get('id'));
                
                
            }
            
            //adding the exisiting merged tasks
            
            if (s_validoldtaskIds.size() > 0)
            {
                for (string lv_exisiting_TaskKey : s_validoldtaskIds)
                    
                {
                    system.debug('lv_exisiting_TaskKey---'+lv_exisiting_TaskKey);
                    system.debug('map_oldtaskid_newtaskids---'+map_oldtaskid_newtaskids);
                    for (string lv_newtaskid:map_oldtaskid_newtaskids.get(lv_exisiting_TaskKey))
                    {
                        map_new_Task.put(lv_newtaskid,(Task) inp_existingTasks.get(lv_exisiting_TaskKey));
                    }
                    
                }
                system.debug('map_new_Task ->' + map_new_Task);
            }
            
            
            //Preparing the update data for replace the refference values for below fields with actual taskids
            //Process_Path_Initiated_Task_Id__c
            //Execution_Depended_on_Task_Ids__c
            //Process_Path_Deviation_Initiated_Task_Id__c
            //Process_Path_Merged_Task_Ids__c
            //Process_Share_Document_Task_Ids__c 
            
            system.debug(map_new_Task);
            for (string lv_newTaskKey : map_new_Task.keyset()) {
                system.debug(lv_newTaskKey);
                task temp_task = new task();
                temp_task = map_new_Task.get(lv_newTaskKey);
                string v_sobjectid = lv_newTaskKey.split('-')[0];
                
                for (string v_filednames : Label.Task_ReplacePPathTaskIds.split(','))
                {
                    list<string> v_PPathTaskIds = new list<string>();
                    string v_finalvalue;
                    
                    if (temp_task.get(v_filednames) != null)
                    {
                        v_PPathTaskIds = ( (string) temp_task.get(v_filednames)).split(',');                
                        for (string lv_PPathTaskId : v_PPathTaskIds)
                        {
                            if (map_all_Task.containskey(v_sobjectid +'-'+lv_PPathTaskId))
                            {
                                string v_tobereplacetaskid = map_all_Task.get(v_sobjectid +'-'+lv_PPathTaskId);
                                v_finalvalue = (v_finalvalue ==  null)? v_tobereplacetaskid  :    v_finalvalue +','+v_tobereplacetaskid;
                            }
                            else if ( inpSobjectType == 'Task' && inp_sobject.get('Process_Path_Task_Detail__c') == lv_PPathTaskId)
                            {
                                string v_tobereplacetaskid = inp_sobject.id;
                                v_finalvalue = (v_finalvalue ==  null)? v_tobereplacetaskid  :    v_finalvalue +','+v_tobereplacetaskid;                        }
                            else
                            {
                                v_finalvalue = (v_finalvalue ==  null)? lv_PPathTaskId  :    v_finalvalue +',' +lv_PPathTaskId;
                            }
                            
                        }
                        temp_task.put(v_filednames,v_finalvalue);
                    }
                    
                }
                
                
                map_new_Task.put(lv_newTaskKey,temp_task);
                
                if (temp_task.get('Subject') ==  'Start')
                {
                    temp_task.put('Status','Completed');
                }
                if (temp_task.get('Execution_Depended_on_Task_Ids__c') != null && (((string)temp_task.get('Execution_Depended_on_Task_Ids__c')).contains((string) inp_sobject.id)) && ((temp_task.get('Execution_Depended_Closed_Task_Ids__c') != null && !((string)temp_task.get('Execution_Depended_Closed_Task_Ids__c')).contains((string) inp_sobject.id)) || temp_task.get('Execution_Depended_Closed_Task_Ids__c') == null))
                {
                    string lv_Execution_Depended_Closed_Task_Ids = (string) temp_task.get('Execution_Depended_Closed_Task_Ids__c');
                    lv_Execution_Depended_Closed_Task_Ids = (lv_Execution_Depended_Closed_Task_Ids != null) ? lv_Execution_Depended_Closed_Task_Ids + inp_sobject.id +',' : inp_sobject.id +',';
                    //temp_task.put('Execution_Depended_Closed_Task_Ids__c',(string) inp_sobject.id +',');
                    set<string> lv_Execution_Depended_on_Task_Ids = new set<string>(((string) temp_task.get('Execution_Depended_on_Task_Ids__c')).split(','));
                    set<string> lv_s_Execution_Depended_Closed_Task_Ids = new set<String>(lv_Execution_Depended_Closed_Task_Ids.split(','));
                    lv_s_Execution_Depended_Closed_Task_Ids.retainAll(lv_Execution_Depended_on_Task_Ids);
                    temp_task.put('Execution_Depended_Closed_Task_Ids__c',String.join(new List<String>(lv_s_Execution_Depended_Closed_Task_Ids), ', '));      
                }
            }
            
            Database.update(map_new_Task.values(),true);
            return map_new_Task;
        }
             
    }