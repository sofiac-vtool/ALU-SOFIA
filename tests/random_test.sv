class random_test extends base_test;
  `uvm_component_utils(random_test)

  int reps ;
  reg_block   m_ral_model; //register model
  random_sequence op_seq;// Declare sequence handle
   

  // Constructor declaration
  extern function new(string name="random_test", uvm_component parent=null);
  //BUILD PHASE
   extern virtual function void build_phase(uvm_phase phase);
  // run_phase declaration
  extern virtual task run_phase(uvm_phase phase);

endclass :random_test


// ===================== Implementation =====================

function random_test::new(string name, uvm_component parent);
  super.new(name, parent);
  reps = 10;
endfunction : new
//------------------------------------------------------------------------------------------------------------
function void random_test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(int)::set(null,  "*", "reps", reps);
  endfunction


//-------------------------------------------------------------------------------------------------------------
// run_phase implementation
task random_test::run_phase(uvm_phase phase);
   super.run_phase(phase);
  `uvm_info(get_type_name(), "run_phase START", UVM_LOW)
  phase.raise_objection(this);

    // Main sequence
    begin
      `uvm_info(get_type_name(), "Creating sequence...", UVM_LOW)
      op_seq = random_sequence::type_id::create("op_seq");
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
