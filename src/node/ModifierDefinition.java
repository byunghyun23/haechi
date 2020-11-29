package node;

import java.util.ArrayList;
import java.util.List;

// import json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ModifierDefinition extends AST{
	public static List<ModifierDefinition> registry = new ArrayList<ModifierDefinition>();
	Object documentation; // uncertainty
	Object id;
	String name;
	JSONObject parameters;
	String src;
	String visibility;
	
	public ModifierDefinition() {
		
	}
	
	public ModifierDefinition(JSONObject node) {
		nodeType = "ModifierDefinition";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			documentation = (Object) node.get("documentation");
			id = (Object) node.get("id");
			name = (String) node.get("name");
			parameters = (JSONObject) node.get("parameters");
			src = (String) node.get("src");
			visibility = (String) node.get("visibility");
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
	
	public static List<ModifierDefinition> getRegistry() {
		return registry;
	}
	
	public Object getDocumentation() {
		return documentation;
	}
	
	public Object getId() {
		return id;
	}
	
	public String getName() {
		return name;
	}
	
	public JSONObject getParameters() {
		return parameters;
	}
	
	public String getSrc() {
		return src;
	}
	
	public String getVisibility() {
		return visibility;
	}
}
