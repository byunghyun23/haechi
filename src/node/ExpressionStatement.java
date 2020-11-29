package node;

import java.util.ArrayList;
import java.util.List;

// import json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ExpressionStatement extends AST{
	public static List<ExpressionStatement> registry = new ArrayList<ExpressionStatement>();
	Expression expression;
	Object id;
	String src;
	
	public ExpressionStatement() {
		
	}
	
	public ExpressionStatement(JSONObject node) {
		nodeType = "ExpressionStatement";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			expression = new Expression((JSONObject) node.get("expression"), "expression");
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
	
	public static List<ExpressionStatement> getRegistry() {
		return registry;
	}
	
	public Expression getExpression() {
		return expression;
	}
	
	public Object getId() {
		return id;
	}
	
	public String getSrc() {
		return src;
	}
	

	

}
