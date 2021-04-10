@isTest
public with sharing class EmailTemplateBodyPopulaterTest {
	
	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateBodyWithNoMergeFields_ShouldNotChangeTemplateBody() {
		String templateBody = 'Test plaintext template';
		String testResults = populateEmailBodyInTestContext(templateBody, new Account());
		System.assertEquals(templateBody, testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithOneMergeFieldAndNonNullRecordOfCorrectType_ShouldFillMergeFieldWithRecordInfo() {
		String templateBody = 'Hello {!Contact.Name}, this email is to inform you that a test has occured.';
		String arthasMenethilJSON = '{"Name":"Arthas Menethil"}';
		Contact arthasMenethil = (Contact)JSON.deserialize(arthasMenethilJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, arthasMenethil);
		System.assertEquals('Hello Arthas Menethil, this email is to inform you that a test has occured.', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithTwoIdenticalMergeFieldsAndNonNullRecordOfCorrectType_ShouldFillMergeFieldsWithRecordInfo() {
		String templateBody = '{!Contact.Name}, hello. {!Contact.Name}, please report for testing.';
		String arthasMenethilJSON = '{"Name":"Arthas Menethil"}';
		Contact arthasMenethil = (Contact)JSON.deserialize(arthasMenethilJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, arthasMenethil);
		System.assertEquals('Arthas Menethil, hello. Arthas Menethil, please report for testing.', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithTwoDifferentMergeFieldsAndNonNullFieldsInRecordOfCorrectType_ShouldFillMergeFieldsWithRecordInfo() {
		String templateBody = '{!Contact.Name}, it has been reported that your email is {!Contact.Email}';
		String arthasMenethilJSON = '{"Name":"Arthas Menethil", "Email":"lichking@example.com"}';
		Contact arthasMenethil = (Contact)JSON.deserialize(arthasMenethilJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, arthasMenethil);
		System.assertEquals('Arthas Menethil, it has been reported that your email is lichking@example.com', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithManyDifferentMergeFieldsAndNonNullFieldsInRecordOfCorrectType_ShouldFillMergeFieldsWithRecordInfo() {
		String templateBody = '{!Contact.Name}, it has been reported that you email is {!Contact.Email} and phone number is {!Contact.HomePhone}';
		String arthasMenethilJSON = '{"Name":"Arthas Menethil", "Email":"lichking@example.com", "HomePhone":"(216) 555-8000"}';
		Contact arthasMenethil = (Contact)JSON.deserialize(arthasMenethilJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, arthasMenethil);
		System.assertEquals('Arthas Menethil, it has been reported that you email is lichking@example.com and phone number is (216) 555-8000', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithSimilarAndDifferentMergeFieldsAndNonNullFieldsInRecordOfCorrectType_ShouldFillMergeFieldsWithRecordInfo() {
		String templateBody = '{!Contact.Name}, hello. It has been reported that you email is {!Contact.Email}, name is {!Contact.Name}, and phone number is {!Contact.HomePhone}.';
		String arthasMenethilJSON = '{"Name":"Arthas Menethil", "Email":"lichking@example.com", "HomePhone":"(216) 555-8000"}';
		Contact arthasMenethil = (Contact)JSON.deserialize(arthasMenethilJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, arthasMenethil);
		System.assertEquals('Arthas Menethil, hello. It has been reported that you email is lichking@example.com, name is Arthas Menethil, and phone number is (216) 555-8000.', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithMergeFieldAndNullValueInRecordOfCorrectType_ShouldRemoveMergeField() {
		String templateBody = '{!Contact.Name}, Hello there.';
		Contact emptyContact = new Contact();
		String testResults = populateEmailBodyInTestContext(templateBody, emptyContact);
		System.assertEquals(', Hello there.', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithNullMergeFieldAndNonNullMergeFieldValueInRecordOfCorrectType_ShouldRemoveNullMergeFieldAndFillNonNullMergeField() {
		String templateBody = '{!Contact.Name}, Hello there. Your email address is {!Contact.Email}.';
		Contact obiwan = new Contact(Email = 'obiwan@example.com');
		String testResults = populateEmailBodyInTestContext(templateBody, obiwan);
		System.assertEquals(', Hello there. Your email address is obiwan@example.com.', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithManyNullMergeFields_ShouldRemoveAllNullMergeFields() {
		String templateBody = '{!Contact.Name}, Hello there.{!Contact.Email}{!Contact.FirstName}{!Contact.LastName}{!Contact.Name}';
		Contact emptyContact = new Contact();
		String testResults = populateEmailBodyInTestContext(templateBody, emptyContact);
		System.assertEquals(', Hello there.', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithMergeFieldOfIncorrectType_ShouldThrowInvalidSObjectTypeException() {
		String templateBody = '{!Account.Name}, Hello there.';
		String obiwanJSON = '{"Name":"Obi-Wan Kenobi"}';
		Contact obiwan = (Contact)JSON.deserialize(obiwanJSON, Contact.class);
		String testResults, exceptionMessage;
		try {
			testResults = populateEmailBodyInTestContext(templateBody, obiwan);
		} catch (EmailTemplateBodyPopulater.InvalidSObjectTypeException e) {
			exceptionMessage = e.getMessage();
		}
		System.assert(String.isBlank(testResults), 'The EmailTemplateBodyPopulater did not throw an exception.');
		System.assertEquals('Invalid SObject type for email template. Expected: Account, Received: Contact.', exceptionMessage);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithMergeFieldsOfCorrectAndIncorrectSObjectType_ShouldThrowInvalidSObjectTypeException() {
		String templateBody = '{!Contact.Name, Hello there. Welcome to {!Account.Name}';
		String obiwanJSON = '{"Name":"Obi-Wan Kenobi"}';
		Contact obiwan = (Contact)JSON.deserialize(obiwanJSON, Contact.class);
		String testResults, exceptionMessage;
		try {
			testResults = populateEmailBodyInTestContext(templateBody, obiwan);
		} catch (EmailTemplateBodyPopulater.InvalidSObjectTypeException e) {
			exceptionMessage = e.getMessage();
		}
		System.assert(String.isBlank(testResults), 'The EmailTemplateBodyPopulater did not throw an exception.');
		System.assertEquals('Invalid SObject type for email template. Expected: Account, Received: Contact.', exceptionMessage);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithMergeFieldWithLooseSpacing_ShouldFillMergeFieldWithSObjectInfo() {
		String templateBody = 'You are not prepared! - { ! Contact.Name }';
		String illidanJSON = '{"Name":"Illidan Stormrage"}';
		Contact illidan = (Contact)JSON.deserialize(illidanJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, illidan);
		System.assertEquals('You are not prepared! - Illidan Stormrage', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithDeepMergeFieldAndRecordWithDeepData_ShouldFillMergeFieldWithSObjectInfo() {
		String templateBody = 'You are not prepared! - {!Contact.CreatedBy.Name}';
		String demonHunterJSON = '{"Name":"Demon Hunter", "CreatedBy":{"Name":"Illidan Stormrage"}}';
		Contact demonHunter = (Contact)JSON.deserialize(demonHunterJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, demonHunter);
		System.assertEquals('You are not prepared! - Illidan Stormrage', testResults);
	}

	@isTest
	private static void emailTemplateBodyPopulater_GivenPlainTextTemplateWithDeeperMergeFieldAndRecordWithDeeperData_ShouldFillMergeFieldWithSObjectInfo() {
		String templateBody = 'I am {!Contact.Name} created by {!Contact.CreatedBy.Name}, the {!Contact.CreatedBy.Profile.Name}.  I represent the {!Contact.Account.Name}.';
		String fictionalCharacterJSON = '{"Name": "Jeff Zoblob","CreatedBy": {"Name": "Blob","Profile": {"Name": "Almighty Creator"}}, "Account": {"Name": "Lightning Blobs"}}';
		Contact fictionalCharacter = (Contact)JSON.deserialize(fictionalCharacterJSON, Contact.class);
		String testResults = populateEmailBodyInTestContext(templateBody, fictionalCharacter);
		System.assertEquals(
			'I am Jeff Zoblob created by Blob, the Almighty Creator.  I represent the Lightning Blobs.', 
			testResults
		);
	}

	private static String populateEmailBodyInTestContext(String templateBody, SObject record) {
		Test.startTest();
			String resultingBody = EmailTemplateBodyPopulater.fillTemplateMergeFields(templateBody, record);
		Test.stopTest();
		return resultingBody;
	}

}