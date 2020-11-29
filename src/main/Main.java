package main;

import java.util.List;

import org.json.simple.JSONObject;
import util.Position;
import util.Printer;
import util.Scanner;
import node.ContractDefinition;
import node.FunctionCall;
import node.FunctionDefinition;
import node.ParsingToAST;
import node.VariableDeclaration;
import rulecheck.RuleChecker;
import context.*;

public class Main {
	public static void main(String[] args) {
		String exeTime = "********** EXECUTION TIME **********\r\n";
		long _start;
		long start;
		long end;
		
		String inputFile = "";
		String json = "";
		try {
			inputFile = args[0];
		} catch (IndexOutOfBoundsException e) {
			e.printStackTrace();
		}
	
		_start = System.currentTimeMillis();
		Scanner scanner = new Scanner();
		json = scanner.createJson(inputFile);
		end = System.currentTimeMillis();
		exeTime += String.format("scanning time : %.3f sec\r\n", (end - _start) / 1000.0);
		
		start = System.currentTimeMillis();
		ParsingToAST parsingToAST = new ParsingToAST();
		JSONObject jsonObject = parsingToAST.parse(json);
		parsingToAST.visitNode(jsonObject);
		end = System.currentTimeMillis();
		exeTime += String.format("parsing time : %.3f sec\r\n", (end - start) / 1000.0);
		
		Position.setup(inputFile);
		
		start = System.currentTimeMillis();
		Printer printer = new Printer();
		printer.init();
		printer.emit(inputFile);
		end = System.currentTimeMillis();
		exeTime += String.format("emitting time : %.3f sec\r\n", (end - start) / 1000.0);
		
		start = System.currentTimeMillis();
		RuleChecker ruleChecker = new RuleChecker();
		ruleChecker.ruleCheck();
		end = System.currentTimeMillis();
		exeTime += String.format("ruleChecking time : %.3f sec\r\n", (end - start) / 1000.0);
		
		exeTime += String.format("total time : %.3f sec\r\n", (end - _start) / 1000.0);
		
		System.out.println(ruleChecker.getResults());
		System.out.println(ruleChecker.getCriticityCount());
		
		ContractContext contractContext = new ContractContext();
		List<ContractDefinition> contractContextList = contractContext.getAllContract();
		VariableContext variableContext = new VariableContext();
		List<VariableDeclaration> variableList = variableContext.getAllVariables();
		FunctionDefinitionContext functionDefinitionContext = new FunctionDefinitionContext();
		List<FunctionDefinition> functionDefinitionList = functionDefinitionContext.getAllFunctionDefinitions();
		FunctionCallContext functionCallContext = new FunctionCallContext();
		List<FunctionCall> functionCallsList = functionCallContext.getAllFunctionCalls();
		System.out.println("********** CONTEXT COUNT **********");
		System.out.println("contract : " + contractContextList.size());
		System.out.println("variable : " + variableList.size());
		System.out.println("funcDef : " + functionDefinitionList.size());
		System.out.println("funcCall : " + functionCallsList.size());
		System.out.println();
		
		System.out.println(exeTime);
		
	}
}