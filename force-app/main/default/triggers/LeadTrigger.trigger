//Trigger on the lead record to remove the unecessary characters from the phone field whenever lead gets created or updated
trigger LeadTrigger on Lead (before insert, before Update) {
    
    for(Lead objLead : Trigger.New){//iterating over the lead records
        if(String.isNotBlank(objLead.Phone))//validating if the phone field is not blank
            objLead.Phone = objLead.Phone.replaceAll('\\D','');//removing the unnecessary characters from the string
    }
    
}
