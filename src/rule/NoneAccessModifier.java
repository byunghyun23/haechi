package rule;

import java.util.ArrayList;
import java.util.List;

import context.FunctionDefinitionContext;
import node.FunctionDefinition;
import util.ValidationRule;

public class NoneAccessModifier implements ValidationRule{
List<String> characterCounts = new ArrayList<String>();
	
	@Override
	public boolean isImplement() {
		return true;
	}
	
	@Override
	public void analyze() {
		if(!characterCounts.isEmpty()) {
			characterCounts.clear();
		}
		
		FunctionDefinitionContext functionDefinitionContext = new FunctionDefinitionContext();
		List<FunctionDefinition> FunctionDefinitions = functionDefinitionContext.getAllFunctionDefinitions();
		
		for(FunctionDefinition funcDef : FunctionDefinitions) {
			if(funcDef.getVisibility().equals("")) {
				characterCounts.add(funcDef.getCharacterCount());
			}
		}
	}

	@Override
	public Criticity getRuleCriticity() {
	    return Criticity.MAJOR;
	}

	@Override
	public String getRuleName() {
	    return "None Access Modifier";
	}

	@Override
	public String getComment() {
	    return "Please specify Access Modifier explicitly";
	}
    
	@Override
	public List<String> getCharacterCounts() {
		return characterCounts;
	}
}
