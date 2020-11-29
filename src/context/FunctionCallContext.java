package context;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import node.FunctionCall;
import util.Position;

public class FunctionCallContext {
	public List<FunctionCall> getAllFunctionCalls() {
		return FunctionCall.getRegistry();
	}
	
	@SuppressWarnings("unchecked")
	public JSONArray getAllFunctionCallInfo() {
		Position position = new Position();

		List<FunctionCall> functionCallContextList = getAllFunctionCalls();
		
		JSONArray functionCallArray;
		JSONObject functionCallInfo = new JSONObject();
		
		functionCallArray = new JSONArray();
		for(FunctionCall functionCall : functionCallContextList) {
			functionCallInfo = new JSONObject();
			functionCallInfo.put("id", functionCall.getId());
			functionCallInfo.put("caller", functionCall.getName());
			functionCallInfo.put("name", functionCall.getMemberName());
			functionCallInfo.put("line", position.getLineNumber(functionCall.getCharacterCount()));
			functionCallArray.add(functionCallInfo);
		}
		
		return functionCallArray;
	}
	
	public List<String> getAllFunctionCallNames() {
		List<String> functionCallNames = new ArrayList<String>();
		
		for(FunctionCall functionCall : FunctionCall.getRegistry()) {
			functionCallNames.add(functionCall.getName());
		}
		return functionCallNames;
	}
	
	public List<String> getAllFunctionCallMemberNames() {
		List<String> functionCallMemberName = new ArrayList<String>();
		
		for(FunctionCall functionCall : FunctionCall.getRegistry()) {
			functionCallMemberName.add(functionCall.getMemberName());
		}
		return functionCallMemberName;
	}
	
	public List<FunctionCall> getAllRequires() {
		List<FunctionCall> requires = new ArrayList<FunctionCall>();
		
		for(FunctionCall functionCall : FunctionCall.getRegistry()) {
			if(functionCall.getName().equals("require")) 
				requires.add(functionCall);
		}
		return requires;
	}
	
	public List<FunctionCall> getAllAsserts() {
		List<FunctionCall> asserts = new ArrayList<FunctionCall>();
		
		for(FunctionCall functionCall : FunctionCall.getRegistry()) {
			if(functionCall.getName().equals("assert")) 
				asserts.add(functionCall);
		}
		return asserts;
	}
	
	public List<FunctionCall> getAllReverts() {
		List<FunctionCall> reverts = new ArrayList<FunctionCall>();
		
		for(FunctionCall functionCall : FunctionCall.getRegistry()) {
			if(functionCall.getName().equals("revert")) 
				reverts.add(functionCall);
		}
		return reverts;
	}
}

