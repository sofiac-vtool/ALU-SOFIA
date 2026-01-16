class env_config extends uvm_object;
   `uvm_object_utils(env_config)
   
   fifo_config cfg;
   virtual interfc vintf;
   reg_block   m_ral_model;
   //uvm_active_passive_enum  is_active = UVM_ACTIVE;

   function new(string name = "");
      super.new(name); 
      cfg = fifo_config::type_id::create("fifo_config");
   endfunction

endclass
