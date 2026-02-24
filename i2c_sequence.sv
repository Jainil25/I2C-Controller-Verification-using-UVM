//`include "i2c_transaction.sv"
class i2c_basic_sequence extends uvm_sequence #(i2c_transaction);
  `uvm_object_utils(i2c_basic_sequence)

  function new(string name = "i2c_basic_sequence");
    super.new(name);
  endfunction : new

  task body();
i2c_transaction tx;
tx = i2c_transaction::type_id::create("tx");
`uvm_info("I2C_SEQ_body_start", "", UVM_LOW)
tx.reset=1;

    start_item(tx);
`uvm_info("I2C_SEQ_Start", "", UVM_LOW)
    finish_item(tx); /*
`uvm_info("I2C_SEQ_Finish", "", UVM_LOW)
tx = i2c_transaction::type_id::create("tx");
`uvm_info("I2C_SEQ_body_start", "", UVM_LOW)
tx.reset=0;

    start_item(tx);
`uvm_info("I2C_SEQ_Start", "", UVM_LOW)
    finish_item(tx);
`uvm_info("I2C_SEQ_Finish", "", UVM_LOW)*/

  // 1. Set Frequency Divider
    
    tx = i2c_transaction::type_id::create("tx");
`uvm_info("I2C_SEQ_body", "", UVM_LOW)
    tx.addr = 5'h04;
    tx.write = 1;
tx.reset=0;
    tx.data = 32'h00000020;
    start_item(tx);
`uvm_info("I2C_SEQ_Start", "", UVM_LOW)
    finish_item(tx);
`uvm_info("I2C_SEQ_Finish", "", UVM_LOW)
    //#1;
// Control Enable
tx = i2c_transaction::type_id::create("tx");
`uvm_info("I2C_SEQ_body", "", UVM_LOW)
    tx.addr = 5'h08;
    tx.write = 1;
tx.reset=0;
    tx.data = 32'h00000080;
    start_item(tx);
`uvm_info("I2C_SEQ_Start", "", UVM_LOW)
    finish_item(tx);
`uvm_info("I2C_SEQ_Finish", "", UVM_LOW)
    // 3. Set Slave Address
  tx = i2c_transaction::type_id::create("slave_addr");
  tx.addr = 5'h00; // I2C_IADR
  tx.data = 32'h00000052;
  tx.write = 1;
tx.reset=0;
  start_item(tx);
`uvm_info("I2C_SEQ_Start_2", "", UVM_LOW)
  finish_item(tx);
`uvm_info("I2C_SEQ_Finish_2", "", UVM_LOW)
//#1;
 /* // 3. Enable I2C Controller
  tx = i2c_transaction::type_id::create("enable");
  tx.addr = 5'h08; // I2C_I2CR
  tx.data = 32'h00000080; // IEN=1
  tx.write = 1;
tx.reset=0;
  start_item(tx);
  finish_item(tx);
#1;*/
  // 4. Set Master Mode, Start Transmission
  tx = i2c_transaction::type_id::create("start_master");
  tx.addr = 5'h08; // I2C_I2CR again
  tx.data = 32'h000000F0; // IEN=1, MSTA=1, MTX=1
  tx.write = 1;
tx.reset=0;
  start_item(tx);
  finish_item(tx);
  //#1;

/*
  // 5. Write Data to I2C Bus (send one byte to slave)

tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR address (Data Register)
tx.data = 32'h00000051; 
tx.write = 1;
tx.reset=0;
tx.SDA_result=0;
start_item(tx);
finish_item(tx);

#1;
tx = i2c_transaction::type_id::create("send_interrupt_IIEN");
tx.addr = 5'h08; // I2C_I2DR address (Data Register)
tx.data = 32'h000000F0; // Interrupt high
//tx.write = 1;
//tx.reset=0;
//tx.SDA_result=0;
start_item(tx);
finish_item(tx);

#2126ns;
tx = i2c_transaction::type_id::create("send_interrupt_bit");
tx.addr = 5'h0C; // I2C_SR
tx.data = 32'h00000001; // Interrupt high
//tx.write = 1;
//tx.reset=0;
//tx.SDA_result=0;
start_item(tx);
finish_item(tx);


repeat(4) begin
#350ns;
// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2SR 
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside SEQ",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end


// Step 5: Enable interrupt (IIEN = 1)
tx = i2c_transaction::type_id::create("enable_interrupt");
tx.addr = 5'h08; // I2C_I2CR
tx.data = 32'h000000F0; // IEN + IIEN + MSTA + MTX = 0b11110000
tx.write = 1;
start_item(tx);
finish_item(tx);

repeat(20) begin

// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2SR 
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside SEQ",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end
*/
// Step 6: Write data
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR
tx.data = 32'h00000060;
tx.write = 1;

start_item(tx);
finish_item(tx);



repeat(200) begin
//do begin
// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2SR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;

start_item(tx);
finish_item(tx);
`uvm_info("Inside SEQ after write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end
/*
// Stop condition

  tx = i2c_transaction::type_id::create("start_master");
  tx.addr = 5'h08; // I2C_I2CR again
  tx.data = 32'h000000B0; // IEN=1, MSTA=1, MTX=1
  tx.write = 1;
tx.reset=0;
  start_item(tx);
  finish_item(tx);

repeat(200) begin
//do begin
// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2SR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside SEQ after write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end

// Disable Condition

  tx = i2c_transaction::type_id::create("start_master");
  tx.addr = 5'h08; // I2C_I2CR again
  tx.data = 32'h00000000; // IEN=1, MSTA=1, MTX=1
  tx.write = 1;
tx.reset=0;
  start_item(tx);
  finish_item(tx);

repeat(200) begin
//do begin
// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2SR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside SEQ after write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end

*/

//while(tx.data[7]==0);

// Step Write
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR
tx.data = 32'h00000052;
tx.write = 1;
start_item(tx);
finish_item(tx);



//repeat(200) begin
/*
// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2CR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside Status Reg after 2nd write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end
*/
/*
//Reset
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h08; // I2C_ICR
tx.data = 32'h00000000;
tx.write = 1;
start_item(tx);
finish_item(tx);
*/

repeat(200) begin

// 6 Read
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2SR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside Status Reg after Reset",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end


repeat(200) begin

// 6 Polling
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h08; // I2C_I2CR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside Control Reg after Reset",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end


// Step Write
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR
tx.data = 32'h00000025;
tx.write = 1;
start_item(tx);
finish_item(tx);

repeat(200) begin

// 6 Polling
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2CR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside Status Reg after 3rd write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end





//Stop generation

tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h08; // I2C_I2CR
tx.data = 32'h00000080;
tx.write = 1;
start_item(tx);
finish_item(tx);
/*
repeat(20) begin

// 6 Polling
tx = i2c_transaction::type_id::create("read_data");
tx.addr = 5'h0C; // I2C_I2CR
//tx.data = 32'h00000007; // Some data to send (0xA5 hex)
tx.write = 0;
tx.reset=0;
start_item(tx);
finish_item(tx);
`uvm_info("Inside Status Reg after stop",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
//@(posedge p_sequencer.vif.PCLK); // Small wait after sending
end
*/
/*

// Read configure

tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h08; // I2C_I2CR
tx.data = 32'h000000B0;
tx.write = 1;
start_item(tx);
finish_item(tx);




// 
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_IDR?
tx.data = 32'h000000A3;
tx.write = 0;
start_item(tx);
finish_item(tx);

// Read
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h08; // I2C_I2CR
tx.data = 32'h000000A0;
tx.write = 0;
start_item(tx);
finish_item(tx);


// Step 8: Configure read
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h08; // I2C_I2DR
tx.data = 32'h000000E0;
tx.write = 1;
start_item(tx);
finish_item(tx);
repeat (50) begin
// Step 8: Read the written data
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR
//tx.data = 32'h00000052;
tx.write = 0;
`uvm_info("I2DR Read after write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
start_item(tx);
finish_item(tx);
end

repeat(50) begin
// Step 8: Read the written data
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR
//tx.data = 32'h00000052;
tx.write = 0;
`uvm_info("I2DR Read after write",$sformatf("Tx.data = %h", tx.data),UVM_LOW);
start_item(tx);
finish_item(tx);
end
*/
/*

// Step 7: Wait for interrupt to be asserted (poll I2C_I2SR)
repeat(200) begin
  tx = i2c_transaction::type_id::create("poll_status");
  tx.addr = 5'h0C; // I2C_I2SR
  tx.write = 0;
  start_item(tx);
  finish_item(tx);
  if ((tx.data & 32'h00000002) != 0) begin
    `uvm_info("I2C_SEQ", "IIF interrupt flag set!", UVM_LOW)
    break;
  end
end


// Step 6: Write data
tx = i2c_transaction::type_id::create("send_data");
tx.addr = 5'h10; // I2C_I2DR
tx.data = 32'h00000041;
tx.write = 1;
start_item(tx);
finish_item(tx);
  #100ns;
*/
//`uvm_info("Seq end", )
  endtask : body
endclass : i2c_basic_sequence
