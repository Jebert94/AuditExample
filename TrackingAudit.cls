/*
*********************************************************
Apex Class Name    : TrackingAudit
@description       : This class is responsible for scheduling and executing a job to track missing tracking numbers 
                    in sales records and send an email notification to the Tech Team if any are found.
*********************************************************
*/
public class TrackingAudit implements Schedulable {

    /*
    *********************************************************
    @Method Name    : execute
    @description    : This method is the entry point for the scheduled job. It queries sales records created in the 
                      last two weeks and checks for missing tracking numbers. If any records have missing tracking numbers, 
                      it sends an email notification to the Tech Team.
    @param          : SchedulableContext sc - The context for the scheduled job.
    @return         : void
    ********************************************************
    */
    public void execute(SchedulableContext sc) {
        // Calculate the date four days ago and two weeks ago
        datetime fourDaysAgo = date.today().addDays(-4);
        datetime twoWeeksAgo = date.today().addDays(-14);
        
        // Create a list to hold the order numbers with missing tracking numbers
        List<String> missingTracking = new List<String>();
        
        // Query total_sales__c records created in the last two weeks
        List<Sales__c> sList = [SELECT
                                      		id,
                                       		createdDate,
                                      		tracking_number__c,
                                       		order_number__c
                                       FROM total_sales__c
                                       WHERE CreatedDate >= :twoWeeksAgo AND CreatedDate < :fourDaysAgo
                                      ];
        
        // Loop through the queried sales records to find orders with missing tracking numbers
        for(Sales__c s : sList){
            if(s.tracking_number__c == NULL && !missingTracking.contains(s.order_number__c)){
                // If a record has a missing tracking number and the order number is not already in the missingTracking list,
                // add it to the list with the Order Number and Created Date information
                missingTracking.add('Order Number: '+ s.Order_Number__c + ' Created Date: '+ s.CreatedDate);
            }
        }
        
        // Prepare the body of the email with the order numbers having missing tracking numbers
        String body = '';
        for(String order : missingTracking){
            // Concatenate each order information to the body string, separating them with newline characters
            body = body + order +'\n';
        }
        
        // If there are any orders with missing tracking numbers, send an email notification to the Tech Team
        if(missingTracking.size() > 0){
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            mail.setToAddresses(['TechTeam@someemail.com']);
            mail.setReplyTo('TechTeam@someemail.com');
            mail.setSenderDisplayName('Tracking Audit');
            mail.setSubject('Error: Tracking for the Following Orders Have Not Populated');
    		mail.setPlainTextBody('The Following Orders Have Not Been Updated With Tracking Information for Over Four Days:\n\n'+ body);
            // Send the email using the Messaging.sendEmail method
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
