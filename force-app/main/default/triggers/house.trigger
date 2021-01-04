trigger house on House__c (after insert, after update, after delete) {
    /*if(Trigger.isInsert){
        if(Trigger.isAfter){
            Map<Id,Integer> mapOfContactIdsToNewHouse = new Map<Id,Integer>();
            for(House__c h : Trigger.new){
                if(h.Contact__c != Null){
                    if(!mapOfContactIdsToNewHouse.containsKey(h.Contact__c))
                        mapOfContactIdsToNewHouse.put(h.Contact__c,1);
                    else{
                        Integer numberOfHouse = mapOfContactIdsToNewHouse.get(h.Contact__c);
                        numberOfHouse++;
                        mapOfContactIdsToNewHouse.put(h.Contact__c, numberOfHouse);
                    }
                }
            }
            if(!mapOfContactIdsToNewHouse.isEmpty()){
                List<Contact> lstContact = new List<Contact>();
                for(Contact objContact : [SELECT Id,Number_of_Houses__c FROM Contact WHERE Id IN :mapOfContactIdsToNewHouse.keySet()]){
                    if(objContact.Number_of_Houses__c != Null)
                        objContact.Number_of_Houses__c += mapOfContactIdsToNewHouse.get(objContact.Id);
                    else
                       objContact.Number_of_Houses__c = mapOfContactIdsToNewHouse.get(objContact.Id); 
                    lstContact.add(objContact);
                }
                if(!lstContact.isEmpty())
                    update lstContact;
            }
        }
    }*/
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