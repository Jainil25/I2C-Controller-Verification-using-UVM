

class i2c_ack_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_ack_monitor)
  i2c_transaction  tx1;
  // Interface and analysis port
  virtual i2c_if vif;
  uvm_analysis_port #(bit) ack_port;  // Analysis port to notify driver
  uvm_analysis_port#(i2c_transaction) mon_ap;
  // Constructor
  function new(string name = "i2c_ack_monitor", uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction
  
  // Build phase - get interface and create analysis port
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
      `uvm_fatal("ACK_MON", "Virtual interface not found")

    ack_port = new("ack_port", this);
  endfunction
  
  // Run phase - monitor I2C bus and generate ACKs
  task run_phase(uvm_phase phase);
    bit last_scl = 1;
    bit last_sda = 1;
    int bit_count = 0;
    bit transaction_active = 0;
    int sb_count = 0;
    bit ifdr_check = 0;
    // Initialize I2C lines (pulled up by default)
    vif.SCL_tb = 1;
    vif.SDA_tb = 1;
    
	//tx1 = i2c_transaction::type_id::create ("tx1");
    forever begin
      @(posedge vif.PCLK);
      // IFDR
	if(vif.PADDR == 5'h04 && vif.PWDATA != 0 && ifdr_check == 0) begin 
		tx1 = i2c_transaction::type_id::create ("tx1");
		tx1.addr = vif.PADDR;
		tx1.data = vif.PWDATA;
		mon_ap.write(tx1);
		ifdr_check =1;
        `uvm_info("ACK_MON", $sformatf("Transmitted to IFDR: %h",tx1.data), UVM_LOW)
	end
      // Detect START condition: SDA falls while SCL is high
      if (vif.SCL_drive == 1 && last_sda == 1 && vif.SDA_drive == 0) begin
        `uvm_info("ACK_MON", "START condition detected", UVM_LOW)
        transaction_active = 1;
        bit_count = 0;
	
	//tx.jainil_time = $realtime();
	tx1 = i2c_transaction::type_id::create ("tx1");
	tx1.jainil = 01;
	mon_ap.write(tx1);
      end
      
      // Detect STOP condition: SDA rises while SCL is high
      else if (vif.SCL_drive == 1 && last_sda == 0 && vif.SDA_drive == 1) begin
        `uvm_info("ACK_MON", "STOP condition detected", UVM_LOW)
        transaction_active = 0;
        bit_count = 0;
      end
      
      // Count SCL falling edges (end of each bit)
      if (transaction_active && vif.SCL_drive == 0 && last_scl == 1) begin
        bit_count++;
	sb_count ++;
        `uvm_info("ACK_MON", $sformatf("SCL falling edge #%0d", bit_count), UVM_DEBUG)
	  
	tx1 = i2c_transaction::type_id::create ("tx1");
	tx1.jainil = 10;
	tx1.jainil_time = $realtime();    
	if(sb_count <= 4)mon_ap.write(tx1);
        // On 8th bit falling edge, prepare to send ACK on next SCL low
        if (bit_count == 8) begin
          // Wait for SCL to go high then low (8th bit complete)
          @(posedge vif.SCL_drive);
          @(negedge vif.SCL_drive);
         // @(posedge vif.SDA_drive)
          // Generate ACK (pull SDA low while SCL is low)
          `uvm_info("ACK_MON", "ACK: Pulling SDA_tb LOW", UVM_LOW)
          vif.SDA_tb = 0;
          
          // Notify driver that ACK is being sent
          ack_port.write(1'b1);
          
          // Wait for SCL to go high and then low again (ACK bit complete)
          @(posedge vif.SCL_drive);
          @(negedge vif.SCL_drive);

          // Release SDA line
          vif.SDA_tb = 1;
          `uvm_info("ACK_MON", "ACK released", UVM_LOW)
          
          // Reset bit counter for next byte
          bit_count = 1;
        end
      end
      
      // Update last values
      last_scl = vif.SCL_drive;
      last_sda = vif.SDA_drive;
    end
  endtask
endclass


/*
class i2c_ack_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_ack_monitor)

  virtual i2c_if vif;
  uvm_analysis_port #(bit) ack_port;  // Analysis port to notify driver

  function new(string name = "i2c_ack_monitor", uvm_component parent);
    super.new(name, parent);
    //ack_port = new("ack_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
      `uvm_fatal("ACK_MON", "Virtual interface not found")
      ack_port = new("ack_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    bit last_scl = 1;
    bit last_sda = 1;
    int scl_edge_count = 0;
    bit start_seen = 0;
    bit mult_tran = 0;
    // Idle SDA/SCL pull-up
    vif.SCL_tb = 1;
    vif.SDA_tb = 1;

    forever begin
      @(posedge vif.PCLK);

      // Detect START: SDA falls while SCL is high
      if (!start_seen && (vif.SCL_drive == 1 && last_sda == 1 && vif.SDA_drive == 0)) begin
        start_seen = 1;
        scl_edge_count = 0;
        `uvm_info("ACK_MON", "START condition detected", UVM_LOW)
      end

      // Count rising edges of SCL_drive
      if (start_seen||mult_tran) begin
        if (!vif.SCL_drive && last_scl) begin
          scl_edge_count++;
          `uvm_info("ACK_MON", $sformatf("SCL falling edge #%0d", scl_edge_count), UVM_LOW)
          mult_tran=1;
        end
	end
        // On 9th rising edge → send ACK
        if (scl_edge_count == 9) begin
//#71ns;
          `uvm_info("ACK_MON", "ACK: Pulling SDA_tb LOW", UVM_LOW)
          vif.SDA_tb = 0;
		//vif.SDA_result=0;
`uvm_info("ACK_MON", $sformatf("SDA_TB Value is #%0d at %t", vif.SDA_tb, $realtime()), UVM_LOW)
         // @(!vif.SCL_drive && last_scl) begin
         // scl_edge_count=10;
          `uvm_info("ACK_MON", $sformatf("SCL falling edge 9th #%0d", scl_edge_count), UVM_LOW)
         // end
	   ack_port.write(1'b1);
         // if(scl_edge_count == 10)
         // #300ns;
	@(!vif.SCL_drive && last_scl)
	//@(!vif.SCL_drive && last_sda)
          vif.SDA_tb = 1; // Release line
          `uvm_info("ACK_MON", "ACK released", UVM_LOW)
          start_seen = 0; // Ready for next byte
	  scl_edge_count=0;

        end


    // end

      last_scl = vif.SCL_drive;
      last_sda = vif.SDA_drive;
    end
  endtask
endclass
*/

