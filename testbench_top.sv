`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
//import i2c_pkg::*;
`include "all.sv"
//`include "i2c_if.sv"
`include "i2c_defs.sv"
`include "i2c.sv"




module testbench_top;

  import uvm_pkg::*;

     bit set_success;
  bit clk;
  bit rst_n;

  // 👉 ADD virtual interface handle
  virtual i2c_if vif;

  // Instantiate the DUT interface
  i2c_if i2c_if_inst(clk);
//assign i2c_if_inst.PRESET = rst_n;

  // Instantiate the DUT
  i2c dut (
    .PCLK(i2c_if_inst.PCLK),
    .PRESET(i2c_if_inst.PRESET),
    .PADDR(i2c_if_inst.PADDR),
    .PSEL(i2c_if_inst.PSEL),
    .PENABLE(i2c_if_inst.PENABLE),
    .PWRITE(i2c_if_inst.PWRITE),
    .PWDATA(i2c_if_inst.PWDATA),
    .PREADY(i2c_if_inst.PREADY),
    .PRDATA(i2c_if_inst.PRDATA),
    .PSLVERR(i2c_if_inst.PSLVERR),
    .Interrupt(i2c_if_inst.Interrupt),
    .SCL_drive(i2c_if_inst.SCL_drive),
    .SDA_drive(i2c_if_inst.SDA_drive),
    .SCL_result(i2c_if_inst.SCL_result),
    .SDA_result(i2c_if_inst.SDA_result)
  );
assign i2c_if_inst.SDA_result = i2c_if_inst.SDA_drive && i2c_if_inst.SDA_tb;
assign i2c_if_inst.SCL_result = i2c_if_inst.SCL_drive && i2c_if_inst.SCL_tb;


  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100MHz clock (10ns period)
  end

  // Reset generation
 initial begin
    i2c_if_inst.PRESET = 1;
    #20;
    i2c_if_inst.PRESET = 0;

  end
initial begin
    $dumpfile("testbench_top.vcd");
	$dumpvars;
  end
  // Interface and UVM setup
  initial begin
    vif = i2c_if_inst; // 👈 Connect virtual interface

  

$display("SDA_Result: %d", i2c_if_inst.SDA_result);

    // Set the virtual interface in the UVM config_db
    uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", vif);
    
    // Verify that the virtual interface was correctly set
    if (!uvm_config_db#(virtual i2c_if)::get(null, "*", "vif", vif)) begin
        `uvm_fatal("VIF_NOT_SET", "Failed to set the virtual interface")
    end else begin
        `uvm_info("VIF_SET", "Virtual interface set successfully", UVM_MEDIUM)
    end
    i2c_if_inst.SCL_tb = 0;
  i2c_if_inst.SDA_tb = 0;

    // Start the UVM test
    run_test("i2c_test"); // Your test class name
    
    #100000000;
    $finish();
end
endmodule

