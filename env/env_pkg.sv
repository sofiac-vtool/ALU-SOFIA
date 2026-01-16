`timescale 1ns/1ps
//------------------------------------------------------------------------------------------------------------
`ifndef ENV_PKG_SV
`define ENV_PKG_SV

`include "uvm_macros.svh" 

package env_pkg;
    import uvm_pkg::*;
    import alu_pkg::*;

  //  `include "alu_agent.sv"

	 //`include "alu_coverage.sv"
	 `include "adapter.sv"
	 `include "reg_block.sv"
	 `include "fifo_virtual_sequencer.sv"
     `include "alu_seq_lib.sv"
	 `include "alu_env_config.sv"
	 `include "alu_scoreboard.sv"
	 
	 `include "alu_env.sv"

endpackage 
`endif
