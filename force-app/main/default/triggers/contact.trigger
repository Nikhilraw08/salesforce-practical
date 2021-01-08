//Trigger to insert the new house record whenever a new contact gets inserted. 
//Removing the unnecessary characters from the phone field.
//Calculating the number of houses on each contact whenever a contact gets updated
//Changing the address of the primary house if any of the address field gets changed on the contact 
trigger contact on Contact (before insert, before update, after insert, after update) {

    if(Trigger.isInsert){ //if insert
        if(Trigger.isBefore){ //if before
            //looping over the inserting contacts
            for(Contact objCon : Trigger.New){
                //validating if phone is not blank
                if(String.isNotBlank(objCon.Phone))
                    //calling the method to remove unnecessary characters
                    objCon.Phone = removeCharacters(objCon.Phone);
            }
        }
        if(Trigger.isAfter){//if After
            List<House__c> lstHouse = new List<House__c>();
            for(Contact c : Trigger.new){ //for each contact being inserted
                //Adding all the mailing address fields
                String mailingAddress = c.MailingStreet + ' ' + c.MailingCity + ' ' + c.MailingState + ' ' + c.MailingPostalCode + ' ' + c.MailingCountry; //build address string
                House__c primaryHouse = new House__c(); //create new house
                primaryHouse.Address__c =  mailingAddress; //set house address as contact address                
                primaryHouse.Contact__c = c.Id; //setting contact as parent of house
                lstHouse.add(primaryHouse); //adding house record into the list             
            } 
            if(!lstHouse.isEmpty()) //validating if list of house is not empty
                insert lstHouse; //insert the house
        }
    }

    if(Trigger.isUpdate){ //if update
        if(Trigger.isBefore){//if Before
            Map<String,Integer> mapOfContactIdToAllHouses = new Map<String,Integer>(); //map to hold contact Id To number of houses
            for(House__c objHouse : [SELECT Id,Contact__c from House__c where Contact__c = :Trigger.NewMap.keySet()]){ //quering all the houses of the contact record
                if(!mapOfContactIdToAllHouses.containsKey(objHouse.Contact__c)) //if map is not containing the contact id
                    mapOfContactIdToAllHouses.put(objHouse.Contact__c, 1); //putting contact id and 1 for a house
                else{
                    Integer numberOfHouses = mapOfContactIdToAllHouses.get(objHouse.Contact__c); //Getting number of houses from the map
                    numberOfHouses++;//incrementing the number of houses
                    mapOfContactIdToAllHouses.put(objHouse.Contact__c,numberOfHouses);//putting the incremented number of house with the contact id
                }
            }
            for(Contact objContact : Trigger.New){//looping over updating contact records
                if(mapOfContactIdToAllHouses.containsKey(objContact.Id))//validating if map contains the contact id
                    objContact.Number_of_Houses__c = mapOfContactIdToAllHouses.get(objContact.Id); //assigning number of houses from map to contact field
                else
                    objContact.Number_of_Houses__c = 0; //Assigning 0 houses if no house found for the contact
                Contact objOldContact = Trigger.OldMap.get(objContact.Id); //Getting the old contact
                if(String.isNotBlank(objContact.Phone) && objContact.Phone != objOldContact.Phone) //validating if the phone field is changed
                    objContact.Phone = removeCharacters(objContact.Phone);//calling the method to remove unnecessary characters
            }
        }
        if(Trigger.isAfter){//if After
            Map<String,House__c> mapOfContactIdToPrimaryHouses = new Map<String,House__c>();//map which hold the contact id to primary house
            for(House__c objHouse : [SELECT Id, Primary__c, Address__c,Contact__c from House__c where Contact__c = :Trigger.NewMap.keySet() AND Primary__c = True]){//iterating over the primary house records
                    mapOfContactIdToPrimaryHouses.put(objHouse.Contact__c,objHouse);//putting the contact id to house record
            }
            Map<Id,Contact> mapOfContactIdToContact = Trigger.OldMap; //Getting the old map
            List<House__c> lstHouses = new List<House__c>();//initializing a list of house object
            for(Contact c : Trigger.new){ //for each contact being updated
                Contact OldContact = mapOfContactIdToContact.get(c.Id); //Getting the old contact record
                if(c.MailingCity != OldContact.MailingCity || c.MailingStreet != OldContact.MailingStreet ||
                   c.MailingState != OldContact.MailingState || c.MailingCountry != OldContact.MailingCountry ||
                   c.MailingPostalCode != OldContact.MailingPostalCode){ //validating if their is any address field is changed
                       if(mapOfContactIdToPrimaryHouses.containsKey(c.Id)){//validating if map contains the contact id
                           String mailingAddress = c.MailingStreet + ' ' + c.MailingCity + ' ' + c.MailingState + ' ' + c.MailingPostalCode + ' ' + c.MailingCountry;//build address string
                           House__c objHouse = new House__c();//initializing the house object
                           objHouse.Id = mapOfContactIdToPrimaryHouses.get(c.Id).Id;//Assigning the house record id
                           objHouse.Address__c = mailingAddress;//Assigning the house address with contact address
                           lstHouses.add(objHouse);//Adding the house record to the list
                       }
                   }
            }
            if(!lstHouses.isEmpty())//validating if the list of house is not empty
                update lstHouses;//updating the house records
        }
    }
    //Methos for removing the unnecessary characters
    private String removeCharacters(String stringToChange){
        return stringToChange.replaceAll('\\D','');//removing the unnecessary characters from a string
    }
}
