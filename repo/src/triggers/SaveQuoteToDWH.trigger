trigger SaveQuoteToDWH on Opportunity(before insert, before update) {
        System.debug('inside SaveQuoteToDWH trigger:isDelete? '+Trigger.isDelete+' trigger: '+Trigger.new);
    	boolean isTest=false;
        if (!Trigger.isDelete) {
    
            // In a before delete trigger, write the delete action to Quote Audit History.
            System.debug('inside trigger: SaveQuoteToDWH');
            List<String> quotes = new List<String>();
            for (Opportunity o : Trigger.new) {
	            System.debug('trigger SaveQuoteToDWH:quote: '+o.Name+' StageName: '+o.StageName);
                if ( o.StageName == 'Closed Won' || o.StageName == 'Closed Lost') {
                    quotes.add(o.Id);
                    if ( o.Name.indexOf('TEST:') >= 0 ) {
                        isTest = true;
                    }
                }
            }
            if ( quotes.size() > 0 ) {
	            SaveQuoteToDWH.execute(quotes,isTest);
            }
    }
}