/*
interface i2c_if(input logic PCLK);

  logic PRESET;
  logic [4:0] PADDR;
  logic PSEL;
  logic PENABLE;
  logic PWRITE;
  logic [31:0] PWDATA;
  logic PREADY;
  logic [31:0] PRDATA;
  logic PSLVERR;
  logic Interrupt;
  logic SCL_drive, SCL_result;
  logic SDA_drive, SDA_result;

  modport DUT (
    input PCLK, PRESET, PADDR, PSEL, PENABLE, PWRITE, PWDATA, SCL_result, SDA_result,
    output PREADY, PRDATA, PSLVERR, Interrupt, SCL_drive, SDA_drive
  );

endinterface
*/
interface i2c_if(input logic PCLK);

  // Reset signal
  logic PRESET;

  // APB Interface
  logic [4:0]  PADDR;
  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;
  logic [31:0] PWDATA;
  logic        PREADY;
  logic [31:0] PRDATA;
  logic        PSLVERR;

  // Interrupt
  logic        Interrupt;

  // I2C signals
  logic        SCL_drive;
  logic        SCL_result;
  logic        SDA_drive;
  logic        SDA_result;


logic SCL_tb, SDA_tb;        // driven by testbench (simulates slave or monitor)


// Open-drain bus simulation (wired-AND)



  // Optional: Clocking block for UVM (helps with proper timing control)
 /* clocking cb @(posedge PCLK);
   default input #1step output #1step;

    // APB signals
    output PADDR, PSEL, PENABLE, PWRITE, PWDATA;
    input  PREADY, PRDATA, PSLVERR;

    // I2C lines
    input SCL_drive, SDA_drive;
    output  SCL_result, SDA_result;

    // Interrupt
    input Interrupt;
  endclocking
*/

modport tb_if (
    // APB signals
    output PADDR,
    output PSEL,
    output PENABLE,
    output PWRITE,
    output PWDATA,
    input  PREADY,
    input  PRDATA,
    input  PSLVERR,

    // I2C lines
    input  SCL_drive,
    input  SDA_drive,
    output SCL_result,
    output SDA_result,

    // Interrupt
    input Interrupt
);



endinterface
