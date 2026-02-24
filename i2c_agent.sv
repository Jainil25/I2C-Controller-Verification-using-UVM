//`include "i2c_driver.sv"
//`include "i2c_monitor.sv"
//`include "i2c_sequencer.sv"
/*
class i2c_agent extends uvm_agent;
`uvm_component_utils(i2c_agent)

  i2c_driver drv;
  i2c_monitor mon;
  i2c_sequencer seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    drv = i2c_driver::type_id::create("drv", this);
    mon = i2c_monitor::type_id::create("mon", this);
    seqr = i2c_sequencer::type_id::create("seqr", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction : connect_phase
endclass : i2c_agent
*/
class i2c_agent extends uvm_agent;
  `uvm_component_utils(i2c_agent)
uvm_analysis_export#(i2c_transaction) agent_ap;
uvm_analysis_export#(i2c_transaction) agent_i2cmon_sb;
  virtual i2c_if vif;  // <- Declare here

  i2c_driver drv;
  i2c_monitor mon;
  i2c_sequencer seqr;
  i2c_ack_monitor ack_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("I2C_AGENT", "Virtual interface not set!")
    end
    agent_ap = new("agent_ap",this);
    agent_i2cmon_sb = new("agent_i2cmon_sb",this);
    drv = i2c_driver::type_id::create("drv", this);
    seqr = i2c_sequencer::type_id::create("seqr", this);
    mon = i2c_monitor::type_id::create("mon", this);
    ack_mon = i2c_ack_monitor::type_id::create("ack_mon",this);
    drv.vif = vif;
    mon.vif = vif;
    ack_mon.vif = vif;
  endfunction

function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  drv.seq_item_port.connect(seqr.seq_item_export);
  ack_mon.mon_ap.connect(agent_ap);
  mon.mon_port.connect(agent_i2cmon_sb);
  //ack_mon.ack_port.connect(drv.ack_imp);
endfunction

endclass

