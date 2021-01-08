//Trigger on house object to update the contact whenever the house record gets inserted, updated or deleted.
//By updating the contact we are calculating number of houses on the contact
trigger house on House__c (after insert, after update, after delete) {
    Map<Id,Contact> mapOfIdToContact = new Map<Id,Contact>();//Intializing the map of for contact id to contact record
    List<House__c> lstHouse;//Declaring the List of house object
    if(Trigger.isInsert || Trigger.isUpdate) //validating if the oprating is insert or update
        lstHouse = Trigger.new;//Assign the new record list
    if(Trigger.isDelete)//validating if the operation is delete
        lstHouse = Trigger.old;//Assign the old record list
    for(House__c h : lstHouse){ // for each house being updated/inserted/deleted
        if(h.Contact__c != null){ // if the Contact relationship is not null
            Contact c = new Contact(Id=h.Contact__c); // create a new contact object to trigger an update to the related record            
            mapOfIdToContact.put(h.Contact__c,c);//putting the contact id along with the record
        }
    } 
    if(!mapOfIdToContact.isEmpty())//validating if the map is not empty
        update mapOfIdToContact.values();//update the contact records
}
