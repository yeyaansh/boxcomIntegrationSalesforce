public with sharing class BoxMethods {
    
    

    // wrapper class for -> respnse from Box.com for -> getAllItemsFromFolder
    public class GetAllItemsFromFolderResponse{
        @AuraEnabled public Integer total_count;	//5
        @AuraEnabled public List<FolderEntry> entries;
        @AuraEnabled public Integer offset;	//0
        // public Integer limit;	//100
        @AuraEnabled public Integer limitValue;	//100
        @AuraEnabled public List<FolderOrder> order;

        public GetAllItemsFromFolderResponse(Integer total_count, List<FolderEntry> entries, Integer offset, Integer limitValue, List<FolderOrder> order )
        {
        this.total_count = total_count;
        this.entries = entries;
        this.offset = offset;
        this.limitValue = limitValue;
        this.order = order;
        }
	}

    // wrapper class for folderEntry
    public class FolderEntry {
		@AuraEnabled public String type;	//folder
		@AuraEnabled public String id;	//376443735718
		@AuraEnabled public String sequence_id;	//0
		@AuraEnabled public String etag;	//0
		@AuraEnabled public String name;	//8th Semester Syllabus

        public FolderEntry(String type, String id, String sequence_id, String etag, String name)
        {
            this.type = type;
            this.id = id;
            this.sequence_id = sequence_id;
            this.etag = etag;
            this.name = name;
        }
	}

    // wrapper class for folderOrder
	public class FolderOrder {
		// public String by;	//type
		@AuraEnabled public String byVal;	//type
		@AuraEnabled public String direction;	//ASC

        public FolderOrder(String byVal,String direction){
            this.byVal = byVal;
            this.direction = direction;
        }
	}


    // wrapper class for response message
    public class ResponseFromBox {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public GetAllItemsFromFolderResponse data;

        // for success
        public ResponseFromBox(GetAllItemsFromFolderResponse data)
        {
        this.isSuccess = true;
        this.data = data;
        }

        // for error
        public ResponseFromBox(String  message)
        {
        this.isSuccess = false;
        this.message = message;
        }
    }


    @AuraEnabled
    public static ResponseFromBox getAllItemsFromFolder(String folderId){
        try {
            folderId = folderId.trim();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('callout:BoxNamedCredential/folders/'+folderId+'/items');
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200)
            {
                Map<String, Object> fullResponse = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
            Integer total_count = (Integer)fullResponse.get('total_count');
            // get the list key-values
            List<Object> entries = (List<Object>)fullResponse.get('entries');
            List<FolderEntry> folderEntryList = new List<FolderEntry>();
            for(Object obj : entries)
            {
                Map<String, Object> singleMap = (Map<String, Object>)obj;
                String type = (String)singleMap.get('type');
                String id = (String)singleMap.get('id');
                String sequence_id = (String)singleMap.get('sequence_id');
                String etag = (String)singleMap.get('etag');
                String name = (String)singleMap.get('name');
                
                FolderEntry singleFolderEntry = new FolderEntry(type, id, sequence_id, etag, name);
                folderEntryList.add(singleFolderEntry);
            }
            Integer offset = (Integer)fullResponse.get('offset');
            Integer limitVal = (Integer)fullResponse.get('limit');
            // get the list key-values
            List<Object> order = (List<Object>)fullResponse.get('order');
            List<FolderOrder> folderOrderList = new List<FolderOrder>();
            for(Object obj : order)
            {
                Map<String, Object> singleMap = (Map<String, Object>)obj;
                String byVal = (String) singleMap.get('by');
                String direction = (String) singleMap.get('direction');
                
                FolderOrder singleFolderOrder = new FolderOrder(byVal,direction);
                
                folderOrderList.add(singleFolderOrder);
            }


            GetAllItemsFromFolderResponse getAllItemsFromFolderResponse = new GetAllItemsFromFolderResponse(total_count, folderEntryList, offset,  limitVal, folderOrderList );

            return new  ResponseFromBox(getAllItemsFromFolderResponse);
            }

            else if(res.getStatusCode() == 401)
            {
                System.debug(LoggingLevel.ERROR, res.getBody());
                return new ResponseFromBox('Session expired. Please contact your administrator.');
            }

            else if(res.getStatusCode() == 404)
            {
                System.debug(LoggingLevel.ERROR, res.getBody());
                return new ResponseFromBox('The requested folder was not found. Please contact your administrator.');
            }

            else if(res.getStatusCode() == 500)
            {
                System.debug(LoggingLevel.ERROR, res.getBody());
                return new ResponseFromBox('Unable to fetch files at the moment. Please try again later.');
            }

            else {
                System.debug(LoggingLevel.ERROR, res.getBody());
                return new ResponseFromBox( 'Something unexpected happened. Please try again later.');
            }
            
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Box Callout: Exception: '+e.getMessage()+ ' |'+e.getStackTraceString());
            return new ResponseFromBox('Unable to connect to file storage. Please try again later.');
        }
    }

}