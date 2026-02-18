//------------------------------------------------------------------------------------------------------------
class alu_env extends uvm_env;

 // TODO: * * * Declare the agent and register env to factory * * *
 `uvm_component_utils(alu_env)

   alu_agent alu_agnt; //Agent Instance
   alu_scoreboard alu_sboard; //Scoreboard Instance
   fifo_virtual_sequencer fifo_vr_sqr; //Virtual Sequencer Instance
   env_config env_cfg;//Configuration Instance
   //virtual interfc vif; //Interface Instance
   
   fifo_config fifo_cfg;      
   
   adapter m_adapter; //Adapter Instance
   reg_block   m_ral_model; //Register Block Instance
   uvm_reg_predictor#(apb_transaction)  m_apb_predictor;   //map apb tx to register in model
   alu_coverage alu_cov; //Coverage Instance

    extern function new (string name="alu_env", uvm_component parent=null);
    extern virtual function void build_phase (uvm_phase phase);
    extern virtual function void connect_phase (uvm_phase phase);

endclass : alu_env

//------------------------------------------------------------------------------------------------------------
function alu_env::new (string name="alu_env", uvm_component parent =null);
    super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------------------------------------
function void alu_env:: build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Get configuration from Config DB
   if(!uvm_config_db#(env_config)::get(this, "", "env_cfg", env_cfg)) begin
     `uvm_fatal(get_type_name(), "Failed to get configuration object from config DB!")
   end

   // --- Create fifo_config for the agent
   fifo_cfg = fifo_config::type_id::create("fifo_cfg");
   fifo_cfg.vintf     = env_cfg.vintf;   // hook the interface
   fifo_cfg.is_active = UVM_ACTIVE;      // or env_cfg.is_active

// --- Set the config for the agent (and children if needed)
	uvm_config_db#(fifo_config)::set(this, "alu_agnt*", "fifo_config", fifo_cfg);
	// Create and build register model
	m_ral_model = reg_block::type_id::create("m_ral_model", this);
	alu_agnt = alu_agent::type_id::create("alu_agnt", this);
	alu_cov = new();
	alu_sboard = alu_scoreboard::type_id::create("alu_sboard", this);
	fifo_vr_sqr = fifo_virtual_sequencer::type_id::create("m_seqr",this);
	m_apb_predictor = uvm_reg_predictor#(apb_transaction)::type_id::create("m_apb_predictor",  this);
	m_ral_model.build();
	m_ral_model.lock_model ();   //a register model has to be locked via invocation of its lock()      function in order to prevent any other testbench component or part from modifying the structure or adding registers to it.  
	uvm_config_db #(reg_block):: set(null, "*", "m_ral_model", m_ral_model);
	m_adapter = adapter :: type_id :: create("m_adapter", this);

  
	 
endfunction : build_phase 

//------------------------------------------------------------------------------------------------------------ 
function void alu_env:: connect_phase (uvm_phase phase);
    super.connect_phase(phase);

/////Connect the monitors analysis port to the scoreboard & coverage
	alu_agnt.monitor.ap_monitor.connect(alu_sboard.alu_analysis_export);
   alu_agnt.monitor.reset_port.connect(alu_sboard.rst_imp);
  // alu_agnt.monitor.ap_monitor.connect(alu_cov.alu_analysis_export);
 //  alu_agnt.monitor.reset_port.connect(alu_cov.rst_imp);

    m_ral_model.reg_map.set_sequencer(.sequencer(alu_agnt.sequencer), .adapter(m_adapter)); 
    m_ral_model.reg_map.set_base_addr(0); 
   
   //connect analysis ports from agent to the scoreboard

   m_apb_predictor.map = m_ral_model.reg_map;

   //provide an adapter to hepl convert apb packet into register item

   m_apb_predictor.adapter = m_adapter;
   alu_sboard.m_ral_model = m_ral_model;

   alu_agnt.monitor.ap_monitor.connect(m_apb_predictor.bus_in);

   //alu_sboard.cvg_obj = cvg_obj;
   m_ral_model.reg_map.set_auto_predict(0);
  //
 
 //connect virtual seq with agent seq
  fifo_vr_sqr.apb_seqr = alu_agnt.sequencer ;
   if (fifo_vr_sqr.apb_seqr == null)
    `uvm_fatal("CONNECT", "fifo_vr_sqr.apb_seqr is NULL! Connection failed")
  else
    `uvm_info("CONNECT", "fifo_vr_sqr.apb_seqr connected OK", UVM_LOW)
endfunction : connect_phase
