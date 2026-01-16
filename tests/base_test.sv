//`include "fifo_config.sv" 
//`include "env_config.sv" 
`include "uvm_macros.svh"
import uvm_pkg::*; 
class base_test extends uvm_test;

//************ ADD TO FACTORY **************
`uvm_component_utils(base_test)


//************ DECLARE COMPONENTS **************
alu_env         env;
env_config   env_cfg;
//alu_agent  agent;
//fifo_config  cfg;


//------------------------------------------------------------------------------------------------------------
function new (string name="base_test",uvm_component parent = null);    
	super.new(name,parent);
   // conf = new("conf");
endfunction

//------------------------------------------------------------------------------------------------------------
function void build_phase(uvm_phase phase);
	super.build_phase(phase); 

   `uvm_info(get_type_name(), "Building and configuring the environment ...", UVM_LOW)
   env = alu_env::type_id::create("env", this);
  // cfg = fifo_config::type_id::create("cfg", this);
   env_cfg = env_config::type_id::create("env_cfg");

  // cfg.cfg_wr_rd  = write;
 //  cfg.is_active = UVM_ACTIVE;   

//************ Set configuration to config_db ************

   //make each cfg available to its respective agent
//   uvm_config_db#(fifo_config)::set(this,"*.agent","fifo_config",cfg);
	uvm_config_db#(env_config)::set(this, "*", "env_cfg", env_cfg);



//************ Apply default configuration ************
//	env_cfg.set_default_config();

 
	

endfunction : build_phase

//-------------------------------------------------------------------------------------------------------------
task run_phase(uvm_phase phase);
  super.run_phase(phase);
      env.fifo_vr_sqr.vintf.rst_n = 1;
      `uvm_info("testbase", $sformatf("run_phase testbase"), UVM_LOW)
   endtask


//-------------------------------------------------------------------------------------------------------------
//************ Print Topology for Debug *************
virtual function void end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
endfunction

endclass:base_test

