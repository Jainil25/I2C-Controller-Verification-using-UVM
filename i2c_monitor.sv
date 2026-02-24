
class i2c_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_monitor)
i2c_transaction tx;
  virtual i2c_if vif;
  uvm_analysis_port #(i2c_transaction) mon_port;

  function new(string name = "i2c_monitor", uvm_component parent);
    super.new(name, parent);
    mon_port = new("mon_port", this);
  endfunction

  int clk_count;
  bit last_SCL, last_SDA;

  task run_phase(uvm_phase phase);
  forever begin
@(!vif.PRESET)
    @(posedge vif.PCLK);
	
    clk_count++;

    // Print all APB and Bus inputs to understand DUT
    `uvm_info("I2C_MON_INPUTS", $sformatf(
      "DUT Inputs: PSEL=%0b PENABLE=%0b PWRITE=%0b PADDR=0x%0h PWDATA=0x%0h | SCL_result=%0b SDA_result=%0b",
      vif.PSEL, vif.PENABLE, vif.PWRITE, vif.PADDR, vif.PWDATA, vif.SCL_result, vif.SDA_result
    ), UVM_LOW)

    if (vif.PSEL && vif.PENABLE) begin
       tx = i2c_transaction::type_id::create("tx");
      tx.addr  = vif.PADDR;
      tx.data  = vif.PWDATA;
      tx.write = vif.PWRITE;
    //  mon_port.write(tx);

      `uvm_info("I2C_MON", $sformatf("APB: %s addr=0x%0h data=0x%0h",
                (tx.write) ? "WRITE" : "READ",
                tx.addr, tx.data), UVM_LOW)
	if(vif.PADDR== 5'h04) 
	mon_port.write(tx);
    end

    if ((vif.SCL_drive !== last_SCL) || (vif.SDA_drive !== last_SDA)) begin
      `uvm_info("I2C_MON", $sformatf("I2C Change: SCL=%0b SDA=%0b",
                vif.SCL_drive, vif.SDA_drive), UVM_LOW)
      last_SCL = vif.SCL_drive;
      last_SDA = vif.SDA_drive;
    end

    if (clk_count % 1000 == 0) begin
      `uvm_info("I2C_MON", $sformatf("Monitor alive clk=%0d", clk_count), UVM_LOW)
    end
  end



endtask

endclass



