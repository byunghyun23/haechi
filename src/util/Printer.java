package util;

import java.io.FileWriter;
import java.io.IOException;

import org.codehaus.jackson.map.ObjectMapper;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import context.ContractContext;
import context.FunctionCallContext;
import context.FunctionDefinitionContext;
import context.VariableContext;

public class Printer {
	JSONObject solidityINFO = null;
	
	@SuppressWarnings("unchecked")
	public void init() {
		solidityINFO = new JSONObject();
		JSONArray jsonArray;
		ContractContext contractContext = new ContractContext();
		jsonArray = contractContext.getAllContractInfo();
		solidityINFO.put("ContractDefinition", jsonArray);
		
		VariableContext variableContext = new VariableContext();
		jsonArray = variableContext.getAllVariableInfo();
		solidityINFO.put("VariableDeclaration", jsonArray);
		
		FunctionDefinitionContext functionDefinitionContext = new FunctionDefinitionContext();
		jsonArray = functionDefinitionContext.getAllFunctionDefinitionInfo();
		solidityINFO.put("functionDefinition", jsonArray);
		
		FunctionCallContext functionCallContext = new FunctionCallContext();
		jsonArray = functionCallContext.getAllFunctionCallInfo();
		solidityINFO.put("functionCall", jsonArray);
	}
	
	public void emit(String fileName) {
		ObjectMapper mapper = new ObjectMapper();
		try {
			String info = "======= " + fileName + " =======" + "\r\n";
			info += mapper.writerWithDefaultPrettyPrinter().writeValueAsString(solidityINFO);
			info = info.replace("  ", "\t");
			FileWriter file = new FileWriter(fileName + ".json");
			file.write(info);
			file.flush();
			file.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
}

