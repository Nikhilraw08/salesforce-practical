trigger LeadTrigger on Lead (before insert, before Update) {
    
    for(Lead objLead : Trigger.New){
        if(String.isNotBlank(objLead.Phone))
            objLead.Phone = objLead.Phone.replaceAll('\\D','');
    }
    
}