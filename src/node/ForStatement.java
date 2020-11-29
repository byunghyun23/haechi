package node;

import java.util.ArrayList;
import java.util.List;

// import json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ForStatement extends AST{
	public static List<ForStatement> registry = new ArrayList<ForStatement>();
	JSONObject body;
	JSONObject condition;
	JSONObject initializationExpression;
	JSONObject loopExpression;
	Object id;
	String src;
	
	public ForStatement() {
		
	}
	
	public ForStatement(JSONObject node) {
		nodeType = "ForStatement";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			body = (JSONObject) node.get("body");
			condition = (JSONObject) node.get("condition");
			initializationExpression = (JSONObject) node.get("initializationExpression");
			loopExpression = (JSONObject) node.get("loopExpression");
			id = (Object) node.get("id");
			src = (String) node.get("src");
		} catch (ClassCastException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public AST getParent() {
		return parent;
	}
	
	@Override
	public List<AST> getChildren() {
		return children;
	}
	
	@Override
	public String getNodeType() {
		return nodeType;
	}
	
	public String getCharacterCount() {
		return src.split(":")[0];
	}
	
	public static List<ForStatement> getRegistry() {
		return registry;
	}
	
	public JSONObject getBody() {
		return body;
	}
	
	public JSONObject getCondition() {
		return condition;
	}
	
	public JSONObject getInitializationExpression() {
		return initializationExpression;
	}
	
	public JSONObject getLoopExpression() {
		return loopExpression;
	}
	
	public Object getId() {
		return id; 
	}

	public String getSrc() {
		return src;
	}
	
}
