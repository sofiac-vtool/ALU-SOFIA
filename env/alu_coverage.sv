
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
////////////////// Coverage 
// TODO: * * * Call the imp_decl macro * * *
//-------------------------------------------------------------------------------------------------------------
// b2gfifo_coverage.sv
//-------------------------------------------------------------------------------------------------------------
class alu_coverage extends uvm_subscriber#(apb_transaction);

  `uvm_component_utils(alu_coverage)
	virtual interfc vif;
  // Analysis port
  uvm_analysis_imp#(apb_transaction, alu_coverage) alu_analysis_export;

//----------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------
// Constructor
	function new(string name, uvm_component parent);
	 super.new(name, parent);

	endfunction

// Build phase
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);

	 if(!uvm_config_db#(virtual interfc)::get(this, "", "vif", vif)) begin
		`uvm_fatal(get_type_name(),"NOVIF: call to uvm_config_db get method failed\n");end

	 alu_analysis_export = new("alu_analysis_export", this);
	endfunction

//Run Phase
task run_phase(uvm_phase phase);

endtask

// Write / sample method (override)
virtual function void write(apb_transaction pkt);
endfunction
endclass


