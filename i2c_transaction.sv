class i2c_transaction extends uvm_sequence_item;
`uvm_object_utils(i2c_transaction)
  rand bit [4:0] addr;
  rand bit write;
  rand bit [31:0] data;
rand bit reset;
rand bit SCL_result;
rand bit SDA_result;
rand bit enable;
rand bit psel;
bit [1:0] jainil;
realtime jainil_time;
  function new(string name = "i2c_transaction");
    super.new(name);
  endfunction : new
endclass : i2c_transaction
