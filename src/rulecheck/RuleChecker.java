package rulecheck;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import util.Position;
import util.ValidationRule;
import util.ValidationRule.Criticity;

public class RuleChecker {
	String ruleCheckResults;
	String countResults;
	
	public void ruleCheck() {
		RuleRepository ruleRepository = new RuleRepository();
		Position position = new Position();
		List<ValidationRule> rules = ruleRepository.getRules();
		Map<String, Integer> criticityCount = new HashMap<String, Integer>();
		
		// count initial
		for(Criticity criticity : Criticity.values()) {
			criticityCount.put(criticity.toString(), 0);
		}
		
		// check
		ruleCheckResults = "\r\n********** RULECHECK RESULTS **********\r\n\r\n";
		for(ValidationRule rule : rules) {
			String ruleCriticality = rule.getRuleCriticity().toString();
			String ruleName = rule.getRuleName();
			String comment = rule.getComment();
			
			ruleCheckResults += String.format("========== %s ==========\r\n", ruleName);
			
			if(rule.isImplement()) {
				rule.analyze();
				List<String> characterCounts = rule.getCharacterCounts();
				
				if(characterCounts.isEmpty()) {
					ruleCheckResults += "None\r\n\r\n";
				}
				else {
					if(criticityCount.containsKey(ruleCriticality)) {
						int count = criticityCount.get(ruleCriticality);
						count += characterCounts.size();
						criticityCount.put(ruleCriticality, count);
					}
					
					for(String characterCount : characterCounts) {
						ruleCheckResults += String.format("[%s] %s warning \"%s\", Line : %d\r\n\r\n", 
								ruleCriticality, ruleName, comment, position.getLineNumber(characterCount));
					}
				}
			}
			else {
				ruleCheckResults += "Not yet implemented\r\n\r\n";
			}
		}
		
		countResults = "********** CRITICITY COUNT **********\r\n";
		for(String key : criticityCount.keySet()) {
			countResults += String.format("%s : %s\r\n", key, criticityCount.get(key));
		}
		
	}
	
	public String getResults() {
		return ruleCheckResults;
	}
	
	public String getCriticityCount() {
		return countResults;
	}
}


