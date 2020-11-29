package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class Identifier extends AST{
	public static List<Identifier> registry = new ArrayList<Identifier>();
	Object argumentTypes; // uncertainty
	Object id;
	String name;
	JSONObject condition;
	JSONArray overloadedDeclarations;
	Object referencedDeclaration;
	String typeIdentifier;
	String type;
	
	public Identifier() {
		
	}
	
	public Identifier(JSONObject node, String type) {
	    nodeType = "Identifier";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			argumentTypes = (Object) node.get("argumentTypes");
			id = (Object) node.get("id");
			name = (String) node.get("name");
			nodeType = (String) node.get("nodeType");
			condition = (JSONObject) node.get("condition");
			overloadedDeclarations = (JSONArray) node.get("overloadedDeclarations");
			referencedDeclaration = (Object) node.get("referencedDeclaration");
			JSONObject temp = (JSONObject) node.get("typeDescriptions");
			typeIdentifier = (String) temp.get("typeIdentifier");
			this.type = type;
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
	
	public static List<Identifier> getRegistry() {
		return registry;
	}
	
	public Object getArgumentTypes() {
		return argumentTypes;
	}
	
	public Object getId() {
		return id;
	}
	
	public String getName() {
		return name;
	}
	
	public JSONObject getCondition() {
		return condition;
	}
	
	public JSONArray getOverloadedDeclarations() {
		return overloadedDeclarations;
	}
	
	public Object getReferencedDeclaration() {
		return referencedDeclaration;
	}
	
	public String getTypeIdentifier() {
		return typeIdentifier;
	}
	
	public String getType() {
		return type;
	}
}
