package node;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class ParsingToAST {
	AST ast = new AST();
	
	public JSONObject parse(String json) {
		JSONParser parser = new JSONParser();
		JSONObject jsonObject = null;
		try {
			jsonObject = (JSONObject) parser.parse(json); 
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return jsonObject;
	}

	public void visitNode(JSONObject jsonObject) {
		JSONArray nodes = (JSONArray) jsonObject.get("nodes"); 
		try {
			for(int i=0; i<nodes.size(); i++){ 
				JSONObject node = (JSONObject) nodes.get(i);
				addNode(node, ast);
			}
		} catch (NullPointerException e) {
			e.printStackTrace();
		}
	}
	
	public void addNode(JSONObject node, AST parent) {
		if(node.get("nodeType").equals("VariableDeclaration"))
			visitVariableDeclaration(node, parent);
		if(node.get("nodeType").equals("ContractDefinition"))
			visitContractDefinition(node, parent);
//		if(node.get("nodeType").equals("EventDefinition"))
//			visitEventDefinition(node, parent);
		if(node.get("nodeType").equals("FunctionDefinition"))
			visitFunctionDefinition(node, parent);
		if(node.get("nodeType").equals("ModifierDefinition"))
			visitModifierDefinition(node, parent);
//		if(node.get("nodeType").equals("PragmaDirective"))
//			visitPragmaDirective(node, parent);
//		if(node.get("nodeType").equals("ImportDirective"))
//			visitImportDirective(node, parent);
//		if(node.get("nodeType").equals("StructDefinition"))
//			visitStructDefinition(node, parent);
	}
	
	public void visitVariableDeclaration(JSONObject node, AST parent) {
		VariableDeclaration variableDeclaration = new VariableDeclaration(node);
		variableDeclaration.parent = parent;
		
		if(parent.children != null) {
			parent.children.add(variableDeclaration);
		}
	}
	
	public void visitVariableDeclarationStatement(JSONObject node, AST parent) {
		VariableDeclarationStatement variableDeclarationStatementInstance = new VariableDeclarationStatement(node);
		variableDeclarationStatementInstance.parent = parent;
		if(parent.children != null) {
			parent.children.add(variableDeclarationStatementInstance);
		}
		
		JSONArray declaration = (JSONArray) node.get("declarations");
		for(int i=0; i<declaration.size(); i++) {
			JSONObject temp = (JSONObject) declaration.get(i);
			if(temp.containsKey("name"))
				visitVariableDeclaration((JSONObject) declaration.get(i), variableDeclarationStatementInstance);
//			if(node.containsKey("initialValue"))
//			initialValue(node.get("initialValue"), variableDeclarationStatementInstance, "variableDeclarationInitialValue");
		}
	}
	
	public void visitContractDefinition(JSONObject node, AST parent) {
		ContractDefinition contractDefinition = new ContractDefinition(node);
		contractDefinition.parent = parent;
		if(parent.children != null) {
			parent.children.add(contractDefinition);
		}
		
		JSONArray nodes = (JSONArray) node.get("nodes");
		try {
			for(int i=0; i<nodes.size(); i++){ 
				addNode((JSONObject)nodes.get(i), contractDefinition);
			}
		} catch (NullPointerException e) {
			// e.printStackTrace();
		}
	}
	
	public void visitModifierDefinition(JSONObject node, AST parent) {
		ModifierDefinition modifierDefinition = new ModifierDefinition(node);
		modifierDefinition.parent = parent;
		if(parent.children != null) {
			parent.children.add(modifierDefinition);
		}
		
		JSONObject body = (JSONObject) node.get("body");
		JSONArray statement = (JSONArray) body.get("statements");
		for(int i=0; i<statement.size(); i++) {
			visitStatement((JSONObject) statement.get(i), modifierDefinition);
		}
	}
	
	public void visitFunctionDefinition(JSONObject node, AST parent) {
		FunctionDefinition functionDefinition = new FunctionDefinition(node);
        functionDefinition.parent = parent;
		if(parent.children != null) {
			parent.children.add(functionDefinition);
		}
		
        JSONObject body = (JSONObject) node.get("body");
        if(body != null) {
    		JSONArray statement = (JSONArray) body.get("statements");
    		for(int i=0; i<statement.size(); i++) {
    			if(statement.get(i) != null) {
    				if(statement.get(i) != null)
    					visitStatement((JSONObject) statement.get(i), functionDefinition);
    			}
    		}
    		JSONObject temp = (JSONObject) node.get("parameters");
    		JSONArray parameters = (JSONArray) temp.get("parameters");
    		for(int i=0; i<parameters.size(); i++) {
    			visitVariableDeclaration((JSONObject) parameters.get(i), functionDefinition);
    		}
        }
	}
	
	public void visitEventDefinition(JSONObject node, AST parent) {
		EventDefinition eventDefinition = new EventDefinition(node);
		eventDefinition.parent = parent;
		if(parent.children != null) {
			parent.children.add(eventDefinition);
		}
	}
	
	public void visitStatement(JSONObject node, AST parent) {
		if(node.get("nodeType").equals("VariableDeclarationStatement"))
			visitVariableDeclarationStatement(node, parent);
		if(node.get("nodeType").equals("IfStatement"))
			visitIfStatement(node, parent);
		if(node.get("nodeType").equals("WhileStatement"))
			visitWhileStatement(node, parent);
		if(node.get("nodeType").equals("ForStatement"))
			visitForStatement(node, parent);	
		if(node.get("nodeType").equals("DoWhileStatement"))
			visitDoWhileStatement(node, parent);
		if(node.get("nodeType").equals("Return"))
			visitReturnStatement(node, parent); 
		else if(node.get("nodeType").equals("ExpressionStatement"))
			visitExpressionStatement(node, parent);
	}
	
	public void visitExpression(JSONObject node, AST parent, String typeOfExpression) {
		Expression expressionInstance = new Expression(node, typeOfExpression);
		expressionInstance.parent = parent;
		if(parent.children != null) {
			parent.children.add(expressionInstance);
		}
		
		if(node.containsKey("expression"))
			visitExpression((JSONObject) node.get("expression"), expressionInstance, "expression");
		if(node.containsKey("leftHandSide"))
			visitExpression((JSONObject) node.get("leftHandSide"), expressionInstance, "leftHandSide");
		if(node.containsKey("rightHandSide"))
			visitExpression((JSONObject) node.get("rightHandSide"), expressionInstance, "rightHandSide");
		if(node.containsKey("leftExpression"))
			visitExpression((JSONObject) node.get("leftExpression"), expressionInstance, "leftExpression");
		if(node.containsKey("rightExpression"))
			visitExpression((JSONObject) node.get("rightExpression"), expressionInstance, "rightExpression");
		if(node.containsKey("subExpression"))
			visitExpression((JSONObject) node.get("subExpression"), expressionInstance, "subExpression");
		if(node.containsKey("baseExpression"))
			visitExpression((JSONObject) node.get("baseExpression"), expressionInstance, "baseExpression");
		if(node.containsKey("indexExpression"))
			visitExpression((JSONObject) node.get("indexExpression"), expressionInstance, "indexExpression");
		if(node.containsKey("components")) {
			JSONArray component = (JSONArray) node.get("statements");
			for(int i=0; i<component.size(); i++)
				visitExpression((JSONObject) component.get(i), expressionInstance, "component");
		}
		
		if(node.get("nodeType").equals("FunctionCall")) {
			FunctionCall functionCall = new FunctionCall(node);
			functionCall.parent = expressionInstance;
			
			if(parent.children != null) {
				parent.children.add(functionCall);
			}
			
			if(node.containsKey("arguments")) {
				JSONArray argument = (JSONArray) node.get("arguments");
				for(int i=0; i<argument.size(); i++) {
					visitExpression((JSONObject) argument.get(i), functionCall, "functionCallArgument");
				}
			}
		}
		
		if(node.get("nodeType").equals("Identifier")) {
			Identifier identifier = new Identifier(node, typeOfExpression);
			identifier.parent = expressionInstance;
			if(parent.children != null) {
				parent.children.add(identifier);
			}
		}
	}
	
	public void visitReturnStatement(JSONObject node, AST parent) {
		if(node.containsKey("expression")) {
			visitExpression((JSONObject) node, parent, "returnStatement");
		}
	}
	
	public void visitExpressionStatement(JSONObject node, AST parent) {
		ExpressionStatement expressionStatementInstance = new ExpressionStatement(node);
		expressionStatementInstance.parent = parent;
		if(parent.children != null) {
			parent.children.add(expressionStatementInstance);
		}
		
		if(node.get("expression") != null)
			visitExpression((JSONObject) node.get("expression"), expressionStatementInstance, "expressionStatement");
	}
	
	public void visitIfStatement(JSONObject node, AST parent) {
		IfStatement ifStatementInstance = new IfStatement(node);
		ifStatementInstance.parent = parent;
		if(parent.children != null) {
			parent.children.add(ifStatementInstance);
		}
		
		if(node.get("condition") != null) {
			visitExpression((JSONObject) node.get("condition"), ifStatementInstance, "ifStatementCondition");
		}
		if(node.get("trueBody") != null) {
			JSONObject temp = (JSONObject) node.get("trueBody");
			if(temp.get("statements") != null) {
				JSONArray statement = (JSONArray) temp.get("statements");
				for(int i=0; i<statement.size(); i++) {
					visitStatement((JSONObject) statement.get(i), ifStatementInstance);
				}
			}
			if(temp.get("expression") != null) { // only a single expression without {}
				visitExpression((JSONObject) temp.get("expression"), ifStatementInstance, "ifStatementFalsebody");
			}
		}
		if(node.get("falseBody") != null) {
			JSONObject temp = (JSONObject) node.get("falseBody");
			if(temp.get("statements") != null) {
				JSONArray statement = (JSONArray) temp.get("statements");
				for(int i=0; i<statement.size(); i++) {
					visitStatement((JSONObject) statement.get(i), ifStatementInstance);
				}
			}
			if(temp.get("expression") != null) { // only a single expression without {}
				visitExpression((JSONObject) temp.get("expression"), ifStatementInstance, "ifStatementFalsebody");
			}
		}
	}
	
	public void visitWhileStatement(JSONObject node, AST parent) {
		WhileStatement whileStatementInstance = new WhileStatement(node);
		whileStatementInstance.parent = parent;
		if(parent.children != null) {
			parent.children.add(whileStatementInstance);
		}
		
		if(node.get("condition") != null) {
			visitExpression((JSONObject) node.get("condition"), whileStatementInstance, "whileStatementCondition");
		}
		JSONObject temp = (JSONObject) node.get("body");
		if(temp.get("statements") != null) {
			JSONArray statement = (JSONArray) temp.get("statements");
			for(int i=0; i<statement.size(); i++) {
				visitStatement((JSONObject) statement.get(i), whileStatementInstance);
			}
		}
		if(temp.get("expression") != null) { // only a single expression without {}
			JSONArray statement = (JSONArray) temp.get("statements");
			for(int i=0; i<statement.size(); i++) {
				visitExpression((JSONObject) temp.get("expression"), whileStatementInstance, "whileStatementBody");
			}
		}
	}
	
	public void visitForStatement(JSONObject node, AST parent) {
		ForStatement forStatementInstance = new ForStatement(node);
		forStatementInstance.parent = parent;
		
		if(parent.children != null) {
			parent.children.add(forStatementInstance);
		}
		
		if(node.get("condition") != null) {
			visitExpression((JSONObject) node.get("condition"), forStatementInstance, "forStatementCondition");
		}
		if(node.get("loopExpression") != null) {
			visitExpression((JSONObject) node.get("loopExpression"), forStatementInstance, "forStatementLoopExpression");
		}
		JSONObject temp = (JSONObject) node.get("body");
		if(temp.get("statements") != null) {
			JSONArray statement = (JSONArray) temp.get("statements");
			for(int i=0; i<statement.size(); i++) {
				visitStatement((JSONObject) statement.get(i), forStatementInstance);
			}
		}
		if(temp.get("expression") != null) {
			JSONArray statement = (JSONArray) temp.get("expression");
			for(int i=0; i<statement.size(); i++) {
				visitExpression((JSONObject) temp.get("expression"), forStatementInstance, "forStatementBody");
			}
		}
		
		//TODO : Evaluate initializationExpression
	}
	
	public void visitDoWhileStatement(JSONObject node, AST parent) {
		DoWhileStatement doWhileStatementInstance = new DoWhileStatement(node);
		doWhileStatementInstance.parent = parent;
		if(parent.children != null) {
			parent.children.add(doWhileStatementInstance);
		}
		
		if(node.get("condition") != null) {
			visitExpression((JSONObject) node.get("condition"), doWhileStatementInstance, "doWhileCondition");
		}
		JSONObject temp = (JSONObject) node.get("body");
		if(temp.get("statements") != null) {
			JSONArray statement = (JSONArray) temp.get("statements");
			for(int i=0; i<statement.size(); i++) {
				visitStatement((JSONObject) statement.get(i), doWhileStatementInstance);
			}
		}
		if(temp.get("expression") != null) {
			visitExpression((JSONObject) temp.get("expression"), doWhileStatementInstance, "doWhileExpression");
		}
	}
}
