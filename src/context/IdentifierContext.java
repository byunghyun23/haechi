package context;

import java.util.List;

import node.Identifier;

public class IdentifierContext {
	public List<Identifier> getAllIdentifiers() {
		return Identifier.getRegistry();
	}
}
