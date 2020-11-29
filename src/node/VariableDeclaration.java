package node;

import java.util.ArrayList;
import java.util.List;

// import json.simple.JSONArray;
import org.json.simple.JSONObject;

public class VariableDeclaration extends AST{
	public static List<VariableDeclaration> registry = new ArrayList<VariableDeclaration>();
	Object constant;   // boolean
	Object id;
	String name;
	Object scope;
	String src;
	Object stateVariable; // boolean
	String storageLocation;
	JSONObject typeDescriptions;
	JSONObject typeName;
	String realTypeName;
	JSONObject value;
	String realValue;
	String visibility;
	
	public VariableDeclaration() {
		
	}
	
	public VariableDeclaration(JSONObject node) {
		nodeType = "VariableDeclaration";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			constant = (Object) node.get("constant");
			id = (Object) node.get("id");
			name = (String) node.get("name");
			scope = (Object) node.get("scope");
			src = (String) node.get("src");
			stateVariable = (Object) node.get("stateVariable");
			storageLocation = (String) node.get("storageLocation");
			typeDescriptions = (JSONObject) node.get("typeDescriptions");
			typeName = (JSONObject) node.get("typeName");
			realTypeName = (String) typeName.get("name");  // Real TypeName
			value = (JSONObject) node.get("value");
			if(value != null) {
				realValue = (String) value.get("value");
//				if(realValue == null) {
//					JSONObject leftExpr = (JSONObject) value.get("leftExpression");
//					realValue = (String) leftExpr.get("value");
//					if(realValue == null) {
//						leftExpr = (JSONObject) leftExpr.get("leftExpression");
//						realValue = (String) leftExpr.get("value");
//					}
//				}
//				
//				JSONObject rightExpr = (JSONObject) value.get("rightExpression");
//				if(rightExpr.get("value") == null) {
//					
//				}
			}
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
	
	public static List<VariableDeclaration> getRegistry() {
		return registry;
	}
	
	public Object getConstant() {
		return constant;
	}
	
	public Object getId() {
		return id;
	}
	
	public String getName() {
		return name;
	}
	
	public Object getScope() {
		return scope;
	}
	
	public String getSrc() {
		return src;
	}
	
	public Object getStateVariable() {
		return stateVariable;
	}
	
	public String getStorageLocation() {
		return storageLocation;
	}
	
	public JSONObject getTypeDescriptions() {
		return typeDescriptions;
	}
	
	public JSONObject getTypeName() {
		return typeName;
	}
	
	public String getRealTypeName() {
		if(realTypeName == null) {
			realTypeName = (String) typeName.get("nodeType");
		}
		return realTypeName;
	}
	
	public JSONObject getValue() {
		return value;
	}
	
	public String getRealValue() {
		return realValue;
	}
	
	public String getVisibility() {
		return visibility;
	}
	
}


