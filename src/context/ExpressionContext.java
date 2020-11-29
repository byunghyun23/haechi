package context;

import java.util.ArrayList;
import java.util.List;

import node.AST;
import node.Expression;

public class ExpressionContext {
	public List<Expression> getAllExpressions() {
		return Expression.getRegistry();                                                                                                                             
	}
	
	public List<Expression> getAllTransfers() {
		List<Expression> transfers = new ArrayList<Expression>();
		
		for(Expression expression : Expression.getRegistry()) {
			if(expression.getMemberName() != null) {
				if(expression.getMemberName().equals("transfer")) {
					transfers.add(expression);
				}
			}	
		}
		return transfers;
	}
	
	public List<Expression> getAllSends() {
		List<Expression> sends = new ArrayList<Expression>();
		
		for(Expression expression : Expression.getRegistry()) {
			if(expression.getMemberName() != null) {
				if(expression.getMemberName().equals("send")) {
					sends.add(expression);
				}
			}
		}
		return sends;
	}
	
	public List<Expression> getAllCalls() {
		List<Expression> calls = new ArrayList<Expression>();
		
		for(Expression expression : Expression.getRegistry()) {
			if(expression.getMemberName() != null) {
				if(expression.getMemberName().equals("call")) {
					calls.add(expression);
				}
			}
		}
		return calls;
	}
	
	public List<Expression> getAllDelegateCalls() {
		List<Expression> delegateCalls = new ArrayList<Expression>();
		
		for(Expression expression : Expression.getRegistry()) {
			if(expression.getMemberName() != null) {
				if(expression.getMemberName().equals("delegatecall")) {
					delegateCalls.add(expression);
				}
			}
		}
		return delegateCalls;
	}
	
	public List<Expression> getAllOperations() {
		List<Expression> OperationList = new ArrayList<Expression>();
		
		for(Expression expr : Expression.getRegistry()) {
			if(expr.getOperator() != null) {
				OperationList.add(expr);
			}
		}
		return OperationList;
	}
	
	public List<Expression> getAllTxOrigins() {
		List<Expression> txOrigins = new ArrayList<Expression>();
		
		for(Expression expression : Expression.getRegistry()) {
			if(expression.getMemberName() != null) {
				boolean found = false;
				try {
					if(expression.getMemberName().equals("origin")) {
						for(AST child : expression.getChildren()) {
							try {
								if(((Expression) child).getNodeType().equals("Identifier") && ((Expression) child).getName().equals("tx")) {
									found = true;
									break;
								}
							} catch (ClassCastException e) {
								;
							}
						}
					}
				} catch (NullPointerException e) {
					//e.printStackTrace();
				}
				
				if(found) {
					txOrigins.add(expression);
				}
			}
		}
		return txOrigins;
	}
	
	public List<Expression> getAllBlockMembers() {
		List<Expression> blockMembers = new ArrayList<Expression>();
		
		for(Expression expression : Expression.getRegistry()) {
			if(expression.getMemberName() != null) {
				boolean found = false;
				if(expression.getMemberName().equals("coinbase") ||
						expression.getMemberName().equals("timestamp") ||
						expression.getMemberName().equals("gaslimit") ||
						expression.getMemberName().equals("number") ||
						expression.getMemberName().equals("blockhash")) {
					for(AST child : expression.getChildren()) {
						if(((Expression) child).getNodeType().equals("Identifier") && ((Expression) child).getName().equals("block")) {
							found = true;
							break;
						}
					}
					if(found) {
						blockMembers.add(expression);
					}
				}
			}
		}
		return blockMembers;
	}
}
