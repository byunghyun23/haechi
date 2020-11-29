package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class FunctionCall extends AST{
	public static List<FunctionCall> registry = new ArrayList<FunctionCall>();
	JSONArray argumentTypes;
	JSONArray arguments;
	JSONObject expression;
	Object id;
	Object isConstant;      // boolean
	Object isLValue;        // boolean
	Object isPure;          // boolean
	String kind;
	Object lValueRequested; // boolean
	JSONArray names;
	String src;
	JSONObject typeDescriptions;
	String memberName;
	String name;
	Object referencedDeclaration;
	
	public FunctionCall() {
		
	}
	
	public FunctionCall(JSONObject node) {
		nodeType = "FunctionCall";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			argumentTypes = (JSONArray) node.get("argumentTypes");
			arguments = (JSONArray) node.get("arguments");
			expression = (JSONObject) node.get("expression");
			id = (Object) node.get("id");
			isConstant = (Object) node.get("isConstant");
			isLValue = (Object) node.get("isLValue");
			isPure = (Object) node.get("isPure");
			kind = (String) node.get("kind");
			lValueRequested = (Object) node.get("lValueRequested");
			names = (JSONArray) node.get("names");
			src = (String) node.get("src");
			typeDescriptions = (JSONObject) node.get("typeDescriptions");
			JSONObject temp = (JSONObject) node.get("expression");
			memberName = (String) temp.get("memberName"); 
			if(memberName == null) {
				memberName = "None";
				name = (String) temp.get("name");
			}
			else {
				JSONObject temp2 = (JSONObject) temp.get("expression");
				name = (String) temp2.get("name");
			}
			referencedDeclaration = (Object) temp.get("referencedDeclaration");
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
	
	public static List<FunctionCall> getRegistry() {
		return registry;
	}
	
	public JSONArray getArgumentTypes() {
		return argumentTypes;
	}
	
	public JSONArray getArguments() {
		return arguments;
	}
	
	public JSONObject getExpression() {
		return expression;
	}
	
	public Object getId() {
		return id;
	}
	
	public Object getIsConstant() {
		return isConstant;
	}
	
	public Object getIsLValue() {
		return isLValue;
	}
	
	public Object getIsPure() {
		return isPure;
	}
	
	public String getKind() {
		return kind;
	}
	
	public Object getLValueRequested() {
		return lValueRequested;
	}
	
	public JSONArray getNames() {
		return names;
	}
	
	public String getSrc() {
		return src;
	}
	
	public JSONObject getTypeDescriptions() {
		return typeDescriptions;
	}
	
	public String getMemberName() {
		return memberName;
	}
	
	public String getName() {
		return name;
	}
	
	public Object getReferencedDeclaration() {
		return referencedDeclaration;
	}
	
}
