public with sharing class EmailTemplateBodyPopulater {
	
	private String body;

	public EmailTemplateBodyPopulater(String templateBody, SObject record) {
		this.body = fillTemplateMergeFields(templateBody, record);
	}

	public String getBody() {
		return body;
	}

	private String fillTemplateMergeFields(String templateBody, SObject record) {
		String recordString = JSON.serialize(record);
		Map<String, Object> formattedRecord = (Map<String, Object>)JSON.deserializeUntyped(recordString);
		Map<String, Object> deepRecord = constructDeepObjectMap(formattedRecord);
		Pattern p = Pattern.compile('\\{\\s*!\\s*(\\w+)\\.([A-Za-z0-9._]+)\\s*\\}');
		Matcher m = p.matcher(templateBody);
		while (m.find()) {
			String objectAPIName = record.getSObjectType().getDescribe().getName();
			validateTemplateSObjectType(objectAPIName, m.group(1));
			String fieldName = m.group(2);
			String replacePattern = '\\{\\s*!\\s*' + objectAPIName + '\\.' + fieldName + '\\s*\\}';
			String fieldValue = String.valueOf(deepRecord.get(fieldName));
			if (String.isBlank(fieldValue)) {
				fieldValue = '';
			}
			templateBody = templateBody.replaceAll(replacePattern, fieldValue);
		}
		return templateBody;
	}

	private void validateTemplateSObjectType(String objectAPIName, String objectAPINameInTemplate) {
		if (objectAPIName != objectAPINameInTemplate) {
			throw new InvalidSObjectTypeException('Invalid SObject type for email template. Expected: ' 
				+ objectAPINameInTemplate + ', Received: ' + objectAPIName + '.');
		}
	}

	private Map<String, Object> constructDeepObjectMap(Map<String, Object> recordRepresentation) {
		Map<String, Object> completedRepresentation = new Map<String, Object>();
		for (String property : recordRepresentation.keySet()) {
			if (recordRepresentation.get(property) instanceof Map<String, Object> && property != 'attributes') {
				Map<String, Object> nestedRepresentation = new Map<String, Object>();
				Map<String, Object> nestedObject = (Map<String, Object>)recordRepresentation.get(property);
				for (String nestedProperty : nestedObject.keySet()) {
					nestedRepresentation.put(property + '.' + nestedProperty, nestedObject.get(nestedProperty));
				}
				completedRepresentation.putAll(constructDeepObjectMap(nestedRepresentation));
			} else {
				completedRepresentation.put(property, recordRepresentation.get(property));
			}
		}
		return completedRepresentation;
	}

	public class InvalidSObjectTypeException extends Exception {}
}