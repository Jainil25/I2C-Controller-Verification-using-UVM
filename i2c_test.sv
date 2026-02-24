//`include "i2c_env.sv"
//`include "i2c_sequence.sv" // Include your sequence file

class i2c_test extends uvm_test;
  `uvm_component_utils(i2c_test)
i2c_basic_sequence seq;
  i2c_env env;

  function new(string name = "i2c_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = i2c_env::type_id::create("env", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("I2C_TEST", "Starting APB transaction sequence...", UVM_LOW)

    
    
    seq = i2c_basic_sequence::type_id::create("seq",this);

    seq.start(env.agent.seqr); 

    // Let simulation run for a little after the sequence
    #100000;

    phase.drop_objection(this);
  endtask : run_phase
endclass : i2c_test

