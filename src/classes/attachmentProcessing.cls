global with sharing class attachmentProcessing {
    String recId;
    Case c; 
    
    public attachmentProcessing(ApexPages.StandardController controller) {
        recId = controller.getId();
        recId = controller.getRecord().Id;     
        //c = (Case) controller.getRecord();        
        
    }
    public String parentId { 
        get { return '5003900001qjBIlAAM';}
        set;
    }
    @RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        /*
        parentId: The sfdc object Id this file will be attached to
        attachmentId: The record of the current Attachment file being processed
        fileName: Name of the attachment
        contentTye: Content Type of the file being attached
        base64BlobValue: Base64 encoded string of the file piece currently processing
        */
        
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                ParentId = parentId,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert att;            
            //Return the new attachment Id
            return att.Id;
            
        }else{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }
    
    
    public string fileName 
    {    get;set;    }
    
    public Blob fileBody 
    {    get;set;    }
    
    public PageReference UploadFile()
    {
        PageReference pr;
        if(fileBody != null && fileName != null)
        {
            Attachment myAttachment  = new Attachment();
            myAttachment.Body = fileBody;
            myAttachment.Name = fileName;
            myAttachment.ParentId = '5003900001qjBIlAAM';//recId;
            insert myAttachment;
            pr = new PageReference('/apex/DisplayFiles?core.apexpages.request.devconsole=1');//('/' + myAttachment.Id);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }        
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }

    public String attachmentValue {
        get;
        // *** setter is NOT being called ***
        set {
            attachmentValue = value;
            System.debug('value: '+value);
        }
    }
    public Pagereference checkout() {
        System.debug('attachment Id:'+attachmentValue);
        loadAttachment();
        PageReference pr;
        //<a href="ms-word:ofe|u|http://some_WebDav_enabled_address.com/some_Word_document.docx">Open Document in Word</a>
        pr = new PageReference('/apex/DisplayFiles?core.apexpages.request.devconsole=1');//('/' + myAttachment.Id);
        pr = new PageReference('/' + attachmentValue);
	    pr = new PageReference('/data:'+contentType+';content-disposition:attachment;base64,'+base64Value+' target=\"_blank\"');
        pr.setRedirect(true);
        return pr;
        
    }
    //<!-- a href="data:{!contentType};content-disposition:attachment;base64,{!base64Value}">Download file</a --!>
    public String base64Value{get;set;}
    public String contentType{get;set;}
    public void loadAttachment() {
        Attachment att = [Select Id, Body, ContentType From Attachment where Id =:attachmentValue];
        System.debug('loading attachment: '+attachmentValue+' records: '+att.Body);
        base64Value = EncodingUtil.base64Encode(att.Body);
        contentType = att.ContentType;
    }
    
    public PageReference upload() {
        
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = '5003900001qjBIlAAM'; // the record the file is attached to
        attachment.IsPrivate = true;
        
        try {
            insert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } finally {
            attachment = new Attachment(); 
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        return null;
    }
    
    public List<Attachment> getAttachments() {
        System.debug('getFieldId--recId: '+recId);
        //List<Attachment> attachedFiles = [select id,contenttype,name,parentId from Attachment where parentId =:recId order By LastModifiedDate DESC ];
        List<Attachment> attachedFiles = [SELECT Id, ParentId, Name, ContentType, Description FROM Attachment order By LastModifiedDate DESC ];
        System.debug('getFieldId--attachment count: '+attachedFiles.size());
        /*if( attachedFiles != null && attachedFiles.size() > 0 ) {
for (Integer i=0 ; i < attachedFiles.size(); i++) {                  
fileId.add(attachedFiles[i].Id);
}      
}*/
        return attachedFiles;
        
    }
    @RemoteAction
    public static String doUploadAttachment(String caseId, String attachmentBody, String attachmentName, String attachmentId) {
        if(caseId != null) {
            Case cse = getCase(caseId);
            if(cse != null) {
                if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = cse.Id;
                    }
                    upsert att;
                    return att.Id;
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Case could not be found';
            }
        } else {
            return 'Case Id was null';
        }
    }
    
    @RemoteAction
    public static String doSubmitForm(String caseId, String description, String website, String phone) {
        if(caseId != null) {
            Case cse = getCase(caseId);
            if(cse != null) {
                cse.Description = description;
                /*cse.Website = website;
cse.Phone = phone;*/
                update cse;
                return 'Success';
            } else {
                return 'Case could not be found';
            }
        } else {
            return 'Case Id was null';
        }
    }
    
    private static Case getCase(String caseId) {
        list<Case> cases = [SELECT Id, CaseNumber,Status,Description 
                            FROM Case
                            WHERE Id =: caseId];
        if(cases.isEmpty()) {
            return null;
        } else {
            return cases[0];
        }
    }
    
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
    public List <ContentDocument> getCaseContentDocuments () {
        System.debug('getCaseContentDocuments: looking for files for case: '+c.id);
        Map<Id, ContentDocumentLink> m = new Map<Id, ContentDocumentLink>([
            select ContentDocumentId
            from ContentDocumentLink
            where LinkedEntityId =: c.id
        ]);
        List <ContentDocument> caseContentDocuments = [
            select Title, OwnerId, ParentId, PublishStatus
            from ContentDocument
            where Id in :m.keySet()
            order by Title
        ];
        System.debug('getCaseContentDocuments: found files for case: '+caseContentDocuments.size());
        return caseContentDocuments;
    }

}