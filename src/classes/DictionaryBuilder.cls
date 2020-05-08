@RestResource(urlMapping='/dictionaryBuilder/*')
global with sharing class DictionaryBuilder {
    /*
* Receives package.xml's as they are deployed to feature branches and attaches them to module enhancement requests for validation
*/
    
    private static final String restVersion = '2.1';
    
    public class PackageTypes {
        public String packageType {get;set;} 
        public List<String> packageMembers {get;set;} 
        
        public PackageTypes(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'packageType') {
                            packageType = parser.getText();
                        } else if (text == 'packageMembers') {
                            packageMembers = arrayOfString(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'PackageTypes consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Enhancement> enhancement {get;set;} 
    public String packageName {get;set;} 
    public List<PackageTypes> packageTypes {get;set;} 
    
    public DictionaryBuilder(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'enhancement') {
                        enhancement = arrayOfEnhancement(parser);
                    } else if (text == 'packageName') {
                        packageName = parser.getText();
                    } else if (text == 'packageTypes') {
                        packageTypes = arrayOfPackageTypes(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'DictionaryBuilder consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    /*
"Id,Name,New_Application_Name__c,RecordType.Name,Business_Sponsor_CCB__c,Business_Sponsor__c,Status__c,Release_Date__c,"+
"App_Enhancement_Description__c,Contract__c,Integration_Needed__c,Business_Objective__c,Name_of_Dev_Sandbox__c,Is_there_a_change_in_PII_PHI__c,Existing_Application__r.Name,"+
"Deploy_Branch__c,Deploy_Status__c,Existing_Application__r.Application_Description__c,Existing_Application__r.ContractIntegrator__c,"+
"Existing_Application__r.Deploy_Merge_Branch__c,Existing_Application__r.Deploy_Symbol__c,"+
"Existing_Application__r.Go_Live_Date__c,Existing_Application__r.Go_Live_Date_Projected__c,Existing_Application__r.Implementation_Start_Date__c,"+
"Existing_Application__r.UI_Format__c,Existing_Application__r.CF_Profile__c,Existing_Application__r.Product_Owner__c,Org__c";
*/ 
    public class Enhancement {
        public String Existing_Application_r_Name {get;set;} // in json: Existing_Application_r.Name
        public String Business_Sponsor_c {get;set;} 
        public String App_Enhancement_Description_c {get;set;} 
        public String Business_Objective_c {get;set;} 
        public String Release_Date_c {get;set;} 
        public String Is_there_a_change_in_PII_PHI_c {get;set;} 
        public String Existing_Application_r_UI_Format_c {get;set;} // in json: Existing_Application_r.UI_Format_c
        public String Existing_Application_r_CF_Profile_c {get;set;} // in json: Existing_Application_r.CF_Profile_c
        public String Contract_c {get;set;} 
        public String Business_Sponsor_CCB_c {get;set;} 
        public String Integration_Needed_c {get;set;} 
        public String Name {get;set;} 
        public String Existing_Application_r_Product_Owner_c {get;set;} // in json: Existing_Application_r.Product_Owner_c
        public String New_Application_Name_c {get;set;} 
        public String RecordType_Name {get;set;} 
        public String Name_of_Dev_Sandbox_c {get;set;} 
        public String Org_c {get;set;} 
        public String Id {get;set;} 
        public String Status_c {get;set;} 
        public String Deploy_Branch_c {get;set;}
        public String Deploy_Status_c {get;set;}
        public String Existing_Application_r_Application_Description_c {get;set;}
        public String Existing_Application_r_ContractIntegrator_c {get;set;}
        public String Existing_Application_r_Deploy_Merge_Branch_c {get;set;}
        public String Existing_Application_r_Deploy_Symbol_c {get;set;}
        public String Existing_Application_r_Go_Live_Date_c {get;set;}
        public String Existing_Application_r_Go_Live_Date_Projected_c {get;set;}
        public String Existing_Application_r_Implementation_Start_Date_c {get;set;}
        
        public Enhancement(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Existing_Application__r.Name') {
                            Existing_Application_r_Name = parser.getText();
                        } else if (text == 'Business_Sponsor__c') {
                            Business_Sponsor_c = parser.getText();
                        } else if (text == 'App_Enhancement_Description__c') {
                            App_Enhancement_Description_c = parser.getText();
                        } else if (text == 'Business_Objective__c') {
                            Business_Objective_c = parser.getText();
                        } else if (text == 'Release_Date__c') {
                            Release_Date_c = parser.getText();
                        } else if (text == 'Is_there_a_change_in_PII_PHI__c') {
                            Is_there_a_change_in_PII_PHI_c = parser.getText();
                        } else if (text == 'Existing_Application__r.UI_Format__c') {
                            Existing_Application_r_UI_Format_c = parser.getText();
                        } else if (text == 'Existing_Application__r.CF_Profile__c') {
                            Existing_Application_r_CF_Profile_c = parser.getText();
                        } else if (text == 'Contract__c') {
                            Contract_c = parser.getText();
                        } else if (text == 'Business_Sponsor_CCB__c') {
                            Business_Sponsor_CCB_c = parser.getText();
                        } else if (text == 'Integration_Needed__c') {
                            Integration_Needed_c = parser.getText();
                        } else if (text == 'Name') {
                            Name = parser.getText();
                        } else if (text == 'Existing_Application__r.Product_Owner__c') {
                            Existing_Application_r_Product_Owner_c = parser.getText();
                        } else if (text == 'New_Application_Name__c') {
                            New_Application_Name_c = parser.getText();
                        } else if (text == 'RecordType.Name') {
                            RecordType_Name = parser.getText();
                        } else if (text == 'Name_of_Dev_Sandbox__c') {
                            Name_of_Dev_Sandbox_c = parser.getText();
                        } else if (text == 'Org__c') {
                            Org_c = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getText();
                        } else if (text == 'Status__c') {
                            Status_c = parser.getText();
                        } else if (text == 'Deploy_Branch__c') {
					        Deploy_Branch_c = parser.getText();
                        } else if (text == 'Deploy_Status__c') {
        					Deploy_Status_c = parser.getText();
                        } else if (text == 'Existing_Application__r.Application_Description__c') {
        					Existing_Application_r_Application_Description_c = parser.getText();
                        } else if (text == 'Existing_Application__r.ContractIntegrator__c') {
        					Existing_Application_r_ContractIntegrator_c = parser.getText();
                        } else if (text == 'Existing_Application__r.Deploy_Merge_Branch__c') {
                            Existing_Application_r_Deploy_Merge_Branch_c = parser.getText();
                        } else if (text == 'Existing_Application__r.Deploy_Symbol__c') {
                            Existing_Application_r_Deploy_Symbol_c = parser.getText();
                        } else if (text == 'Existing_Application__r.Go_Live_Date__c') {
                            Existing_Application_r_Go_Live_Date_c = parser.getText();
                        } else if (text == 'Existing_Application__r.Go_Live_Date_Projected__c') {
                            Existing_Application_r_Go_Live_Date_Projected_c = parser.getText();
                        } else if (text == 'Existing_Application__r.Implementation_Start_Date__c') {
                            Existing_Application_r_Implementation_Start_Date_c = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Enhancement consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static DictionaryBuilder parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new DictionaryBuilder(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                           curr == System.JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    
    
    private static List<PackageTypes> arrayOfPackageTypes(System.JSONParser p) {
        List<PackageTypes> res = new List<PackageTypes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new PackageTypes(p));
        }
        return res;
    }
    
    
    
    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
    
    
    
    private static List<Enhancement> arrayOfEnhancement(System.JSONParser p) {
        List<Enhancement> res = new List<Enhancement>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Enhancement(p));
        }
        return res;
    }
    
    @HttpPost
    global static String executeBuild() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String returnMessage = 'Success';
        String requestBody = req.requestBody.toString();
        requestBody = requestBody;
        
        try {
            DictionaryBuilder packageXML = DictionaryBuilder.parse(req.requestBody.toString());
            
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'1-executeBuild:enhancement: '+packageXML.enhancement);
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'2-executeBuild:packageName: '+packageXML.packageName);
            
            List<Enhancement> enhancements = packageXML.enhancement;
            for ( Enhancement enh: enhancements ) {
                
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'enhancement: '+
                             '\nApp Name						: '+enh.Existing_Application_r_Name+
                             '\nApp Descprtion					: '+enh.Existing_Application_r_Application_Description_c+
                             '\nApp Contract					: '+enh.Existing_Application_r_ContractIntegrator_c+
                             '\nApp Merge Branch				: '+enh.Existing_Application_r_Deploy_Merge_Branch_c+
                             '\nApp Deploy Symbol				: '+enh.Existing_Application_r_Deploy_Symbol_c+
                             '\nApp Go Live Date				: '+enh.Existing_Application_r_Go_Live_Date_c+
                             '\nApp Go Live Projected Date		: '+enh.Existing_Application_r_Go_Live_Date_Projected_c+
                             '\nApp Implementation Start Date	: '+enh.Existing_Application_r_Implementation_Start_Date_c+
                             '\nApp Production Owner			: '+enh.Existing_Application_r_Product_Owner_c+
                             '\nApp Profile Id					: '+enh.Existing_Application_r_CF_Profile_c+
                             '\nApp UI Format					: '+enh.Existing_Application_r_UI_Format_c+
                             '\nEnhancement Id					: '+enh.Id+
                             '\nEnhancement Name				: '+enh.Name+
                             '\nEnhancement	Description			: '+enh.App_Enhancement_Description_c+
                             '\nEnhancement Business Objective	: '+enh.Business_Objective_c+
                             '\nEnhancement Business Sponsor	: '+enh.Business_Sponsor_c+
                             '\nEnhancement Business Sponsor CCB: '+enh.Business_Sponsor_CCB_c+
                             '\nEnhancement Contract			: '+enh.Contract_c+
                             '\nEnhancement	Integration Needed	: '+enh.Integration_Needed_c+
                             '\nEnhancement Dev Sandbox Name	: '+enh.Name_of_Dev_Sandbox_c+
                             '\nEnhancement New Application Name: '+enh.New_Application_Name_c+
                             '\nEnhancement	Org					: '+enh.Org_c+
                             '\nEnhancement RecordType Id		: '+enh.RecordType_Name+
                             '\nEnhancement	Release Date		: '+enh.Release_Date_c+
                             '\nEnhancement Status				: '+enh.Status_c+
                             '\nEnhancement Deploy Branch		: '+enh.Deploy_Branch_c+
                             '\nEnhancement Deploy Status		: '+enh.Deploy_Status_c
                            );                
            }
            
            //first lets see if the app already exists
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'3-Trying to find DTC Application: '+enhancements[0].Existing_Application_r_Name);
            DTC_Application__c app = new DTC_Application__c();
            try {
                app = [select Id,Name,CF_Profile__c,Application_Description__c,ContractIntegrator__c,Deploy_Merge_Branch__c,
                       Deploy_Symbol__c,Go_Live_Date__c,Go_Live_Date_Projected__c,Implementation_Start_Date__c 
                       from DTC_Application__c where Name= :enhancements[0].Existing_Application_r_Name limit 1];
                app.CF_Profile__c				=	enhancements[0].Existing_Application_r_CF_Profile_c;
                app.Application_Description__c	=	enhancements[0].Existing_Application_r_Application_Description_c;
                app.ContractIntegrator__c		=	enhancements[0].Existing_Application_r_ContractIntegrator_c;
                app.Deploy_Merge_Branch__c		=	enhancements[0].Existing_Application_r_Deploy_Merge_Branch_c;
                app.Deploy_Symbol__c			=	enhancements[0].Existing_Application_r_Deploy_Symbol_c;
                if ( enhancements[0].Existing_Application_r_Go_Live_Date_c != null )
                    app.Go_Live_Date__c				=	date.valueOf(enhancements[0].Existing_Application_r_Go_Live_Date_c);
                if ( enhancements[0].Existing_Application_r_Go_Live_Date_Projected_c != null )
                    app.Go_Live_Date_Projected__c	=	date.valueOf(enhancements[0].Existing_Application_r_Go_Live_Date_Projected_c);
                if ( enhancements[0].Existing_Application_r_Implementation_Start_Date_c != null )
                    app.Go_Live_Date_Projected__c	=	date.valueOf(enhancements[0].Existing_Application_r_Implementation_Start_Date_c);
                update app;
             
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'3.1-Finding DTC Application: '+app);
            } catch (Exception dme) {
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'3.2-executeBuild: did not find the application record: '+dme.getMessage());
                app = new DTC_Application__c ();
                app.Name						=	enhancements[0].Existing_Application_r_Name;
                app.CF_Profile__c				=	enhancements[0].Existing_Application_r_CF_Profile_c;
                app.Application_Description__c	=	enhancements[0].Existing_Application_r_Application_Description_c;
                app.ContractIntegrator__c		=	enhancements[0].Existing_Application_r_ContractIntegrator_c;
                app.Deploy_Merge_Branch__c		=	enhancements[0].Existing_Application_r_Deploy_Merge_Branch_c;
                app.Deploy_Symbol__c			=	enhancements[0].Existing_Application_r_Deploy_Symbol_c;
                if ( enhancements[0].Existing_Application_r_Go_Live_Date_c != null )
                    app.Go_Live_Date__c				=	date.valueOf(enhancements[0].Existing_Application_r_Go_Live_Date_c);
                if ( enhancements[0].Existing_Application_r_Go_Live_Date_Projected_c != null )
                    app.Go_Live_Date_Projected__c	=	date.valueOf(enhancements[0].Existing_Application_r_Go_Live_Date_Projected_c);
                if ( enhancements[0].Existing_Application_r_Implementation_Start_Date_c != null )
                    app.Go_Live_Date_Projected__c	=	date.valueOf(enhancements[0].Existing_Application_r_Implementation_Start_Date_c);
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'3.2.1-executeBuild: trying to insert the following record: '+app);
                insert app;
            }
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'3.3-Inserted DTC Application: '+app);
            
            //first lets see if the architecture design already exists
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'4-Trying to find Architecture Design: '+enhancements[0].Existing_Application_r_Name);
            DTC_Architecture_Design__c arch = new DTC_Architecture_Design__c();
            try {
                arch = [select Id,Name from DTC_Architecture_Design__c where Name= :enhancements[0].Existing_Application_r_Name limit 1];
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'4.1-Finding DTC Application: '+arch);
            } catch (Exception dme) {
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'4.2-executeBuild: did not find the architecture design record: '+dme.getMessage());
                arch = new DTC_Architecture_Design__c (Name=enhancements[0].Existing_Application_r_Name,
                                                       Contract__c='Other',
                                                       DTC_Application__c=app.Id);
                insert arch;
            }
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'4.3-Inserted DTC Architecture Design: '+arch);
            
            List<CICD_Package_Content__c> contents = new List<CICD_Package_Content__c>();
            CICD_Package_Content__c content = new CICD_Package_Content__c();
            
            Application_Request__c mer = new Application_Request__c();
            try {
                mer = [select Id,Name, 
                        Existing_Application__r.Name,
                        Business_Sponsor__c,
                        App_Enhancement_Description__c,
                        Business_Objective__c,
                        Release_Date__c,
                        DTC_Architecture_Design__c,
                        Existing_Application__c,
                        Is_there_a_change_in_PII_PHI__c,
                        Existing_Application__r.UI_Format__c,
                        Existing_Application__r.CF_Profile__c,
                        Contract__c,
                        Business_Sponsor_CCB__c,
                        Integration_Needed__c,
                        Existing_Application__r.Product_Owner__c,
                        New_Application_Name__c,
                        RecordType.Name,
                        Name_of_Dev_Sandbox__c,
                        Org__c,
                        Status__c,
                        Deploy_Package_Name__c,
                        Deploy_Branch__c,
                        Deploy_Status__c
                       from Application_Request__c where Deploy_Package_Name__c = :packageXML.packageName];
             	
                mer.Existing_Application__c=app.Id;
                mer.Business_Sponsor__c = enhancements[0].Business_Sponsor_c;
                mer.App_Enhancement_Description__c = enhancements[0].App_Enhancement_Description_c;
                mer.Business_Objective__c = enhancements[0].Business_Objective_c;
                mer.DTC_Architecture_Design__c = arch.Id;
                mer.Release_Date__c = enhancements[0].Release_Date_c;
                mer.Is_there_a_change_in_PII_PHI__c = enhancements[0].Is_there_a_change_in_PII_PHI_c;
                mer.Contract__c = enhancements[0].Contract_c;
                mer.Business_Sponsor_CCB__c = enhancements[0].Business_Sponsor_CCB_c;
                mer.Integration_Needed__c = enhancements[0].Integration_Needed_c;
                mer.New_Application_Name__c = enhancements[0].New_Application_Name_c;
                //mer.RecordType.Name = enhancements[0].
                mer.Name_of_Dev_Sandbox__c = enhancements[0].Name_of_Dev_Sandbox_c;
                mer.Org__c = enhancements[0].Org_c;
                mer.Status__c = enhancements[0].Status_c;
                mer.Deploy_Package_Name__c=packageXML.packageName;
                mer.Deploy_Branch__c = enhancements[0].Deploy_Branch_c;
                mer.Deploy_Status__c = enhancements[0].Deploy_Status_c;

                update mer;

                System.debug('DictionaryBuilder v: '+restVersion+'-'+'5.1-Finding Application Requests: '+mer);
            } catch (Exception dme) {
                System.debug('DictionaryBuilder v: '+restVersion+'-'+'5.2-executeBuild: did not find the application request record: '+dme.getMessage());
                try {
                    mer = new Application_Request__c();
	                mer.Existing_Application__c=app.Id;
                    mer.Business_Sponsor__c = enhancements[0].Business_Sponsor_c;
                    mer.App_Enhancement_Description__c = enhancements[0].App_Enhancement_Description_c;
                    mer.Business_Objective__c = enhancements[0].Business_Objective_c;
	                mer.DTC_Architecture_Design__c = arch.Id;
                    mer.Release_Date__c = enhancements[0].Release_Date_c;
                    mer.Is_there_a_change_in_PII_PHI__c = enhancements[0].Is_there_a_change_in_PII_PHI_c;
                    mer.Contract__c = enhancements[0].Contract_c;
                    mer.Business_Sponsor_CCB__c = enhancements[0].Business_Sponsor_CCB_c;
                    mer.Integration_Needed__c = enhancements[0].Integration_Needed_c;
                    mer.New_Application_Name__c = enhancements[0].New_Application_Name_c;
                    //mer.RecordType.Name = enhancements[0].
                    mer.Name_of_Dev_Sandbox__c = enhancements[0].Name_of_Dev_Sandbox_c;
                    mer.Org__c = enhancements[0].Org_c;
                    mer.Status__c = enhancements[0].Status_c;
                    mer.Deploy_Package_Name__c=packageXML.packageName;
                    mer.Deploy_Branch__c = enhancements[0].Deploy_Branch_c;
                    mer.Deploy_Status__c = enhancements[0].Deploy_Status_c;
		            System.debug('DictionaryBuilder v: '+restVersion+'-'+'5.2.1-Preparing to Insert Application_Request__c: '+mer);
	                insert mer;
                    
	            } catch (Exception dme1) {
    	            System.debug('DictionaryBuilder v: '+restVersion+'-'+'5.2.2-executeBuild: did not find the application request record: '+dme1.getMessage());
                }
	            System.debug('DictionaryBuilder v: '+restVersion+'-'+'5.2.3-Record Inserted Application_Request__c: '+mer);
                mer = [select Id,Name, 
                        Existing_Application__c,
                        Existing_Application__r.Name,
                        Business_Sponsor__c,
                        App_Enhancement_Description__c,
                        Business_Objective__c,
                        DTC_Architecture_Design__c,
                        Release_Date__c,
                        Is_there_a_change_in_PII_PHI__c,
                        Existing_Application__r.UI_Format__c,
                        Existing_Application__r.CF_Profile__c,
                        Contract__c,
                        Business_Sponsor_CCB__c,
                        Integration_Needed__c,
                        Existing_Application__r.Product_Owner__c,
                        New_Application_Name__c,
                        RecordType.Name,
                        Name_of_Dev_Sandbox__c,
                        Org__c,
                        Status__c,
                       	Deploy_Package_Name__c,
                        Deploy_Branch__c,
                        Deploy_Status__c
                       from Application_Request__c where  Id = :mer.Id];
            }
            System.debug('DictionaryBuilder v: '+restVersion+'-'+'5.3-Re-queried Application_Request__c: '+mer);
            
            for (PackageTypes pck: packageXML.packageTypes) {
                
                for (String pckMember: pck.packageMembers) {
                    content = new CICD_Package_Content__c();
                    content.Package_xml_Name__c = packageXML.packageName;
                    content.MetaData_Type__c = pck.packageType;
                    content.MetaData_Element__c = pckMember;
                    if ( mer != null ) {
                        content.Name = mer.Name+':'+packageXML.packageName;//+':'+pck.packageType+':'+pckMember;
                        content.Module_Enhancement_Request__c = mer.Id;
                    }
                    System.debug('DictionaryBuilder v: '+restVersion+'-'+'6-executeBuild: package: '+content.Package_xml_Name__c+
                                 ' content name: '+content.Name+
                                 ' enhancement request{Id: '+content.Module_Enhancement_Request__c+'): '+mer.Name+
                                 ' package type: '+content.MetaData_Type__c+
                                 ' metadata element: '+content.MetaData_Element__c);
                    contents.add(content);
                }
            }
            insert contents;
        } catch (Exception dme) {
            returnMessage = 'Failure: '+dme.getMessage();
        }
        return returnMessage;
    }
    
}