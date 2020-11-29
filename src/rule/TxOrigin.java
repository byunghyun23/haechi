package rule;

import java.util.List;
import java.util.ArrayList;

import context.ExpressionContext;
import util.ValidationRule;
import node.Expression;

public class TxOrigin implements ValidationRule{
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
		
		ExpressionContext expressionContext= new ExpressionContext();
		List<Expression> txOrigins = expressionContext.getAllTxOrigins();
		for(Expression txOrigin : txOrigins) {
			characterCounts.add(txOrigin.getCharacterCount());
		}
	}

	@Override
	public Criticity getRuleCriticity() {
	    return Criticity.MAJOR;
	}

	@Override
	public String getRuleName() {
	    return "tx-origin";
	}

	@Override
	public String getComment() {
	    return "Potential vulnerability to tx.origin attack";
	}
    
	@Override
	public List<String> getCharacterCounts() {
		return characterCounts;
	}
}


