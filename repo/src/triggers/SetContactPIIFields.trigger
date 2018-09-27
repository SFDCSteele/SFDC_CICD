trigger SetContactPIIFields on Contact (before insert, before update) {
    for (Contact c: Trigger.New) {
        System.debug('####SetContactPIIFields:name: '+c.Name+' birhdate: '+c.Birthdate+' SSN: '+c.SSN__c);
        if ( c.BirthDate != null ) {
            c.PII_Birthdate__c = '' + c.Birthdate.month() + '/' + c.Birthdate.day() + '/' + c.Birthdate.year();
        }
        if ( c.SSN__c != null ) {
            c.PII_SSN__c = c.SSN__c;
        }
    }
}