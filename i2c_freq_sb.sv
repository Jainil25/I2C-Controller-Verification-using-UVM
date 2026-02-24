class i2c_freq_sb extends uvm_scoreboard;
  `uvm_component_utils(i2c_freq_sb)
bit queue[$];
time queue_time[$];
bit [4:0] queue_freq[$];
bit rec_addr;

 virtual i2c_if vif;
  uvm_analysis_imp #(i2c_transaction,i2c_freq_sb) apb_imp;
  uvm_analysis_imp #(i2c_transaction,i2c_freq_sb) i2c_imp;
  realtime expected_period; // base period for 1 clock
  realtime prev_time;
  realtime delta_time;
  bit first_edge_seen = 0;
  bit [31:0] div_value;
realtime start_time;
realtime end_time;
realtime period;
realtime diff;
bit check = 0;

typedef bit [7:0] ic_addr_t;
  typedef int divider_t;
  divider_t divider_map [ic_addr_t];


function new(string name = "i2c_freq_sb", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
      `uvm_fatal("ACK_MON", "Virtual interface not found")
	apb_imp = new("apb_imp",this);
	i2c_imp = new("i2c_imp",this);
	initialize_divider_map();
endfunction : build_phase



function void initialize_divider_map();
    divider_map[5'h00] = 30;    divider_map[5'h01] = 32;    divider_map[5'h02] = 36;    divider_map[5'h03] = 42;
divider_map[5'h04] = 48;    divider_map[5'h05] = 52;    divider_map[5'h06] = 60;    divider_map[5'h07] = 72;
divider_map[5'h08] = 80;    divider_map[5'h09] = 88;    divider_map[5'h0A] = 104;   divider_map[5'h0B] = 128;
divider_map[5'h0C] = 144;   divider_map[5'h0D] = 160;   divider_map[5'h0E] = 192;   divider_map[5'h0F] = 240;
divider_map[5'h10] = 288;   divider_map[5'h11] = 320;   divider_map[5'h12] = 384;   divider_map[5'h13] = 480;
divider_map[5'h14] = 576;   divider_map[5'h15] = 640;   divider_map[5'h16] = 768;   divider_map[5'h17] = 960;
divider_map[5'h18] = 1152;  divider_map[5'h19] = 1280;  divider_map[5'h1A] = 1536;  divider_map[5'h1B] = 1920;
divider_map[5'h1C] = 2304;  divider_map[5'h1D] = 2560;  divider_map[5'h1E] = 3072;  divider_map[5'h1F] = 3840;
divider_map[5'h20] = 22;    divider_map[5'h21] = 24;    divider_map[5'h22] = 26;    divider_map[5'h23] = 28;
divider_map[5'h24] = 32;    divider_map[5'h25] = 36;    divider_map[5'h26] = 40;    divider_map[5'h27] = 44;
divider_map[5'h28] = 48;    divider_map[5'h29] = 56;    divider_map[5'h2A] = 64;    divider_map[5'h2B] = 72;
divider_map[5'h2C] = 80;    divider_map[5'h2D] = 96;    divider_map[5'h2E] = 112;   divider_map[5'h2F] = 128;
divider_map[5'h30] = 160;   divider_map[5'h31] = 192;   divider_map[5'h32] = 224;   divider_map[5'h33] = 256;
divider_map[5'h34] = 320;   divider_map[5'h35] = 384;   divider_map[5'h36] = 448;   divider_map[5'h37] = 512;
divider_map[5'h38] = 640;   divider_map[5'h39] = 768;   divider_map[5'h3A] = 896;   divider_map[5'h3B] = 1024;
divider_map[5'h3C] = 1280;  divider_map[5'h3D] = 1536;  divider_map[5'h3E] = 1792;  divider_map[5'h3F] = 2048;

  endfunction
/*
function void write(i2c_transaction txn);
  `uvm_info("SB", $sformatf("Received clock edge info: %p and Time : %t", txn.jainil, txn.jainil_time), UVM_MEDIUM)
  queue.push_back(txn.jainil);
  queue_time.push_back(txn.jainil_time);
  queue_freq.push_back(txn.data);
  if (txn.addr == 5'h04 && check !=1) begin
  rec_addr = txn.addr;
  div_value = txn.data;
  `uvm_info("SB", $sformatf("Div Value: %h and data: %h", txn.data,divider_map[div_value]), UVM_LOW)
  check = 1;
  `uvm_info("SB", $sformatf("Received IFDR: %d with size: %h", txn.data, queue_freq.size()), UVM_LOW)
end
endfunction
*/

function void write(i2c_transaction txn);
  `uvm_info("SB", $sformatf("Received clock edge info: %p and Time : %t", txn.jainil, txn.jainil_time), UVM_MEDIUM)

  queue.push_back(txn.jainil);
  queue_time.push_back(txn.jainil_time);
  queue_freq.push_back(txn.data);  // <- push txn.data always

  // Optional debug: show PADDR value and associated divider
  if (txn.addr == 5'h04) begin
    div_value = txn.data;
    if (divider_map.exists(div_value[4:0])) begin
      `uvm_info("SB", $sformatf("Div Value: %h → Expected Period: %0d", div_value[4:0], divider_map[div_value[4:0]]), UVM_LOW)
    end else begin
      `uvm_error("DIV_MAP", $sformatf("No mapping for Div Value: %h", div_value[4:0]))
    end
  end
endfunction




function void write_mon_port(i2c_transaction txn);
  `uvm_info("SB", $sformatf("Received from I2C Monitor %d", txn), UVM_MEDIUM)
  //queue_freq.push_back(txn.data);
endfunction




task run_phase(uvm_phase phase);

  fork
    begin
      monitor_scl();
    end
    begin
      monitor_divider_config();
    end
  join

endtask


task monitor_scl();
  forever begin
  @(posedge vif.SCL_drive) start_time = $time; 
  @(posedge vif.SCL_drive) end_time = $time; 
  period = end_time - start_time;
  
  if(period == expected_period) $display("Pass");
  end
endtask

/*
task monitor_divider_config();
  i2c_transaction txn;
  forever begin
    wait (queue.size() > 0 && queue_time.size()>0);
    txn = new();
    txn.jainil = queue.pop_front();
    //txn.jainil_time = queue_time.pop_front();
`uvm_info("SB", $sformatf("Pop Done: %d and %t", txn.jainil,txn.jainil_time), UVM_MEDIUM)
`uvm_info("SB", $sformatf("Size is %0d", queue_time.size()), UVM_MEDIUM)
    if(txn.addr == 5'h04) begin
      div_value = txn.data;
      `uvm_info("SB", $sformatf("Received data: %p", txn.data), UVM_MEDIUM)
end
	if(queue_time.size()==5) begin
`uvm_info("SB", $sformatf("Difference but not inside is %0t", queue_time[0] ), UVM_MEDIUM)
	//diff = queue_time[2] - queue_time[1];
	//if(diff > 0) 
`uvm_info("SB", $sformatf("Difference is %0d", diff), UVM_MEDIUM)
diff = queue_time[3] - queue_time[2];
`uvm_info("SB", $sformatf("Difference in 3-2 is %0d", diff), UVM_MEDIUM)
diff = queue_time[4] - queue_time[3];
`uvm_info("SB", $sformatf("Difference in 4-3 is %0d", diff), UVM_MEDIUM)

if(diff!=300)
`uvm_error(get_type_name(),"Freq not matching");
end

   
  end
endtask


  task monitor_divider_config();
    i2c_transaction txn;
    forever begin
      wait (queue.size() > 0 && queue_time.size() > 0);
      txn = new();
      txn.jainil = queue.pop_front();
     // txn.jainil_time = queue_time.pop_front();
     // txn.data = queue_freq.pop_front();
      `uvm_info("SB", $sformatf("Pop Done: %d and %t", txn.jainil, txn.jainil_time), UVM_MEDIUM)

      if (rec_addr == 5'h04) begin
        //div_value = txn.data;
        if (divider_map.exists(txn.data[4:0])) begin
  expected_period = divider_map[txn.data[4:0]];
end else begin
  `uvm_error("DIV_MAP", $sformatf("No mapping found for PADDR value %0h", txn.data[4:0]))
end

      end
	


      if (queue_time.size() >= 5) begin
        diff = queue_time[3] - queue_time[2];
        `uvm_info("SB", $sformatf("Difference in 3-2 is %0t", diff), UVM_MEDIUM)
        diff = queue_time[4] - queue_time[3];
        `uvm_info("SB", $sformatf("Difference in 4-3 is %0t", diff), UVM_MEDIUM)

        if (diff != expected_period)
          `uvm_error(get_type_name(), "Freq not matching");
	
      end
    end
  endtask
*/

task monitor_divider_config();
  i2c_transaction txn;
  forever begin
    wait (queue.size() > 0 && queue_time.size() > 0 && queue_freq.size() > 0);
    txn = new();
    txn.jainil       = queue.pop_front();
   // txn.jainil_time  = queue_time.pop_front();
    //txn.data         = queue_freq.pop_front();

    `uvm_info("SB", $sformatf("Pop Done: %d, Time: %t, Data: %h", txn.jainil, txn.jainil_time, txn.data), UVM_MEDIUM)

    if (divider_map.exists(txn.data[4:0])) begin
      expected_period = divider_map[div_value[4:0]];
      `uvm_info("SB", $sformatf("Expected period set to %0t (from data %h)", expected_period, txn.data[4:0]), UVM_MEDIUM)
    end else begin
      `uvm_error("DIV_MAP", $sformatf("No mapping found for value %0h", txn.data[4:0]))
    end

    if (queue_time.size() >= 5) begin
     // diff = queue_time[3] - queue_time[2];
      //`uvm_info("SB", $sformatf("Difference in 3-2: %0t", diff), UVM_MEDIUM)
      diff = queue_time[4] - queue_time[3];
      `uvm_info("SB", $sformatf("Difference between 2 negative edges is: %0t", diff), UVM_MEDIUM)

      if (diff/10 != expected_period)
        `uvm_error(get_type_name(), "Freq not matching");
    end
  end
endtask


endclass

