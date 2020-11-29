package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class VariableDeclarationStatement extends AST{
	public static List<VariableDeclarationStatement> registry = new ArrayList<VariableDeclarationStatement>();
	Object id;
	JSONObject initialValue;
	String src;
	JSONArray assignments;
	JSONArray declarations;
	
	public VariableDeclarationStatement() {
		
	}
	
	public VariableDeclarationStatement(JSONObject node) {
		nodeType = "VariableDeclarationStatement";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			id = (Object) node.get("id");
			initialValue = (JSONObject) node.get("initialValue");
			src = (String) node.get("src");
			assignments = (JSONArray) node.get("assignments");
			declarations = (JSONArray) node.get("declarations");
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
	
	public static List<VariableDeclarationStatement> getRegistry() {
		return registry;
	}
	
	public Object getId() {
		return id;
	}
	
	public JSONObject getInitialValue() {
		return initialValue;
	}
	
	public String getSrc() {
		return src;
	}
	
	public JSONArray getAssignments() {
		return assignments;
	}
	
	public JSONArray getdeclarations() {
		return declarations;
	}
}
