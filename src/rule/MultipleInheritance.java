package rule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import context.ContractContext;
import node.AST;
import node.ContractDefinition;
import node.FunctionDefinition;
import util.ValidationRule;

public class MultipleInheritance implements ValidationRule{
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
		
		ContractContext contractContext = new ContractContext();
		List<ContractDefinition> ContractList = contractContext.getAllContract();
		
		for(ContractDefinition contract : ContractList) {
			JSONArray baseContract = contract.getBaseContract();
			List<Object> baseContractIdList = new ArrayList<Object>();
			
			if(baseContract.size() >= 2) {
				for(int i=0; i<baseContract.size(); i++) {
					JSONObject baseName = (JSONObject)baseContract.get(i);
					baseName = (JSONObject) baseName.get("baseName");
					if(baseName != null) {
						Object baseId = (Object) baseName.get("referencedDeclaration");
						baseContractIdList.add(baseId);
					}
				}
				
				Map<Object, List<FunctionDefinition>> baseContractIdAndFunc = new HashMap<Object, List<FunctionDefinition>>();
				for(Object baseContractId : baseContractIdList) {
					List<FunctionDefinition> baseContractFuncList = new ArrayList<FunctionDefinition>();
					for(ContractDefinition _contract : ContractList) {
						if(_contract.getId().equals(baseContractId)) {
							List<AST> childrenList = _contract.getChildren();
							for(AST children : childrenList) {
								if(children.getNodeType().equals("FunctionDefinition") && !children.getNodeType().equals("ModifierDefinition")) { // 0531 Add ModifierDefinition
									baseContractFuncList.add((FunctionDefinition) children);
								}
							}
						}
					}
					baseContractIdAndFunc.put(baseContractId, (ArrayList<FunctionDefinition>) baseContractFuncList);
				}
				
				List<FuncSignature> FuncSigList = new ArrayList<FuncSignature>();
				for(Object baseContractId : baseContractIdList) {
					List<FunctionDefinition> baseContractFuncList = baseContractIdAndFunc.get(baseContractId);
					for(FunctionDefinition baseContractFunc : baseContractFuncList) {
						List<String> paramNameList = new ArrayList<String>();
						List<String> paramTypeList = new ArrayList<String>();
						
						String funcName = baseContractFunc.getName();
						JSONObject parameters = (JSONObject) baseContractFunc.getParameters();
						JSONArray paramList = null;
						if(parameters != null) {
							paramList = (JSONArray) parameters.get("parameters");
						}
						
						for(int i = 0; i < paramList.size(); i++) {
							JSONObject param = (JSONObject) paramList.get(i);
							String paramName = (String) param.get("name");
							
							JSONObject typeName = (JSONObject) param.get("typeName");
							String paramType = (String) typeName.get("name");
							
							paramNameList.add(paramName);
							paramTypeList.add(paramType);
						}
						FuncSigList.add(new FuncSignature(funcName, paramTypeList));
					}
					
				}
				boolean flag = false;
				for(int i = 0; i < FuncSigList.size() - 1; i++) {
					if(flag) break;
					for(int j = i + 1; j < FuncSigList.size(); j++) {
						if(FuncSigList.get(i).getFuncName().equals(FuncSigList.get(j).getFuncName())) {
							if(FuncSigList.get(i).getParamType().equals(FuncSigList.get(j).getParamType())) {
		    					String count = (String) contract.getSrc();
		    					count = count.split(":")[0];
								characterCounts.add(count);
								//System.out.println(count);
								flag = true;
								break;
							}
						}
					}
				}
			}
		}
	}

	@Override
	public Criticity getRuleCriticity() {
	    return Criticity.MAJOR;
	}

	@Override
	public String getRuleName() {
	    return "Contract characteristics : Multiple Inheritance";
	}

	@Override
	public String getComment() {
	    return "Do not write multiple inheritance";
	}
    
	@Override
	public List<String> getCharacterCounts() {
		return characterCounts;
	}
}

class FuncSignature {
	String funcName = null;
	List<String> paramTypeList = null;
	
	public FuncSignature() {
		
	}
	
	public FuncSignature(String funcName, List<String> paramTypeList) {
		this.funcName = funcName;
		this.paramTypeList = paramTypeList;
	}
	
	public String getFuncName() {
		return funcName;
	}
	
	public List<String> getParamType() {
		return paramTypeList;
	}
 }
