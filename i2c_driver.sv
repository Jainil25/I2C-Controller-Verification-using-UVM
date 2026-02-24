



class i2c_driver extends uvm_driver#(i2c_transaction);
`uvm_component_utils(i2c_driver)
  virtual i2c_if vif;
//uvm_analysis_imp #(bit, i2c_driver) ack_imp;
uvm_tlm_analysis_fifo  #(bit) tlm_a_fifo;
bit ack_ready = 0;
  bit first_transaction = 1;
  
  function new(string name = "i2c_driver", uvm_component parent);
    super.new(name, parent);
tlm_a_fifo = new("tlm_a_fifo", this);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Failed to get interface")
     // ack_imp = new("ack_imp", this);
  endfunction : build_phase
/*function void write(bit ack_signal);
    if (ack_signal) begin
      ack_ready = 1;
      `uvm_info("I2C_DRV", "ACK received from monitor", UVM_LOW)
      first_transaction =0;
    end
  endfunction
  */

task run_phase(uvm_phase phase);
//bit first_transaction = 1;
  forever begin
	wait(!vif.PRESET)
    seq_item_port.get_next_item(req);
`uvm_info("I2C_DRV", req.convert2string(), UVM_LOW)
	
    // Setup phase
    vif.PADDR   = req.addr;
    vif.PWRITE  = req.write;
    
    vif.PSEL    = 1;
    vif.PENABLE = 0;
if (req.write)
vif.PWDATA  = req.data;

    @(posedge vif.PCLK); // Setup captured

    // Enable phase
    vif.PENABLE = 1;

    @(posedge vif.PCLK); // Enable captured (monitor sees valid transaction)

	if(vif.PWRITE==0)
	req.data = vif.PRDATA;
    // Complete
    vif.PSEL = 0;
    vif.PENABLE = 0;
`uvm_info("I2C_DRV_Done", req.convert2string(), UVM_LOW)
    seq_item_port.item_done();
//#100ns;
  end
endtask

/*
task run_phase(uvm_phase phase);
forever begin
/*
if (!first_transaction) begin
      `uvm_info("I2C_DRV", "Waiting for ACK from monitor before next transaction", UVM_LOW)
     (tlm_a_fifo.get(bit)) begin
      //@(ack_ready == 1);
      `uvm_info("I2C_DRV", "ACK ready ==1 in monitor", UVM_LOW)
        ack_ready = 0;
	end
    end


    // Get next sequence item
    seq_item_port.get_next_item(req);
    `uvm_info("I2C_DRV", req.convert2string(), UVM_LOW)

    // APB Write/Read Sequence
    vif.PADDR   = req.addr;
    vif.PWRITE  = req.write;
    vif.PSEL    = 1;
    vif.PENABLE = 0;

    if (req.write)
      vif.PWDATA = req.data;

    @(posedge vif.PCLK);   //setup

    vif.PENABLE = 1;
    @(posedge vif.PCLK);	//Enable

    if (!req.write) 
      req.data = vif.PRDATA;

    vif.PSEL = 0;
    vif.PENABLE = 0;

    seq_item_port.item_done();
    `uvm_info("I2C_DRV_Done", req.convert2string(), UVM_LOW)
    //ack_ready=1;
    //first_transaction = 0;
  end
endtask */

endclass : i2c_driver
