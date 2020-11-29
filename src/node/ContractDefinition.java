package node;

import java.util.List;
import java.util.ArrayList;

import org.json.simple.JSONObject;
import org.json.simple.JSONArray;

public class ContractDefinition extends AST{
	static List<ContractDefinition> registry = new ArrayList<ContractDefinition>();
	JSONArray baseContract;
	JSONArray contractDependencies;
	String contractKind;
	String documentation;
	Object fullyImplemented;   // boolean
	Object id;
	JSONArray linearizedBaseContracts;
	String name;
	Object scope;
	String src;
	
	public ContractDefinition() {
		
	}
	
	public ContractDefinition(JSONObject node) {
		nodeType = "ContractDefinition";
		registry.add(this);
		
		try {
			children = new ArrayList<AST>();
			baseContract = (JSONArray) node.get("baseContracts");
			contractDependencies = (JSONArray) node.get("contractDependencies");
			contractKind = (String) node.get("contractKind");
			documentation = (String) node.get("documentation");
			fullyImplemented = (Object) node.get("fullyImplemented");
			id = (Object) node.get("id");
			linearizedBaseContracts = (JSONArray) node.get("linearizedBaseContracts");
			name = (String) node.get("name");
		    scope = (Object) node.get("scope");
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
	
	public static List<ContractDefinition> getRegistry() {
		return registry;
	}
	
	public JSONArray getBaseContract() {
		return baseContract;
	}
	
	public JSONArray getContractDependencies() {
		return contractDependencies;
	}
	
	public String getContractKind() {
		return contractKind;
	}
	
	public String getDocumentation() {
		return documentation;
	}
	
	public Object getFullyImplemented() {
		return fullyImplemented;
	}
	
	public Object getId() {
		return id;
	}
	
	public JSONArray getLinearizedBaseContracts() {
		return linearizedBaseContracts;
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
	
}

