package rulecheck;

import java.util.ArrayList;
import java.util.List;
import rule.*;
import util.ValidationRule;

public class RuleRepository {
    private List<ValidationRule> rules = new ArrayList<>();
    
    public RuleRepository() {
        registerRule(new DoSAttack());
        registerRule(new NoneAccessModifier());
        registerRule(new Overflow());
        registerRule(new Underflow());
        registerRule(new Reentrancy());
        registerRule(new TransferEther());
        registerRule(new TxOrigin());
        registerRule(new MultipleInheritance());
        
    }

    private void registerRule(ValidationRule rule) {
        rules.add(rule);
    }

    public List<ValidationRule> getRules() {
        return rules;
    }
}

