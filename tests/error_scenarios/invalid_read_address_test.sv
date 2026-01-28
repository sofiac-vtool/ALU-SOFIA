class error_invalid_read_address_test extends base_test;
  `uvm_component_utils(error_invalid_read_address_test)

  
  reg_block   m_ral_model; //register model
  error_invalid_read_address_sequence op_seq;// Declare sequence handle
   

  // Constructor declaration
  extern function new(string name="error_invalid_read_address_test", uvm_component parent=null);

  // run_phase declaration
  extern virtual task run_phase(uvm_phase phase);

endclass : error_invalid_read_address_test


// ===================== Implementation =====================

function error_invalid_read_address_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


//-------------------------------------------------------------------------------------------------------------
// run_phase implementation
task error_invalid_read_address_test::run_phase(uvm_phase phase);
   super.run_phase(phase);
  `uvm_info(get_type_name(), "run_phase START", UVM_LOW)
  phase.raise_objection(this);

    // Main sequence
    begin
      `uvm_info(get_type_name(), "Creating sequence...", UVM_LOW)
      op_seq = error_invalid_read_address_sequence::type_id::create("op_seq");
      if (op_seq == null)
        `uvm_fatal("TEST", "Failed to create seq")
      else
        `uvm_info(get_type_name(), "Sequence created OK", UVM_LOW)


      `uvm_info(get_type_name(), "Starting sequence...", UVM_LOW)
///////////NA TSEKARV ONOMATA
       op_seq.start(env.alu_agnt.sequencer);
      `uvm_info(get_type_name(), " sequence FINISHED", UVM_LOW)
    end
  phase.drop_objection(this);
  `uvm_info(get_type_name(), "run_phase END", UVM_LOW)
endtask : run_phase
