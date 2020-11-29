package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONObject;

public class DoWhileStatement extends AST{
	public static List<DoWhileStatement> registry = new ArrayList<DoWhileStatement>(); 
	JSONObject condition;
	JSONObject body;
	Object id;
	String src;
	
	public DoWhileStatement() {
		
	}
	
	public DoWhileStatement(JSONObject node) {
		nodeType = "DoWhileStatement";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			condition = (JSONObject) node.get("condition");
			body = (JSONObject) node.get("body");
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
	
	public static List<DoWhileStatement> getRegistry() {
		return registry;
	}
	
	public JSONObject getCondition() {
		return condition;
	}
	
	public JSONObject getBody() {
		return body;
	}
	
	public Object getId() {
		return id;
	}
	
	public String getSrc() {
		return src;
	}
}
