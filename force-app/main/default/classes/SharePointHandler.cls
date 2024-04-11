global without sharing class SharePointHandler {
    
    public static String siteName = 'NortherArc';//System.Label.SharePoint_Site;
    
    public static String getFiles(){
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        system.debug('siteName'+siteName);
        req.setEndpoint('callout:SPSF/sites/'+siteName+'/_api/web/lists/GetByTitle('+'\'Documents\''+')/items');
        req.setMethod('GET');
        
        HTTPResponse res = http.send(req);
        return JSON.serialize(res.getBody());
    }
    
    public static String getAllFilesAndFoldersInSites(String folderName,String type){
        system.debug('folderName'+folderName);
        folderName = folderName.replaceAll(' ','%20');
        system.debug('folderName'+folderName); 
        //folderName = 'Shared%20Documents%2FMain%20Folder';
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        //String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\'/sites/'+siteName+'/Shared%20Documents/'+folderName+'\''+')/'+type;
        String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\'/sites/'+siteName+'/'+folderName+'\''+')/'+type;
        system.debug('url'+url);
        req.setEndpoint('callout:SPSF/'+url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('odata-version','');
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getBody();
        
    }
    
    public static String getFilesOrFolder(String url){
        //https://utillabs.sharepoint.com/sites/UtilitariansProjects/_api/web/GetFolderByServerRelativeUrl('/sites/UtilitariansProjects/Shared%20Documents')/Folders
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        System.debug('URL------'+url);
        req.setEndpoint('callout:SPSF/'+url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('odata-version','');
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getBody();
    }
    
    public static String createFolderInsideSite(String path){
        system.debug('path'+path);
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        String url = siteName+'/_api/web/folders';
        String body = '{\'__metadata\':{\'type\':\'SP.Folder\'},\'ServerRelativeUrl\':\''+'Shared%20Documents/'+path+'\'}';
        
        System.debug(body);
        
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('odata-version','');
        req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('X-RequestDigest','{form_digest_value}');
        req.setBody(body);
        req.setMethod('POST');
        req.setEndpoint('callout:SPSF/sites/'+url);
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        
        if(res.getStatusCode()==200 || res.getStatusCode()==201){
            return 'Success';
        }
        
        return 'Failure';
    }
    
    public static String createFolder(String path){
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        String url = siteName+'/_api/web/folders';
        String body = '{\'__metadata\':{\'type\':\'SP.Folder\'},\'ServerRelativeUrl\':\''+path+'\'}';
        
        System.debug(body);
        
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('odata-version','');
        req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('X-RequestDigest','{form_digest_value}');
        req.setBody(body);
        req.setMethod('POST');
        req.setEndpoint('callout:SPSF/sites/'+url);
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        
        return res.getBody();
    }
    
    public static boolean deleteFolderInsideSite(String folderName){
        folderName = folderName.replace(' ','%20');
        String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\''+folderName+'\')';
        // String url = folderName.replace(' ','%20');
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('If-Match','*');
        req.setHeader('Content-Length', '0');
        req.setHeader('X-HTTP-Method','DELETE');
        req.setHeader('X-RequestDigest','{form_digest_value}');
        
        req.setMethod('POST');
        req.setEndpoint('callout:SPSF/'+url);
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getStatusCode()==200;
    }
    
    
    public static String createFileInsideSite(String folderName,String fileName){
        String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\'/sites/'+siteName+'/'+folderName+'\')/Files/add(url=\''+fileName+'\',overwrite=true)';
        system.debug('url==========>'+url);
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        String body = 'Ly8gUmVxdWVzdCBCb2R5LS0tLQ0KDQp7DQogICJjdXN0b21lcl9ncm91cGluZyI6ICJaMDAxIiwNCiAgInBhcnRuZXJfcm9sZSI6ICJTWTAwMDFYIiwNCiAgImN1c3RvbWVyX25hbWUiOiAiQWtoaWwgSyBHIiwNCiAgInN0cmVldF8yIjogIk5POjgwLEJPTU1BU0FORFJBIElORFVTVFJJQUwgQVJFQSIsDQogICJzdHJlZXRfMyI6ICJBTkVLQUwgVEFMVUssIEhPU1VSIFJPQUQsIiwNCiAgInN0cmVldCI6ICJJTkRVU1RSSUFMIEFSRUEsIENIRU1CQU5PT1IiLA0KICAicG9zdGFsX0NvZGUiOiAiNjgzNTcyIiwNCiAgImNpdHkiOiAiQU5HQU1BTFkiLA0KICAiY291bnRyeSI6ICJJTiIsDQogICJyZWdpb24iOiAzMiwNCiAgImxhbmd1YWdlIjogIkVOIiwNCiAgInRlbGVwaG9uZV9udW1iZXIiOiAiOTI0OTUwMDAwMiIsDQogICJtb2JpbGVfbnVtYmVyIjogIjkyNDk1MDAwMDIiLA0KICAiZW1haWwiOiAibW9vbGFuc2dyb3VwQGdtYWlsLmNvbSIsDQogICJ0YXhfdHlwZSI6ICIwOSIsDQogICJnc3Rpbl9udW1iZXIiOiAiMzJBQUNDTTMyNTlOMVpCIiwNCiAgInBhbl9udW1iZXIiOiAiQUFDQ00zMjU5TiINCn0NCg0KDQovLyBSZXNwb25zZSAtIFN1Y2Nlc3MNCg0Kew0KICAgICJzdGF0dXMiOnRydWUsDQogICAgImN1c3RvbWVyX2lkIjoiV0VXRVBXSUUzMjMyMzIzMiIsDQp9DQoNCi8vIFJlc3BvbnNlIC0gRXJyb3INCg0Kew0KICAgICJzdGF0dXMiOnRydWUsDQogICAgIm1lc3NhZ2UiOiJFcnJvciBtZXNzYWdlIGhlcmUiLA0KfQ0KDQo=';
        
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('Content-Length', '0');
        req.setHeader('X-RequestDigest','{form_digest_value}');
        req.setBody(EncodingUtil.base64Decode(body).toString());
        //request.Credentials = new NetworkCredential(UserName, PassWord);
        req.setMethod('POST');
        req.setEndpoint('callout:SPSF/'+url);
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return JSON.serialize(res.getBody());
    }
    
    public static String createFileUsingBlob(Blob content,String fileName,String folderName){
        String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\''+folderName+'\')/Files/add(url=\''+fileName+'\',overwrite=true)';
        //String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\'/sites/'+siteName+'/'+folderName+'\')/Files/add(url=\''+fileName+'\',overwrite=true)';
        system.debug('url==========>'+url);
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        String body = 'Ly8gUmVxdWVzdCBCb2R5LS0tLQ0KDQp7DQogICJjdXN0b21lcl9ncm91cGluZyI6ICJaMDAxIiwNCiAgInBhcnRuZXJfcm9sZSI6ICJTWTAwMDFYIiwNCiAgImN1c3RvbWVyX25hbWUiOiAiQWtoaWwgSyBHIiwNCiAgInN0cmVldF8yIjogIk5POjgwLEJPTU1BU0FORFJBIElORFVTVFJJQUwgQVJFQSIsDQogICJzdHJlZXRfMyI6ICJBTkVLQUwgVEFMVUssIEhPU1VSIFJPQUQsIiwNCiAgInN0cmVldCI6ICJJTkRVU1RSSUFMIEFSRUEsIENIRU1CQU5PT1IiLA0KICAicG9zdGFsX0NvZGUiOiAiNjgzNTcyIiwNCiAgImNpdHkiOiAiQU5HQU1BTFkiLA0KICAiY291bnRyeSI6ICJJTiIsDQogICJyZWdpb24iOiAzMiwNCiAgImxhbmd1YWdlIjogIkVOIiwNCiAgInRlbGVwaG9uZV9udW1iZXIiOiAiOTI0OTUwMDAwMiIsDQogICJtb2JpbGVfbnVtYmVyIjogIjkyNDk1MDAwMDIiLA0KICAiZW1haWwiOiAibW9vbGFuc2dyb3VwQGdtYWlsLmNvbSIsDQogICJ0YXhfdHlwZSI6ICIwOSIsDQogICJnc3Rpbl9udW1iZXIiOiAiMzJBQUNDTTMyNTlOMVpCIiwNCiAgInBhbl9udW1iZXIiOiAiQUFDQ00zMjU5TiINCn0NCg0KDQovLyBSZXNwb25zZSAtIFN1Y2Nlc3MNCg0Kew0KICAgICJzdGF0dXMiOnRydWUsDQogICAgImN1c3RvbWVyX2lkIjoiV0VXRVBXSUUzMjMyMzIzMiIsDQp9DQoNCi8vIFJlc3BvbnNlIC0gRXJyb3INCg0Kew0KICAgICJzdGF0dXMiOnRydWUsDQogICAgIm1lc3NhZ2UiOiJFcnJvciBtZXNzYWdlIGhlcmUiLA0KfQ0KDQo=';
        
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('Content-Length', '0');
        req.setHeader('X-RequestDigest','{form_digest_value}');
        req.setTimeout(120000);
        //req.setBody(EncodingUtil.base64Decode(body).toString());
        req.setBodyAsBlob(content);
        //system.debug('content'+req.setBodyAsBlob(EncodingUtil.base64Decode(content).toString()));
        
        req.setMethod('POST');
        req.setEndpoint('callout:SPSF/'+url);
        system.debug('content'+content);
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        if(res.getStatusCode()==200){
            return res.getBody();
        }else{
            return 'Failure';
        }
        
    }
    
    public static String deleteFileInsideSite(String folderName){
        folderName = folderName.replace(' ','%20');
        String url = 'sites/'+siteName+'/_api/web/GetFolderByServerRelativeUrl('+'\''+folderName+'\')';
        
        //String url = 'sites/'+siteName+'/_api/web/GetFileByServerRelativeUrl('+'\'/sites/'+siteName+'/'+folderName+'\')';
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('If-Match','*');
        req.setHeader('Content-Length', '0');
        req.setHeader('X-HTTP-Method','DELETE');
        req.setHeader('X-RequestDigest','{form_digest_value}');
        
        req.setMethod('POST');
        req.setEndpoint('callout:SPSF/'+url);
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        return res.getStatusCode()==200?'Success':'Failure';
    }
    
    public static String downloadFile(String path){
        path = path.replace(' ','%20');
        String url = 'sites/'+siteName+'/_api/web/GetFileByServerRelativePath(decodedurl='+'\''+path+'\')/$value';
        
        System.debug('URL----))))'+url);
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        System.debug('URL------'+url);
        req.setEndpoint('callout:SPSF/'+url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('odata-version','');
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getBody();
    }
}