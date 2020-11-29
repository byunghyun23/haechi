package context;

import java.util.List;
import java.util.ArrayList;

import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import node.ContractDefinition;
import util.Position;

public class ContractContext{
	public List<ContractDefinition> getAllContract() {
		return ContractDefinition.getRegistry();
	}
	
	@SuppressWarnings("unchecked")
	public JSONArray getAllContractInfo() {

		Position position = new Position();
		List<ContractDefinition> allContractDefinition = getAllContract();
		
		JSONArray contractArray;
		JSONObject contractInfo = new JSONObject();
		
		contractArray = new JSONArray();
		for(ContractDefinition contractDefinition : allContractDefinition) {
			contractInfo = new JSONObject();
			contractInfo.put("id", contractDefinition.getId());
			contractInfo.put("name", contractDefinition.getName());
			contractInfo.put("kind", contractDefinition.getContractKind());
			contractInfo.put("line", position.getLineNumber(contractDefinition.getCharacterCount()));
			contractArray.add(contractInfo);
		}
		
		return contractArray;
	}
	
	public List<String> getAllContractNames() {
		List<String> contractNames = new ArrayList<String>();
		
		for(ContractDefinition contract : ContractDefinition.getRegistry()) {
			contractNames.add(contract.getName());
		}
		return contractNames;
	}
}


