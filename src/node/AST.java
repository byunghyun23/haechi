package node;

import java.util.List;

public class AST {
	AST parent = null;
	List<AST> children;
	String nodeType;
	
	public AST getParent() {
		return parent;
	}
	
	public List<AST> getChildren() {
		return children;
	}
	
	public String getNodeType() {
		return nodeType;
	}
}

