//Test Class to test the insert of a house record whenever a contact gets inserted.
//To test the number of houses are calculating whenever we are inserting a house record.
//To test that the number of houses are calculating whenever we are deleting the houses records.
@IsTest
public without sharing class contactHouse_test {
    
    @isTest
    static void contactInsertData(){
        Contact c = new Contact(LastName='test', MailingStreet='123 Street', MailingCity='City', MailingState='State', MailingPostalCode='ZIP', MailingCountry='Country',Phone='(123) 456-7890'); //new contact with address
        Test.startTest();//Staring the Test
        insert c; //insert the contact
        Test.stopTest();//Stops the test
        List<House__c> houses = new List<House__c>([select Id, Contact__c, Primary__c, Address__c from House__c where Contact__c = :c.Id]); //get all houses related to contact
        c = [select id, Number_of_Houses__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact where Id = :c.id limit 1];//get the contact record
        System.assertEquals(1, houses.Size()); //check that there is 1 house related to the contact
        System.assertEquals(1, c.Number_of_Houses__c); //check that the contact shows that it has 1 house
    }
    
    @isTest
    static void houseInsertTest() {        
        Contact c = new Contact(LastName='test', MailingStreet='123 Street', MailingCity='City', MailingState='State', MailingPostalCode='ZIP', MailingCountry='Country'); //new contact with address
        insert c;//insert the contact               
        House__c house2 = new House__c(Name='2', Contact__c=c.Id, Primary__c=true); //new primary house
        Test.startTest();//Test starts
        insert house2; //insert our second house
        Test.stopTest();//Test End
        List<House__c> houses = new List<House__c>([select Id, Contact__c, Primary__c, Address__c from House__c where Contact__c = :c.Id]); //refresh the list of houses
        c = [select id, Number_of_Houses__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact where Id = :c.id limit 1]; //refresh the contact
        System.assertEquals(2, houses.Size()); //check that there are 2 houses related to the contact
        System.assertEquals(2, c.Number_of_Houses__c); //check that the contact shows that it has 2 houses
    }
    
    @isTest
    static void houseDeleteTest() { 
        Contact c = new Contact(LastName='test', MailingStreet='123 Street', MailingCity='City', MailingState='State', MailingPostalCode='ZIP', MailingCountry='Country'); //new contact with address
        insert c;//insert the contact               
        House__c house2 = new House__c(Name='2', Contact__c=c.Id); //new house
        insert house2;//insert the second house 
        List<House__c> houses = new List<House__c>([select Id, Contact__c, Primary__c, Address__c from House__c where Contact__c = :c.Id]);//get all the houses
        Test.startTest();//Test starts
        delete houses; //delete all of the houses
        Test.stopTest();//Test stops
        houses = new List<House__c>([select Id, Contact__c, Primary__c, Address__c from House__c where Contact__c = :c.Id]); //refresh the list houses
        c = [select id, Number_of_Houses__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact where Id = :c.id limit 1]; //refresh the contact
        System.assertEquals(0, houses.Size()); //check that there are 0 houses related to the contact
        System.assertEquals(0, c.Number_of_Houses__c); //check that the contact shows that it has 0 houses
    }
}
