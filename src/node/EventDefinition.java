package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONObject;

public class EventDefinition extends AST{
	public static List<EventDefinition> registry = new ArrayList<EventDefinition>();
	Object anonymous; // uncertainty
	Object documentation; // uncertainty
	Object id;
	String name;
	String src;
	
	public EventDefinition() {
		
	}
	
	public EventDefinition(JSONObject node) {
		nodeType = "EventDefinition";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			anonymous = (Object) node.get("anonymous");
			documentation = (Object) node.get("documentation");
			id = (Object) node.get("id");
			name = (String) node.get("name");
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
	
	public static List<EventDefinition> getRegistry() {
		return registry;
	}
	
	public Object getAnonymous() {
		return anonymous;
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
	
	public String getSrc() {
		return src;
	}
}
