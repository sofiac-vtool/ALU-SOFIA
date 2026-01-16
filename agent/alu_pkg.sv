`timescale 1ns/1ps
//------------------------------
`ifndef ALU_PKG_SV
`define ALU_PKG_SV

`include "uvm_macros.svh"

package alu_pkg;

   import uvm_pkg::*;
   //include "top_tb.sv"
   `include "defines.sv"

   `include "apb_transaction.sv" 
   `include "fifo_config.sv"
   `include "alu_driver.sv"
   `include "alu_monitor.sv"
   `include "fifo_sequencer.sv"
   `include "alu_agent.sv"
   //`include "interface.sv"
   //`include "fifo_sequence.sv"



endpackage
`endif // ALU_PKG_SV
