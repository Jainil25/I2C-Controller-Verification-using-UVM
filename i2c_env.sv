//`include "i2c_agent.sv"
class i2c_env extends uvm_env;
`uvm_component_utils(i2c_env)

  i2c_agent agent;
  i2c_freq_sb sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    agent = i2c_agent::type_id::create("agent", this);
    sb    = i2c_freq_sb::type_id::create("sb", this);
  endfunction : build_phase

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.agent_ap.connect(sb.apb_imp);
    agent.agent_i2cmon_sb.connect(sb.i2c_imp);
  endfunction : connect_phase
endclass : i2c_env
