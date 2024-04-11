public without sharing class ProposalDocumentLWCController {
   
    @AuraEnabled(cacheable = true)
    public static Map<String,List<Object>> getFoldersAndFiles(String recId){
        try {
            if(!String.isEmpty(recId)){
                Map<String,List<Object>> responseMap = new Map<String,List<Object>>();

                Opportunity prop = [Select Id,Name,Account.Name,SharePoint_URL__C From Opportunity Where Id=:recId];
                String destination = prop.SharePoint_URL__C;
                //Shared%20Documents%2FForms%2FAllItems%2Easpx&id=%2Fsites%2FNortherArc%2FSh
                destination = destination.remove('https://utillabs.sharepoint.com/sites/NortherArc/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FNortherArc%2F');
                destination = destination.split('&viewid')[0];
                system.debug('destination'+destination);
                //destination = 'Customer%20Projects%2FAB%2FABB%20Inc%2FF2P27415';
               
                Map<String,Object> filesResponse = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.getAllFilesAndFoldersInSites(destination,'Files'));
                Map<String,Object> foldersResponse = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.getAllFilesAndFoldersInSites(destination,'Folders'));

                if(filesResponse.containsKey('d') && foldersResponse.containsKey('d')){
                    Map<String,Object> resultFileMap = (Map<String,Object>) filesResponse.get('d');
                    Map<String,Object> resultFolderMap = (Map<String,Object>) foldersResponse.get('d');

                    responseMap.put('files',(List<Object>) resultFileMap.get('results'));
                    responseMap.put('folders',(List<Object>) resultFolderMap.get('results'));
                }
                
                system.debug('responseMap'+responseMap.size());
                return responseMap;
            }
            return null;
        } catch (Exception e) {
           system.debug(e.getMessage()+'at Line number==>'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static Map<String,List<Object>> getSubFoldersAndFiles(String filesUrl,String foldersUrl){
        try {
            System.debug('FilesUrl----'+filesUrl);
            System.debug('FoldersUrl----'+foldersUrl);

            Map<String,List<Object>> responseMap = new Map<String,List<Object>>();

            Map<String,Object> filesResponse = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.getFilesOrFolder(filesUrl));
            Map<String,Object> foldersResponse = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.getFilesOrFolder(foldersUrl));

            if(filesResponse.containsKey('d') && foldersResponse.containsKey('d')){
                Map<String,Object> resultFileMap = (Map<String,Object>) filesResponse.get('d');
                Map<String,Object> resultFolderMap = (Map<String,Object>) foldersResponse.get('d');

                responseMap.put('files',(List<Object>) resultFileMap.get('results'));
                responseMap.put('folders',(List<Object>) resultFolderMap.get('results'));
            }
            // responseMap.put('files',filesResponse);
            // responseMap.put('folders',foldersResponse);
            return responseMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+'at Line number==>'+e.getLineNumber());
        }
    }

    @AuraEnabled
    public static Map<String,Object> createFolder(String path){
        try {
            system.debug('path'+path);
            Map<String,Object> responseMap = new Map<String,Object>();
            Map<String,Object> response = (Map<String, Object>)JSON.deserializeUntyped(SharePointHandler.createFolder(path));

            if(response.containsKey('d')){
                responseMap = (Map<String,Object>) response.get('d');
            }

            return responseMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteFolderInsideSite(String path){
        try {
            return SharePointHandler.deleteFolderInsideSite(path)?'Success':'Failure';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Object> createFile(String base64, String fileName,String path){
        try {
            system.debug('path--'+path);
            Map<String,Object> responseMap = new Map<String,Object>();

            Blob fileContents = EncodingUtil.base64Decode(base64);
            String response = SharePointHandler.createFileUsingBlob(fileContents,fileName,path);

            if(response!='Failure'){
                Map<String,Object> res = (Map<String, Object>)JSON.deserializeUntyped(response);

                if(res.containsKey('d')){
                    responseMap = (Map<String,Object>) res.get('d');
                }
            }
            
            return responseMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteFileSP(String path){
        try {
            return SharePointHandler.deleteFileInsideSite(path);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string downloadFile(String path){
        try {
            return SharePointHandler.downloadFile(path);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}