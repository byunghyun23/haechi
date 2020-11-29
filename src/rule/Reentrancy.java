package rule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;

import context.FunctionCallContext;
import node.AST;
import node.FunctionCall;
import node.FunctionDefinition;
import util.ValidationRule;

public class Reentrancy implements ValidationRule{
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
    	List<FunctionCall> functionCallList = functionCallContext.getAllFunctionCalls();
    	List<Map<String, Object>> functionCallInfoList = new ArrayList<Map<String, Object>>();
    	String name;
    	Object id;
    	Object defId = null;
    	Object refId;
    	String characterCount;
    	for(FunctionCall functionCall : functionCallList) {
    		AST parent = functionCall.getParent();
    		try {
    			while(!parent.getClass().getSimpleName().equals("FunctionDefinition")) {
    				parent = parent.getParent();
    			}
    			defId = ((FunctionDefinition) parent).getId();
    		} catch(NullPointerException e) {
//    			e.printStackTrace();
    		}
    		
    		Map<String, Object> functionCallInfo = new HashMap<String, Object>();
    		name = functionCall.getName();
    		id = functionCall.getId();
    		refId = functionCall.getReferencedDeclaration();
    		characterCount = functionCall.getSrc().split(":")[0];
   
    		functionCallInfo.put("name", name);
    		functionCallInfo.put("id", id);
    		functionCallInfo.put("defId", defId);
    		functionCallInfo.put("refId", refId);
    		functionCallInfo.put("characterCount", characterCount);
    		functionCallInfoList.add(functionCallInfo);
    	}
		
		// check
    	try {
        	for(int i=0; i<functionCallInfoList.size(); i++) {
        		Stack<Map<Object, Object>> i_defIds = new Stack<Map<Object, Object>>();
        		String i_characterCount = (String) functionCallInfoList.get(i).get("characterCount");
        		
        		Map<Object, Object> i_map = new HashMap<Object, Object>();
        		Object i_defId = functionCallInfoList.get(i).get("defId");
        		Object i_refId = functionCallInfoList.get(i).get("refId");
        		i_map.put(i_defId, i_refId);
        		i_defIds.push(i_map);
    			
        		for(int j=0; j<functionCallInfoList.size(); j++) {
        			Map<Object, Object> j_map = new HashMap<Object, Object>();
        			Object j_defId = functionCallInfoList.get(j).get("defId");
        			Object j_refId = functionCallInfoList.get(j).get("refId");
        			
        			if(i_defIds.peek().containsValue(j_defId)) {
        				j_map.put(j_defId, j_refId);
        				i_defIds.push(j_map);
        				if((i_defIds.peek().get(j_defId)).equals(i_defId)) {
        					if(!characterCounts.contains(i_characterCount)) {
        						characterCounts.add(i_characterCount);
        						break;
        					}
        				}
        			}
    			}
    		}
    	} catch (NullPointerException e) {
//    		e.printStackTrace();
    	}

	}
    
	@Override
	public Criticity getRuleCriticity() {
	    return Criticity.CRITICAL;
	}

	@Override
	public String getRuleName() {
	    return "Reentrancy";
	}

	@Override
	public String getComment() {
	    return "Potential vulnerability to Reentrancy attack";
	}
    
	@Override
	public List<String> getCharacterCounts() {
		return characterCounts;
	}
}
