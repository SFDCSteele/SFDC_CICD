trigger VehicleAuditHistory on Vehicle__c(before delete, before insert, before update, 
                                    after delete, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
    
            // In a before delete trigger, write the delete action to Quote Audit History.
            List<Quote_Audit_History__c> qAudit = new List<Quote_Audit_History__c>();
            for (Vehicle__c v : Trigger.old) {
                qAudit.add(new Quote_Audit_History__c(
                    Quote__c=v.Quote__c,
                    Entity__c='Vehicle',
                    Action__c='Record Deleted',
                    Details__c='Vehicle: ' +v.Model__c+' '+v.Model_Make__c+' added by '+Userinfo.getName())); 
            }
            insert qAudit;
        } else if (Trigger.isUpdate) {
    
        // In before insert or before update triggers, the trigger adds insert/update records
            List<Quote_Audit_History__c> qAudit = new List<Quote_Audit_History__c>();
            for (Vehicle__c v : Trigger.New) {
                qAudit.add(new Quote_Audit_History__c(
                    Quote__c=v.Quote__c,
                    Entity__c='Vehicle',
                    Action__c='Record Updated',
                    Details__c='Vehicle: ' +v.Model__c+' '+v.Model_Make__c+' added by '+Userinfo.getName())); 
            }
            insert qAudit;
        }
        if (Trigger.isInsert) {
            List<Quote_Audit_History__c> qAudit = new List<Quote_Audit_History__c>();
            for (Vehicle__c v : Trigger.New) {
                qAudit.add(new Quote_Audit_History__c(
                    Quote__c=v.Quote__c,
                    Entity__c='Vehicle',
                    Action__c='Record Added',
                    Details__c='Vehicle: ' +v.Model__c+' '+v.Model_Make__c+' added by '+Userinfo.getName())); 
            }
            insert qAudit;
        }
    }
}