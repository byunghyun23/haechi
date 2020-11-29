package rule;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONObject;

import context.FunctionCallContext;
import node.FunctionCall;
import util.ValidationRule;

public class TransferEther implements ValidationRule{
	List<String> characterCounts = new ArrayList<String>();
	
	@Override
	public boolean isImplement() {
		return true;
	}
	
	@Override
	public void analyze() {
		if(!characterCounts.isEmpty()) {
			characterCounts.clear();
		}
		
		FunctionCallContext functionCallContext = new FunctionCallContext();
    	List<FunctionCall> functionCalls = functionCallContext.getAllFunctionCalls();
    	
    	
    	// Check whether send function is used
    	try {
    		for(FunctionCall functionCall : functionCalls) {
    			JSONObject expression = functionCall.getExpression();
    			//System.out.println(expression.get("memberName"));
    			if(expression.get("memberName") != null && expression.get("memberName").equals("send") || expression.get("memberName") != null && expression.get("memberName").equals("value")) {
    				//System.out.println(expression.get("memberName"));
    				if(expression.get("memberName").equals("value")) {
    					String count = (String) expression.get("src");
    					count = count.split(":")[0];
    					characterCounts.add(count);
    				}
    				expression = (JSONObject) expression.get("expression");
    				expression = (JSONObject) expression.get("expression");

    				if(expression.get("name").equals("msg") || expression.get("name").equals("tx")){
    					String count = (String) expression.get("src");
    					count = count.split(":")[0];
    					characterCounts.add(count);
    				}
    			}
    		}
    	} catch(NullPointerException e) {
//			e.printStackTrace();
    	}

	}

	@Override
	public Criticity getRuleCriticity() {
	    return Criticity.MAJOR;
	}

	@Override
	public String getRuleName() {
	    //return "Transfer-Ether";
		return "Reentrancy : Transfer Ether";
	}

	@Override
	public String getComment() {
	    return "Incorrect function usage in Ether transmission, Use transfer() instead";
	}
    
	@Override
	public List<String> getCharacterCounts() {
		return characterCounts;
	}
}
