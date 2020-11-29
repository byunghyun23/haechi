package context;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import node.AST;
import node.FunctionDefinition;
import util.Position;

public class FunctionDefinitionContext {
	public List<FunctionDefinition> getAllFunctionDefinitions() {
		return FunctionDefinition.getRegistry();
	}
	
	@SuppressWarnings("unchecked")
	public JSONArray getAllFunctionDefinitionInfo() {
		Position position = new Position();
		
		List<FunctionDefinition> functionDefinitionContextList = getAllFunctionDefinitions();
		
		JSONArray functionDefinitionArray;
		JSONObject functionDefinitionInfo = new JSONObject();
		
		functionDefinitionArray = new JSONArray();
		for(FunctionDefinition functionDefinition : functionDefinitionContextList) {
			functionDefinitionInfo = new JSONObject();
			functionDefinitionInfo.put("id", functionDefinition.getId());
//			functionDefinitionINFO.put("kind", functionDefinition.getKind()); // ver. 0.5.1
			functionDefinitionInfo.put("name", functionDefinition.getName());
			functionDefinitionInfo.put("visibility", functionDefinition.getVisibility());
			functionDefinitionInfo.put("line", position.getLineNumber(functionDefinition.getCharacterCount()));
			functionDefinitionArray.add(functionDefinitionInfo);
		}
		
		return functionDefinitionArray;
	}
	
	public List<String> getAllConstructors() {
		List<String> constructors = new ArrayList<String>();
		
		for(FunctionDefinition functionDefinition : FunctionDefinition.getRegistry()) {
			if((boolean) functionDefinition.getIsConstructor()) 
				constructors.add(functionDefinition.getName());
		}
		return constructors;
	}
	
	public List<String> getAllFuncionDefinitionNames() {
		List<String> functionDefinitionNames = new ArrayList<String>();
		
		for(int i=0; i<getAllFunctionDefinitions().size(); i++) {
			String name = getAllFunctionDefinitions().get(i).getName();
			functionDefinitionNames.add(name);
		}
		
		return functionDefinitionNames;
	}
	
	public List<String> getAllFunctionDefinitionsWithExternalVisibility() {
		List<String> functionDefinitions = new ArrayList<String>();
		return functionDefinitions;
	}
	
	public List<String> getAllFunctionDefinitionsWithPublicVisibility() {
		List<String> functionDefinitions = new ArrayList<String>();
		return functionDefinitions;
	}
	
	public List<String> getAllFunctionDefinitionsWithInternalVisibility() {
		List<String> functionDefinitions = new ArrayList<String>();
		return functionDefinitions;
	}
	
	public List<String> getAllFunctionDefinitionsWithPrivateVisibility() {
		List<String> functionDefinitions = new ArrayList<String>();
		return functionDefinitions;
	}
	
	public List<String> getAllPureFunctions() {
		List<String> functionDefinitions = new ArrayList<String>();
		return functionDefinitions;
	}
	
	public List<String> getAllViewFunctions() {
		List<String> functionDefinitions = new ArrayList<String>();
		return functionDefinitions;
	}
	
	public int hasFallbackFunction() {
		int fallbackFunctionCount = 0;
		return fallbackFunctionCount;
	}
	
	public int hasPayableFallbackFunction() {
		int payableFallbackFunctionCount =0;
		return payableFallbackFunctionCount;
	}
	
	public boolean isFallbackFunction(AST functionDefinition) {
		return true;
	}
	
	public boolean isPayableFallbackFunction(AST functionDefinition) {
		return true;
	}
}
