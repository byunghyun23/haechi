package context;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import node.VariableDeclaration;
import util.Position;

public class VariableContext {
	public List<VariableDeclaration> getAllVariables() {
		return VariableDeclaration.getRegistry();
	}
	
	@SuppressWarnings("unchecked")
	public JSONArray getAllVariableInfo() {
		Position position = new Position();

		List<VariableDeclaration> variableContextList = getAllVariables();
		
		JSONArray variableArray;
		JSONObject variableInfo = new JSONObject();
		
		variableArray = new JSONArray();
		for(VariableDeclaration variableDeclaration : variableContextList) {
			variableInfo = new JSONObject();
			variableInfo.put("id", variableDeclaration.getId());
			variableInfo.put("isStateVariable", variableDeclaration.getStateVariable());
			variableInfo.put("name", variableDeclaration.getName());
			variableInfo.put("type", variableDeclaration.getRealTypeName());
			variableInfo.put("line", position.getLineNumber(variableDeclaration.getCharacterCount()));
			variableArray.add(variableInfo);
		}
		
		return variableArray;
	}
	
	public List<VariableDeclaration> getAllStateVariables() {
		List<VariableDeclaration> stateVariables = new ArrayList<VariableDeclaration>();
		
		for(VariableDeclaration variable : VariableDeclaration.getRegistry()) {
			if((boolean) variable.getStateVariable()) 
				stateVariables.add(variable);
		}
		return stateVariables;
	}
	
	public List<VariableDeclaration> getAllStorageVariables() {
		List<VariableDeclaration> storageVariables = new ArrayList<VariableDeclaration>();
		
		for(VariableDeclaration variable : VariableDeclaration.getRegistry()) {
			if(variable.getStorageLocation().equals("storage")) 
				storageVariables.add(variable);
		}
		return storageVariables;
	}
	
	public List<VariableDeclaration> getAllMemoryVariables() {
		List<VariableDeclaration> memoryVariables = new ArrayList<VariableDeclaration>();
		
		for(VariableDeclaration variable : VariableDeclaration.getRegistry()) {
			if(variable.getStorageLocation().equals("memory")) 
				memoryVariables.add(variable);
		}
		return memoryVariables;
	}
	
	public String getVariableNameForId(Object id) {
		for(VariableDeclaration variable : VariableDeclaration.getRegistry()) {
			if(variable.getId() == id)
				return variable.getName();
		}
		return "Error";
	}
	
	public List<String> getAllVariablesNames() {
		List<String> variableNames = new ArrayList<String>();
		for(VariableDeclaration variable : VariableDeclaration.getRegistry()) {
			variableNames.add(variable.getName());
		}
		return variableNames;
	}
}

