package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class FunctionDefinition extends AST{
	static List<FunctionDefinition> registry = new ArrayList<FunctionDefinition>();
	Object documentation; // uncertainty
	Object id;
	Object implemented;   // boolean
	Object isConstructor; // boolean (maybe)
	Object isDeclaredConst; // boolean (maybe)
	String kind;
	JSONArray modifiers;
	String name;
	JSONObject parameters;
	Object payable; // uncertainty
	JSONObject returnParameters;
	Object scope;
	String src;
	String stateMutability;
	Object superFunction;
	String visibility;
	
	public FunctionDefinition() {
		
	}
	
	public FunctionDefinition(JSONObject node) {
		nodeType = "FunctionDefinition";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			documentation = (Object) node.get("documentation");
			id = (Object) node.get("id");
			implemented = (Object) node.get("implemented");
			isConstructor = (Object) node.get("isConstructor");
			isDeclaredConst = (Object) node.get("isDeclaredConst");
			kind = (String) node.get("kind");
			modifiers = (JSONArray) node.get("modifiers");
			name = (String) node.get("name");
			if(name.equals("")) {
				name = "None";
			}
			parameters = (JSONObject) node.get("parameters");
			payable = (Object) node.get("payable");
			returnParameters = (JSONObject) node.get("returnParameters");
			scope = (Object) node.get("scope");
			src = (String) node.get("src");
			stateMutability = (String) node.get("stateMutability");
			superFunction = (Object) node.get("superFunction");
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
	
	public static List<FunctionDefinition> getRegistry() {
		return registry;
	}
	
	public Object getDocumentation() {
		return documentation;
	}
	
	public Object getId() {
		return id;
	}
	
	public Object getImplemented() {
		return implemented;
	}
	
	public Object getIsConstructor() {
		return isConstructor;
	}
	
	public Object getIsDeclaredConst() {
		return isDeclaredConst;
	}
	
	public String getKind() {
		return kind;
	}
	
	public JSONArray getModifiers() {
		return modifiers;
	}
	
	public String getName() {
		return name;
	}
	
	public JSONObject getParameters() {
		return parameters;
	}
	
	public Object getPayable() {
		return payable;
	}
	
	public JSONObject getReturnParameters() {
		return returnParameters;
	}
	
	public Object getScope() {
		return scope;
	}
	
	public String getSrc() {
		return src;
	}
	
	public String getStateMutability() {
		return stateMutability;
	}
	
	public Object getSuperFunction() {
		return superFunction;
	}
	
	public String getVisibility() {
		return visibility;
	}
	
}
