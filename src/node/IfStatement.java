package node;

import java.util.ArrayList;
import java.util.List;

// import json.simple.JSONArray;
import org.json.simple.JSONObject;

public class IfStatement extends AST{
	public static List<IfStatement> registry = new ArrayList<IfStatement>();
	JSONObject condition;
	JSONObject trueBody;
	JSONObject falseBody;
	Object id;
	String src;
	
	public IfStatement() {
		
	}
	
	public IfStatement(JSONObject node) {
		nodeType = "IfStatement";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			condition = (JSONObject) node.get("condition");
			trueBody = (JSONObject) node.get("trueBody");
			falseBody = (JSONObject) node.get("falseBody");
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
	
	public static List<IfStatement> getRegistry() {
		return registry;
	}
	
	public JSONObject getCondition() {
		return condition;
	}
	
	public JSONObject getTrueBody() {
		return trueBody;
	}
	
	public JSONObject getFalseBody() {
		return falseBody;
	}
	
	public Object getId() {
		return id;
	}
	
	public String getSrc() {
		return src;
	}
	
}
