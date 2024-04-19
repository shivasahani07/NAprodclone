public without sharing class SharePointMaster {
    
    @AuraEnabled
    public static string fetchDefaultPath(String base64,String fileName,Id docHandlerId){
        //Id documentId = 'a0IBl000000gLBTMA2';
        String file_Path = '';
        String main_Default_Path = System.Label.SharePointDefaultPath;//'Shared%20Documents%2FMain%20Folder';
        system.debug('folderName'+main_Default_Path);
        main_Default_Path = main_Default_Path.replaceAll(' ','%20');
        system.debug('folderName'+main_Default_Path); 
        List<Document_Handler__c> docHandlerList = new List<Document_Handler__c>();
        docHandlerList = [SELECT Id,File_Path__c
                          From Document_Handler__c
                          WHERE Id =: docHandlerId Limit 1];
        
        if(!docHandlerList.isEmpty()){
            List<String> s_Path = docHandlerList[0].File_Path__c.split('/');
            system.debug('s_Path::'+s_Path);
            for(String path : s_Path){
                if(CheckParentFilePath(main_Default_Path,path)){
                    createFolder(main_Default_Path + '/'+path);
                }
                main_Default_Path = main_Default_Path + '/'+path;
            }
            
            system.debug('main_Default_Path::'+main_Default_Path);
            file_Path = createFile(base64,fileName,main_Default_Path);
        }
        system.debug('file_Path::'+file_Path);
        return file_Path;
    }
    public static Boolean CheckParentFilePath(String default_Path,String parent_Path){
        Boolean newFolderCreation = true;
        
        Map<String,List<Object>> responseMap = new Map<String,List<Object>>();
        Map<String,Object> filesResponse = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.getAllFilesAndFoldersInSites(default_Path,'Files'));
        Map<String,Object> foldersResponse = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.getAllFilesAndFoldersInSites(default_Path,'Folders'));
        system.debug('filesResponse::'+filesResponse);
        system.debug('foldersResponse::'+foldersResponse);
        if(filesResponse.containsKey('d') && foldersResponse.containsKey('d')){
            Map<String,Object> resultFileMap = (Map<String,Object>) filesResponse.get('d');
            Map<String,Object> resultFolderMap = (Map<String,Object>) foldersResponse.get('d');
            system.debug('Files::::::'+resultFileMap.get('results'));
            responseMap.put('files',(List<Object>) resultFileMap.get('results'));
            responseMap.put('folders',(List<Object>) resultFolderMap.get('results'));
        }
        system.debug('responseMap::'+responseMap);
        system.debug('folder Name::'+responseMap.get('Name'));
        for(List<Object> obj : responseMap.values()){
            for(Object obj1 : obj){
                if(obj1 != null){
                    system.debug('before::'+obj1);
                    map<string,object> temp = (map<string,object>)obj1;
                    system.debug('OBJ::'+temp);
                    system.debug('Folder Name::'+temp.get('Name'));
                    if(temp != null && temp.ContainsKey('Name') && temp.get('Name') == parent_Path){
                        newFolderCreation = false;
                    }
                }
            }
            
            
        }
        system.debug('responseMap'+responseMap.size());
        return newFolderCreation;
    }
    
    public static void createFolder(String path){
        try {
            system.debug('path::'+path);
            Map<String,Object> responseMap = new Map<String,Object>();
            Map<String,Object> response = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.createFolder(path));
            
            if(response.containsKey('d')){
                responseMap = (Map<String,Object>) response.get('d');
            }
            
            system.debug('responseMap::'+responseMap);
            
            //return responseMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String createFile(String base64, String fileName,String path){
        try {
            String filePath = '';
            system.debug('path--'+path);
            path = path.replaceAll(' ','%20');
            system.debug('path--'+path);
            Map<String,Object> responseMap = new Map<String,Object>();
            Map<String,List<Object>> fileResponseMap = new Map<String,List<Object>>();
            Blob fileContents = EncodingUtil.base64Decode(base64);
            String response = SharePointHandler.createFileUsingBlob(fileContents,fileName,path);
            
            if(response!='Failure'){
                Map<String,Object> res = (Map<String, Object>)JSON.deserializeUntyped(response);
                
                if(res.containsKey('d')){
                    responseMap = (Map<String,Object>) res.get('d');
                    
                    system.debug('responseMap::'+responseMap);
                    system.debug('Author::'+responseMap.get('Author'));
                    map<string,object> temp = (map<string,object>)responseMap.get('Author');
                    system.debug('obbbb::'+temp);
                    system.debug('temp value::'+temp.get('__deferred'));
                    map<string,object> temp1 = (map<string,object>)temp.get('__deferred'); 
                    system.debug('temp1::'+temp1.get('uri'));
                    String toRemoveStart = '_api/Web/GetFileByServerRelativePath(decodedurl=';
                    String toRemoveEnd = ')/Author}';
                    Integer startIndex = String.valueOf(temp1.get('uri')).indexOf(toRemoveStart);
                    Integer endIndex = String.valueOf(temp1.get('uri')).indexOf(toRemoveEnd) + toRemoveEnd.length();
                    system.debug('startIndex::'+startIndex);
                    system.debug('endIndex::'+endIndex);
                    system.debug('String value::'+String.valueOf(temp1.get('uri')));
                    system.debug('inner string::'+String.valueOf(temp1.get('uri')).split('decodedurl='));
                    String finalString = String.valueOf(temp1.get('uri'));
                    finalString = finalString.replace('\'', '');
                    finalString = finalString.replace(')/Author','');
                    finalString = finalString.replace('sites/NortherArc/_api/Web/GetFileByServerRelativePath(decodedurl=/','');
                    system.debug('finalString::'+finalString);
                    filePath = finalString;
                    system.debug('filepath}}}::'+responseMap.get('LinkingUri'));
                    system.debug('filepath}}}::'+responseMap.get('LinkingUrl'));
                    if(String.valueOf(responseMap.get('LinkingUri')) !=null)
                        filePath = String.valueOf(responseMap.get('LinkingUri'));
                }
            }
            
            return filePath;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}