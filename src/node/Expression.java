package node;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class Expression extends AST{
	public static List<Expression> registry = new ArrayList<Expression>();
	JSONArray argumentTypes;
	JSONArray arguments;
	Object id;
	Object isConstant;       // boolean
	Object isLValue;         // boolean
	Object isPure;           // boolean
	Object lValueRequested;  // boolean
	String operator;          
	Object prefix;           // boolean
	String src;
	JSONObject subExpression; 
	JSONObject typeDescriptions;
	JSONObject leftHandSide;
	JSONObject rightHandSide;
	JSONObject leftExpression;
	JSONObject rightExpression;
	JSONArray overloadedDeclarations;
	Object referencedDeclaration;
	String name; 
	JSONObject commonType;
	Object components;       // uncertainty
	String hexValue;
	String kind;
	Object subdenomination;  // uncertainty
	String value;
	Object isInlineArray;    // boolean
	String memberName;
	String typeOfExpression; // Maybe
	
	public Expression() {
		
	}
	
	public Expression(JSONObject node, String typeOfExpression) {
		nodeType = "Expression";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			nodeType = (String) node.get("nodeType");
			argumentTypes = (JSONArray) node.get("argumentTypes");
			arguments = (JSONArray) node.get("arguments");
			id = (Object) node.get("id");
			isConstant = (Object) node.get("isConstant");
			isLValue = (Object) node.get("isLValue");
			isPure = (Object) node.get("isPure");
			lValueRequested = (Object) node.get("lValueRequested");
			operator = (String) node.get("operator");
			prefix = (Object) node.get("prefix");
			src = (String) node.get("src");
			subExpression = (JSONObject) node.get("subExpression");
			typeDescriptions = (JSONObject) node.get("typeDescriptions");
			leftHandSide = (JSONObject) node.get("leftHandSide");
			rightHandSide = (JSONObject) node.get("rightHandSide");
			leftExpression = (JSONObject) node.get("leftExpression");
			rightExpression = (JSONObject) node.get("rightExpression");
			overloadedDeclarations = (JSONArray) node.get("overloadedDeclarations");
			referencedDeclaration = (Object) node.get("referencedDeclaration");
			name = (String) node.get("name");
			commonType = (JSONObject) node.get("commonType");
			components = (Object) node.get("components");
			hexValue = (String) node.get("hexValue");
			kind = (String) node.get("kind");
			subdenomination = (Object) node.get("subdenomination");
			value = (String) node.get("value");
			isInlineArray = (Object) node.get("isInlineArray");
			memberName = (String) node.get("memberName");
			this.typeOfExpression = typeOfExpression;
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
	
	public static List<Expression> getRegistry() {
		return registry;
	}
	
	public JSONArray getArgumentTypes() {
		return argumentTypes;
	}
	
	public JSONArray getArguments() {
		return arguments;
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
	
	public Object getLValueRequested() {
		return lValueRequested;
	}
	
	public String getOperator() {
		return operator;
	}
	
	public Object getPrefix() {
		return prefix;
	}
	
	public String getSrc() {
		return src;
	}
	
	public JSONObject getSubExpression() {
		return subExpression;
	}
	
	public JSONObject getTypeDescriptions() {
		return typeDescriptions;
	}
	
	public JSONObject getLeftHandSide() {
		return leftHandSide;
	}
	
	public JSONObject getRightHandSide() {
		return rightHandSide;
	}
	
	public JSONObject getLeftExpression() {
		return leftExpression;
	}
	
	public JSONObject getRightExpression() {
		return rightExpression;
	}
	
	public JSONArray getOverloadedDeclarations() {
		return overloadedDeclarations;
	}
	
	public Object getReferencedDeclaration() {
		return referencedDeclaration;
	}
	
	public String getName() {
		return name;
	}
	
	public JSONObject getCommonType() {
		return commonType;
	}

	public Object getComponents() {
		return components;
	}

	public String getHexValue() {
		return hexValue;
	}
	
	public String getKind() {
		return kind;
	}
	
	public Object getSubdenomination() {
		return subdenomination;  
	}
	
	public String getValue() {
		return value;
	}
	
	public Object getIsInlineArray() {
		return isInlineArray;  
	}
	
	public String getMemberName() {
		return memberName;
	}
	
	public Object getTypeOfExpression() {
		return typeOfExpression;
	}
}
