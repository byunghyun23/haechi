package util;

import java.util.List;

public interface ValidationRule {
	public enum Criticity {
	    CRITICAL, MAJOR, MINOR
	}
	
	public abstract boolean isImplement();
	public abstract void analyze();
	public abstract Criticity getRuleCriticity();
    public abstract String getRuleName();
    public abstract String getComment();
    public abstract List<String> getCharacterCounts();
}


