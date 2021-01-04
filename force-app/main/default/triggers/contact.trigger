trigger contact on Contact (before insert, before update, after insert, after update) {

    if(Trigger.isInsert){ //if insert
        if(Trigger.isBefore){
            for(Contact objCon : Trigger.New){
                if(String.isNotBlank(objCon.Phone))
                    objCon.Phone = removeCharacters(objCon.Phone);
            }
        }
        if(Trigger.isAfter){
            List<House__c> lstHouse = new List<House__c>();
            for(Contact c : Trigger.new){ //for each contact being updated
                String mailingAddress = c.MailingStreet + ' ' + c.MailingCity + ' ' + c.MailingState + ' ' + c.MailingPostalCode + ' ' + c.MailingCountry; //build address string
                House__c primaryHouse = new House__c(); //create new house
                primaryHouse.Address__c =  mailingAddress; //set house address as contact address                
                primaryHouse.Contact__c = c.Id;
                lstHouse.add(primaryHouse);             
            } 
            if(!lstHouse.isEmpty())
                insert lstHouse; //insert the house
        }
    }

    if(Trigger.isUpdate){ //if update
        if(Trigger.isBefore){
            Map<String,Integer> mapOfContactIdToAllHouses = new Map<String,Integer>();
            for(House__c objHouse : [SELECT Id,Contact__c from House__c where Contact__c = :Trigger.NewMap.keySet()]){
                if(!mapOfContactIdToAllHouses.containsKey(objHouse.Contact__c))
                    mapOfContactIdToAllHouses.put(objHouse.Contact__c, 1);
                else{
                    Integer numberOfHouses = mapOfContactIdToAllHouses.get(objHouse.Contact__c);
                    numberOfHouses++;
                    mapOfContactIdToAllHouses.put(objHouse.Contact__c,numberOfHouses);
                }
            }
            for(Contact objContact : Trigger.New){
                if(mapOfContactIdToAllHouses.containsKey(objContact.Id))
                    objContact.Number_of_Houses__c = mapOfContactIdToAllHouses.get(objContact.Id);
                else
                    objContact.Number_of_Houses__c = 0;
                Contact objOldContact = Trigger.OldMap.get(objContact.Id);
                if(String.isNotBlank(objContact.Phone) && objContact.Phone != objOldContact.Phone)
                    objContact.Phone = removeCharacters(objContact.Phone);
            }
        }
        if(Trigger.isAfter){
            Map<String,House__c> mapOfContactIdToPrimaryHouses = new Map<String,House__c>();
            for(House__c objHouse : [SELECT Id, Primary__c, Address__c,Contact__c from House__c where Contact__c = :Trigger.NewMap.keySet() AND Primary__c = True]){
                if(objHouse.Contact__c != Null)
                    mapOfContactIdToPrimaryHouses.put(objHouse.Contact__c,objHouse);
            }
            Map<Id,Contact> mapOfContactIdToContact = Trigger.OldMap;
            List<House__c> lstHouses = new List<House__c>();
            for(Contact c : Trigger.new){ //for each contact being updated
                Contact OldContact = mapOfContactIdToContact.get(c.Id);
                if(c.MailingCity != OldContact.MailingCity || c.MailingStreet != OldContact.MailingStreet ||
                   c.MailingState != OldContact.MailingState || c.MailingCountry != OldContact.MailingCountry ||
                   c.MailingPostalCode != OldContact.MailingPostalCode){
                       if(mapOfContactIdToPrimaryHouses.containsKey(c.Id)){
                           String mailingAddress = c.MailingStreet + ' ' + c.MailingCity + ' ' + c.MailingState + ' ' + c.MailingPostalCode + ' ' + c.MailingCountry;
                           House__c objHouse = new House__c();
                           objHouse.Id = mapOfContactIdToPrimaryHouses.get(c.Id).Id;
                           objHouse.Address__c = mailingAddress;
                           lstHouses.add(objHouse);
                       }
                   }
            }
            if(!lstHouses.isEmpty())
                update lstHouses;
        }
    }
    
    private String removeCharacters(String stringToChange){
        return stringToChange.replaceAll('\\D','');
    }
}