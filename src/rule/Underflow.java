package rule;

import java.util.ArrayList;
//import java.util.ArrayList;
import java.util.List;

import util.ValidationRule;

public class Underflow implements ValidationRule{
	List<String> characterCounts = new ArrayList<String>();
	
	@Override
	public boolean isImplement() {
		return false;
	}
	
	@Override
	public void analyze() {
		if(!characterCounts.isEmpty()) {
			characterCounts.clear();
		}
	}

	@Override
	public Criticity getRuleCriticity() {
	    return Criticity.CRITICAL;
	}

	@Override
	public String getRuleName() {
	    return "Underflow";
	}

	@Override
	public String getComment() {
	    return "Note the operation of integer variables";
	}
    
	@Override
	public List<String> getCharacterCounts() {
		return characterCounts;
	}
}
