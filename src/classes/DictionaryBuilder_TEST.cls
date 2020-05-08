@isTest
public class DictionaryBuilder_TEST {
    
    Static final String testMessage = '{ "enhancement" : [ { "Existing_Application__r.Name" : "Recruitment Tracker" , "Existing_Application__r.Go_Live_Date_Projected__c" : "2019-10-31" ,'+
        ' "App_Enhancement_Description__c" : "VA Staffing Management System. February 2020 release with enhancements." , "Existing_Application__r.Deploy_Symbol__c" : "VAHRS" , '+
        '"Release_Date__c" : "02/27/20" , "Is_there_a_change_in_PII_PHI__c" : "No" , "Contract__c" : "VA Internal Teams" , "RecordType.Name" : "empty" , "Integration_Needed__c" : "No" ,'+
        ' "Name" : "Enhancement-000880" , "Name_of_Dev_Sandbox__c" : "HRINFODEV" ,'+
        ' "Business_Sponsor__c" : "Chris Jaqua  Program Director, HR Systems Integration (HRSI)  Human Capital Management (HCM) (10A2A4)  Workforce Management and Consulting (10A2A)  Veterans Health Administration  US Department of Veterans Affairs  Office Phone# (405) 552-4345" ,'+
        ' "Business_Objective__c" : "HR Staffing Management System. HR across the VA recently modernized and centralized and we need this new capability to facilitate shared-services/support." ,'+
        ' "Existing_Application__r.Application_Description__c" : "Formerly VA HRSuite. HR Staffing Management System. HR across the VA recently modernized and centralized and we need this new capability to facilitate shared-services/support." ,'+
        ' "Existing_Application__r.UI_Format__c" : "Lightning Only" , "Existing_Application__r.Go_Live_Date__c" : "2020-10-31" , "Existing_Application__r.Product_Owner__c" : "005t00000044m9aAAA" ,'+
        ' "New_Application_Name__c" : "VA Recruitment Tracker" , "Existing_Application__r.Deploy_Merge_Branch__c" : "DTCMerge" , "Deploy_Status__c" : "Deployed to PROD" , "Deploy_Branch__c" : "VAHRS-ENH-000880" ,'+
        ' "Existing_Application__r.CF_Profile__c" : "VA Base Platform" , "Org__c" : "VA" , "Id" : "a0Kt00000040nOFEAY" , "Status__c" : "Failed to Obtain Production Sign-Off" ,'+
        ' "Existing_Application__r.ContractIntegrator__c" : "Citizen Developers - VA Internal teams" } ],                "packageName" : "Package_VAHRS-ENH-000880.xml",'+
        '                "packageTypes" : [                    {"packageType" : "CustomField", "packageMembers" : ["Notification__c.Active__c","Notification__c.Critical_Module_Notification__c",'+
        '"Notification__c.Critical_Org_Wide_Notification__c","Notification__c.End_Date__c","Notification__c.Message_Type__c","Notification__c.Module_Name__c","Notification__c.Module_Specific_Notification__c",'+
        '"Notification__c.Notification_Message__c","Notification__c.Org_Wide_Message__c","Notification__c.Start_Date__c","Notification__c.Within_Dates__c","Position_Number__c.Assignment_Code__c",'+
        ' "Position_Number__c.Budgeted_Position_Flag__c","Position_Number__c.Grade__c","Position_Number__c.Last_Position_Action_Reason__c","Position_Number__c.Position_Action_Effective_Date__c",'+
        ' "Position_Number__c.Position_Status__c","Position_Number__c.Position_Vacancy_Excluded_Position__c","Staffing_Request__c.Days_Announcement_Close_to_Cert_Issued__c",'+
        ' "Staffing_Request__c.Days_Tent_Offer_Accepted_to_Invest__c","Staffing_Request__c.Days_Tentative_Offer_Sent_to_Accepted__c","Staffing_Request__c.Prolonged_Start_Date_Reason__c",'+
        ' "Staffing_Request__c.Tentative_Offer_Accepted__c","Staffing_Request__c.Tentative_Offer_to_Receive_Tentative_Off__c"] },'+
        '                    {"packageType" : "FlexiPage", "packageMembers" : ["HRsuite_Home"] },                    {"packageType" : "Flow", "packageMembers" : ["BB_Notification_Updated"] },'+
        '                    {"packageType" : "Layout", "packageMembers" : ["Notification__c-Notification Layout","Position_Number__c-Position Number Layout","Staffing_Request__c-HR Staffing View",'+
        ' "Staffing_Request__c-Staffing Request Layout"] },                    {"packageType" : "PermissionSet", "packageMembers" : ["HRRT_System_Edit","HRsuite_StaffingAdmin","HRsuite_StaffingUser","HRsuite_SysAdmin"] },'+
        '                    {"packageType" : "ReportType", "packageMembers" : ["Org_Position_with_Staffing_Request","Recruitment_Tracker_Adhoc_Data"] }, '+
        '                   {"packageType" : "SharingCriteriaRule", "packageMembers" : ["Staffing_Request__c.HRsuite_VISN_10_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_12_Share_Region_Read",'+
        '"Staffing_Request__c.HRsuite_VISN_15_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_16_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_17_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_19_Share_Region_Read",'+
        ' "Staffing_Request__c.HRsuite_VISN_1_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_20_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_21_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_22_Share_Region_Read",'+
        ' "Staffing_Request__c.HRsuite_VISN_23_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_2_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_4_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_5_Share_Region_Read",'+
        ' "Staffing_Request__c.HRsuite_VISN_6_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_7_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_8_Share_Region_Read","Staffing_Request__c.HRsuite_VISN_9_Share_Region_Read",'+
        ' "Staffing_Request__c.VHA_Read_Only_All"] }] }';
    
    @isTest static void testExecuteBuild() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        
        req.requestURI = '/services/apexrest/dictionaryBuilder/executeBuild';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
        String JsonMsg = testMessage;/*'{\"build\": '+
            '			{\"envName\":\"ENTSD\",\"releaseNumber\":\"Release_19.6.1\",\"build_url\":\"http://18.188.255.76:8080/job/VA_SFDC_Parameterized_Build/173/\",'+
            '					\"build_id\":173,\"status\":\"Initiated\",\"project_name\":\"git@github.com:department-of-veterans-affairs/va-salesforce-master.git\",'+
            '					\"commit_id\":\"b79e49e2315f1b0eabc3c7cdf5c5f5e3a7172c7c\",'+
            '					\"message\":\"Revert  Removal of required field in permission set   This reverts commit 665810c2c1db1eb0ad9ab6b87a80741c449f0931.\",'+
            '					\"committer\":\"WSteele\",\"branch\":\"Acumen\",'+
            '					\"buildPackages\": [\"Package_GCMTRS-ENH-000633.xm\",\"Package_GCMTRS-ENH-000633.xm\",\"Package_LHCAMP-ENH-000555.xm\"]}}';*/
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        //createModuleEnhancement();
        
        Test.startTest();
        String returnMessage = DictionaryBuilder.executeBuild();
        Test.stopTest();

        List<DTC_Architecture_Design__c> arch = [select Id,Name from DTC_Architecture_Design__c where Name= 'Recruitment Tracker'];
        System.debug('testExecuteBuild:checking the DTC Architecture Designs created: '+arch);
		System.assertEquals(1, arch.size());

        List<DTC_Application__c> apps = [select Id,Name,CF_Profile__c from DTC_Application__c where Name= 'Recruitment Tracker'];
        System.debug('testExecuteBuild:checking the DTC Applications created: '+apps);
		System.assertEquals(1, apps.size());
        
        List<Application_Request__c> mer = [select Id,Name,Deploy_Package_Name__c from Application_Request__c where Deploy_Package_Name__c = 'Package_VAHRS-ENH-000880.xml'];
        System.debug('testExecuteBuild:checking the Application Request created: '+mer);
		System.assertEquals(1, mer.size());

        List<CICD_Package_Content__c> content = [select Id,Name,Module_Enhancement_Request__c from CICD_Package_Content__c where Module_Enhancement_Request__c= :mer[0].Id];
        System.debug('testExecuteBuild:checking the CICD Package Content created: '+content+' using key: '+mer[0].Id);
		System.assertEquals(55, content.size());
        
        System.debug('testExecuteBuild:returnMessage: '+returnMessage);
        System.assert(returnMessage.contains('Success'));
    }
    
    static testMethod void testParse() {
        String json = testMessage;//'{ \"enhancement\": [ { \"Existing_Application__r.Name\" : \"Recruitment Tracker\" , \"Business_Sponsor__c\" : \"Chris Jaqua\" , \"App_Enhancement_Description__c\" : \"VA Staffing Management System. February 2020 release with enhancements.\" , \"Business_Objective__c\" : \"HR Staffing Management System. HR across the VA recently modernized and centralized and we need this new capability to facilitate shared-services/support.\" , \"Release_Date__c\" : \"02/27/20\" , \"Is_there_a_change_in_PII_PHI__c\" : \"No\" , \"Existing_Application__r.UI_Format__c\" : \"Lightning Only\" , \"Existing_Application__r.CF_Profile__c\" : \VA Base Platform\" , \"Contract__c\" : \"VA Internal Teams\" , \"Business_Sponsor_CCB__c\" : \"null\" , \"Integration_Needed__c\" : \"No\" , \"Name\" : \"Enhancement-000880\" , \"Existing_Application__r.Product_Owner__c\" : \"005t00000044m9aAAA\" , \"New_Application_Name__c\" : \"VA Recruitment Tracker\" , \"RecordType.Name\" : \"012t0000000TRfRAAW\" , \"Name_of_Dev_Sandbox__c\" : \"HRINFODEV\" , \"Org__c\" : \"VA\" , \"Id\" : \"a0Kt00000040nOFEAY\" , \"Status__c\" : \"In Staging\" } ],                \"packageName\" : \"Package_VAHRS-ENH-000880.xml\",                \"packageTypes\" : [                    {\"packageType\" : \"CustomField\", \"packageMembers\" : [\"Notification__c.Active__c\",\"Notification__c.Critical_Module_Notification__c\",\"Notification__c.Critical_Org_Wide_Notification__c\",\"Notification__c.End_Date__c\",\"Notification__c.Message_Type__c\",\"Notification__c.Module_Name__c\",\"Notification__c.Module_Specific_Notification__c\",\"Notification__c.Notification_Message__c\",\"Notification__c.Org_Wide_Message__c\",\"Notification__c.Start_Date__c\",\"Notification__c.Within_Dates__c\",\"Position_Number__c.Assignment_Code__c\",\"Position_Number__c.Budgeted_Position_Flag__c\",\"Position_Number__c.Grade__c\",\"Position_Number__c.Last_Position_Action_Reason__c\",\"Position_Number__c.Position_Action_Effective_Date__c\",\"Position_Number__c.Position_Status__c\",\"Position_Number__c.Position_Vacancy_Excluded_Position__c\",\"Staffing_Request__c.Days_Announcement_Close_to_Cert_Issued__c\",\"Staffing_Request__c.Days_Tent_Offer_Accepted_to_Invest__c\",\"Staffing_Request__c.Days_Tentative_Offer_Sent_to_Accepted__c\",\"Staffing_Request__c.Prolonged_Start_Date_Reason__c\",\"Staffing_Request__c.Tentative_Offer_Accepted__c\",\"Staffing_Request__c.Tentative_Offer_to_Receive_Tentative_Off__c\"] },                    {\"packageType\" : \"FlexiPage\", \"packageMembers\" : [\"HRsuite_Home\"] },                    {\"packageType\" : \"Flow\", \"packageMembers\" : [\"BB_Notification_Updated\"] },                    {\"packageType\" : \"Layout\", \"packageMembers\" : [\"Notification__c-Notification Layout\",\"Position_Number__c-Position Number Layout\",\"Staffing_Request__c-HR Staffing View\",\"Staffing_Request__c-Staffing Request Layout\"] },                    {\"packageType\" : \"PermissionSet\", \"packageMembers\" : [\"HRRT_System_Edit\",\"HRsuite_StaffingAdmin\",\"HRsuite_StaffingUser\",\"HRsuite_SysAdmin\"] },                    {\"packageType\" : \"ReportType\", \"packageMembers\" : [\"Org_Position_with_Staffing_Request\",\"Recruitment_Tracker_Adhoc_Data\"] },                    {\"packageType\" : \"SharingCriteriaRule\", \"packageMembers\" : [\"Staffing_Request__c.HRsuite_VISN_10_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_12_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_15_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_16_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_17_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_19_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_1_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_20_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_21_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_22_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_23_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_2_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_4_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_5_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_6_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_7_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_8_Share_Region_Read\",\"Staffing_Request__c.HRsuite_VISN_9_Share_Region_Read\",\"Staffing_Request__c.VHA_Read_Only_All\"] }] }';
        DictionaryBuilder r = DictionaryBuilder.parse(json);
        System.assert(r != null);
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        DictionaryBuilder.PackageTypes objPackageTypes = new DictionaryBuilder.PackageTypes(System.JSON.createParser(json));
        System.assert(objPackageTypes != null);
        System.assert(objPackageTypes.packageType == null);
        System.assert(objPackageTypes.packageMembers == null);
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        DictionaryBuilder objDictionaryBuilder = new DictionaryBuilder(System.JSON.createParser(json));
        System.assert(objDictionaryBuilder != null);
        System.assert(objDictionaryBuilder.enhancement == null);
        System.assert(objDictionaryBuilder.packageName == null);
        System.assert(objDictionaryBuilder.packageTypes == null);
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        DictionaryBuilder.Enhancement objEnhancement = new DictionaryBuilder.Enhancement(System.JSON.createParser(json));
        System.assert(objEnhancement != null);
        System.assert(objEnhancement.Existing_Application_r_Name == null);
        System.assert(objEnhancement.Business_Sponsor_c == null);
        System.assert(objEnhancement.App_Enhancement_Description_c == null);
        System.assert(objEnhancement.Business_Objective_c == null);
        System.assert(objEnhancement.Release_Date_c == null);
        System.assert(objEnhancement.Is_there_a_change_in_PII_PHI_c == null);
        System.assert(objEnhancement.Existing_Application_r_UI_Format_c == null);
        System.assert(objEnhancement.Existing_Application_r_CF_Profile_c == null);
        System.assert(objEnhancement.Contract_c == null);
        System.assert(objEnhancement.Business_Sponsor_CCB_c == null);
        System.assert(objEnhancement.Integration_Needed_c == null);
        System.assert(objEnhancement.Name == null);
        System.assert(objEnhancement.Existing_Application_r_Product_Owner_c == null);
        System.assert(objEnhancement.New_Application_Name_c == null);
        System.assert(objEnhancement.RecordType_Name == null);
        System.assert(objEnhancement.Name_of_Dev_Sandbox_c == null);
        System.assert(objEnhancement.Org_c == null);
        System.assert(objEnhancement.Id == null);
        System.assert(objEnhancement.Status_c == null);
    }
    
    public static void createModuleEnhancement() {
        
        Application_Request__c mer 			= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_LHCAMP-ENH-000555.xml';
        mer.Deploy_Branch__c 				= 'LHCAMP-ENH-000555';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing build status 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Deploy to ENTSD';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing build status description';
        mer.Business_Objective__c 			= 'testing build status objective';
        mer.Business_Sponsor__c 			= 'testing build status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('10-DictionaryBuilder_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('11-DictionaryBuilder_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_GCMTRS-ENH-000633.xml';
        mer.Deploy_Branch__c 				= 'GCMTRS-ENH-000633';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing build status 2';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Deploy to ENTSD';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing build status description';
        mer.Business_Objective__c 			= 'testing build status objective';
        mer.Business_Sponsor__c 			= 'testing build status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('20-DictionaryBuilder_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('21-DictionaryBuilder_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_VAHD-ENH-000699.xml';
        mer.Deploy_Branch__c 				= 'VAHD-ENH-000699';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing extract process 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Extract Package';
        mer.From_Sandbox__c					= 'CTALBOTVA';
        mer.Deploy_Changeset__c				= 'deploy_changeset';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing build status description';
        mer.Business_Objective__c 			= 'testing build status objective';
        mer.Business_Sponsor__c 			= 'testing build status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('30-DictionaryBuilder_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('31-DictionaryBuilder_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_VAHD-ENH-000700.xml';
        mer.Deploy_Branch__c 				= 'VAHD-ENH-000700';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing merge process 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Merge to Merge Branch';
        mer.From_Sandbox__c					= 'CTALBOTVA';
        mer.Deploy_Changeset__c				= 'deploy_changeset';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing merge status description';
        mer.Business_Objective__c 			= 'testing merge status objective';
        mer.Business_Sponsor__c 			= 'testing merge status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('32-DictionaryBuilder_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('33-DictionaryBuilder_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_VAHD-ENH-000701.xml';
        mer.Deploy_Branch__c 				= 'VAHD-ENH-000701';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing merge process 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'New';
        mer.From_Sandbox__c					= 'CTALBOTVA';
        mer.Deploy_Changeset__c				= 'deploy_changeset';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing create branch';
        mer.Business_Objective__c 			= 'testing merge status objective';
        mer.Business_Sponsor__c 			= 'testing merge status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('34-DictionaryBuilder_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('35-DictionaryBuilder_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
    }
}