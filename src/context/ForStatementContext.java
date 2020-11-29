package context;

import java.util.ArrayList;
import java.util.List;

import node.ForStatement;

public class ForStatementContext{
	public List<ForStatement> getAllForStatement() {
		return ForStatement.getRegistry();
	}
	
	public List<Object> getAllForStatementId() {
		List<Object> ForStatementNames = new ArrayList<Object>();
		
		for(ForStatement forStatement : ForStatement.getRegistry()) {
			ForStatementNames.add(forStatement.getId());
		}
		return ForStatementNames;
	}
	
}