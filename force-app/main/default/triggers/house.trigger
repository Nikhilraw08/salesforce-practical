trigger house on House__c (after insert, after update, after delete) {
    
    Map<Id,Contact> mapOfIdToContact = new Map<Id,Contact>();
    List<House__c> lstHouse;
    if(Trigger.isInsert || Trigger.isUpdate)
        lstHouse = Trigger.new;
    if(Trigger.isDelete)
        lstHouse = Trigger.old;
    for(House__c h : lstHouse){ // for each house being updated/inserted/deleted
        if(h.Contact__c != null){ // if the Contact relationship is not null
            Contact c = new Contact(Id=h.Contact__c); // create a new contact object to trigger an update to the related record            
            mapOfIdToContact.put(h.Contact__c,c);
        }
    } 
    if(!mapOfIdToContact.isEmpty())
        update mapOfIdToContact.values();
}
