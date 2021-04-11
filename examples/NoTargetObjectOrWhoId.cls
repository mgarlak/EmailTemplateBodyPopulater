public with sharing class NoTargetObjectOrWhoId {
       
    public static void runExample(String recipient) {
        EmailTemplate template = new EmailTemplate(
            HTMLValue = '<style>div {background-color: rgba(201, 76, 76, 0.3)}</style>' 
                + '<div>This email template was sent by {!User.Name}, a {!User.Profile.Name}, without a whoid or targetObjectId.</div>',
            Body = 'This email template was sent by {!User.Name}, a {!User.Profile.Name}, without a whoid or targetObjectId.',
            Subject = 'EmailTemplateBodyPopulater - NoTargetObjectOrWhoId'
        );
        sendMessage(template, recipient);
    }

    private static void sendMessage(EmailTemplate template, String recipient) {
        User currentRunningUser = [ SElECT Id, Name, Profile.Name, Email 
                                    FROM User 
                                    WHERE Id = :UserInfo.getUserId()];

        // Fills Merge Fields in template with contents of SObject, in this case currentRunningUser
        String templateBody = EmailTemplateBodyPopulater.fillTemplateMergeFields(template.HTMLValue, currentRunningUser);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // Intead of using 'setTemplateId', since templateBody the desired message with values merged
        // use other setters to specify body, recipients, subject, etc...
        email.setToAddresses(new List<String>{recipient});
        email.setHTMLBody(templateBody);
        email.setSubject(template.Subject);

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        if (results.get(0).success) {
            System.debug('The email has been sent');
        } else {
            System.debug('The email failed to send: ' + results.get(0).errors.get(0).message);
        }
    }
}
