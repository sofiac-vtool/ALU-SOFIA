`timescale 1ns/1ps

`ifndef ALU_TEST_PKG_SV
`define ALU_TEST_PKG_SV

package alu_test_pkg;
`include "uvm_macros.svh"
//	import uvm_pkg::*;
	import env_pkg::*;
//	import seq_pkg::*;

//	`include "alu_seq_lib.sv" 
   `include "base_test.sv"
   `include "sanity/operation_test.sv"
   `include "sanity/no_start_operation_test.sv"
   `include "sanity/monitor_register_test.sv"
   `include "functional/add_waitstate_test.sv"
   `include "functional/no_start_exec_test.sv"
   `include "functional/sequence_order_test.sv"
   `include "edge_case_test.sv"
   `include "error_scenarios/invalid_wirte_address_test.sv"
   `include "error_scenarios/invalid_read_address_test.sv"
   `include "error_scenarios/invalid_ctrl_data_test.sv"
   `include "error_scenarios/underflow_test.sv"
   `include "error_scenarios/overflow_test.sv"
   `include "random_test.sv"
   `include "stress_test.sv"
   `include "reset_test.sv"

endpackage
`endif
