public with sharing class EmailTemplateBodyPopulater {

	public static String fillTemplateMergeFields(String templateBody, SObject record) {
		String recordString = JSON.serialize(record);
		Map<String, Object> formattedRecord = (Map<String, Object>)JSON.deserializeUntyped(recordString);
		Map<String, Object> deepRecord = buildDeepRecord(formattedRecord);
		Pattern p = Pattern.compile('\\{\\s*!\\s*(\\w+)\\.([A-Za-z0-9._]+)\\s*\\}');
		Matcher m = p.matcher(templateBody);
		String objectAPIName = record.getSObjectType().getDescribe().getName();
		while (m.find()) {
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

	private static void validateTemplateSObjectType(String objectAPIName, String objectAPINameInTemplate) {
		if (objectAPIName != objectAPINameInTemplate) {
			throw new InvalidSObjectTypeException('Invalid SObject type for email template. Expected: ' 
				+ objectAPINameInTemplate + ', Received: ' + objectAPIName + '.');
		}
	}

	private static Map<String, Object> buildDeepRecord(Map<String, Object> recordRepresentation) {
		Map<String, Object> completedRepresentation = new Map<String, Object>();

		EmailTemplateBodyPopulaterStack stack = new EmailTemplateBodyPopulaterStack();
		stack.push(recordRepresentation);
		while(!stack.empty()) {
			Map<String, Object> node = stack.pop();
			for (String property : node.keySet()) {
				if (node.get(property) instanceof Map<String, Object> && property != 'attributes') {
					stack.push(buildRelationship(property, (Map<String, Object>) node.get(property)));
				} else if (property != 'attributes') {
					completedRepresentation.put(property, node.get(property));
				}
			}
		}

		return completedRepresentation;
	}

	private static Map<String, Object> buildRelationship(String parent, Map<String, Object> relationship) {
		Map<String, Object> nestedRepresentation = new Map<String, Object>();
		for (String property : relationship.keySet()) {
			nestedRepresentation.put(parent + '.' + property, relationship.get(property));
		}
		return nestedRepresentation;
	}

	private class EmailTemplateBodyPopulaterStack {
		private List<Map<String, Object>> s = new List<Map<String, Object>>();

		public Map<String, Object> pop() {
			return s.remove(s.size()-1);
		}

		public void push(Map<String, Object> o) {
			s.add(o);
		}

		public Boolean empty() {
			return s.isEmpty();
		}
	}

	public class InvalidSObjectTypeException extends Exception {}
}