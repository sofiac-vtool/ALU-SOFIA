`ifndef APB_VIRTUAL_SEQ_LIB_SV
`define APB_VIRTUAL_SEQ_LIB_SV
//=========================================================================
//-----------------------------SANITY-------------------------------------
//=========================================================================
//=========================================================================
//--------------------------BASE SEQUENCE----------------------------------
//=========================================================================
// Base test, is empty, doesnt run any sequence, its just the base for all the other tests.

class base_seq extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(base_seq)
   `uvm_declare_p_sequencer(fifo_virtual_sequencer)

   apb_transaction  data_obj;

   function new (string name = "base_seq");
      super.new(name);
   endfunction

   virtual task body();
   endtask

endclass : base_seq

//=========================================================================
//--------------------------SANITY-OPERATION SEQUENCE----------------------
//=========================================================================
// Write data to registers 1 & 2.
//Perform a valid operation.
//Read the result register.

class sanity_operation_sequence extends base_seq;

//Fctory Registration
   `uvm_object_utils(sanity_operation_sequence)

//Declare
 virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="sanity_operation_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   
      if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'h1234;
      bit[15:0] reg2_val = 16'hABCD;
      bit[15:0] control_reg_val;
      bit[24:0] result;

      `uvm_info(get_type_name(), "Starting simple RAL sequence", UVM_MEDIUM)

      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (10) @(posedge  vintf.clk);
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b10;    // valid operation
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
      repeat(40)begin
	    @(posedge vintf.clk);
	   end
	   
      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
   endtask
endclass


//=========================================================================
//--------------------------NO-START-OPERATION SEQUENCE----------------------
//=========================================================================
// Write data to registers 1 & 2.
//Perform an operation with start = 0.
//Read the result register. 

class sanity_no_start_operation_sequence extends base_seq;

//Fctory Registration
   `uvm_object_utils(sanity_no_start_operation_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="sanity_no_start_operation_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'h1234;
      bit[15:0] reg2_val = 16'hABCD;
      bit[15:0] control_reg_val;
      bit[24:0] result;
   
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (10) @(posedge  vintf.clk);
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b01;    // valid operation
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (33) @(posedge  vintf.clk);

      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
   endtask
endclass

//=========================================================================
//--------------------------MONITOR-REGISTER SEQUENCE----------------------
//=========================================================================
// Read the monitor register. 
//Write data to registers 1 & 2. 
//Perform a valid operation.
//Read the monitor register. 

class sanity_monitor_register_sequence extends base_seq;

//Fctory Registration
   `uvm_object_utils(sanity_monitor_register_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="sanity_monitor_register_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'h1234;
      bit[15:0] reg2_val = 16'hABCD;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

      `uvm_info(get_type_name(), "Starting simple RAL sequence", UVM_MEDIUM)
      //READ MONITOR REGISTER 
      m_ral_model.monitor.read(status, monitor);

      `uvm_info("SEQ", $sformatf("MONITOR REG STATUS = %h", monitor), UVM_MEDIUM)

      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // valid operation
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);

      //READ RESULT REGISTER
      m_ral_model.monitor.read(status, monitor);

     `uvm_info("SEQ", $sformatf("MONITOR REG STATUS = %h", monitor), UVM_MEDIUM)
   endtask
endclass

//=========================================================================
//-----------------------------FUNCTIONAL-------------------------------------
//=========================================================================
//=========================================================================
//----------------------ADD WAITSTATE SEQUENCE------------------------------
//=========================================================================
// Write data to registers 1 & 2.
//Perform an addition.Read the result register. 
//Count the wait states in the waveform

class functional_add_waitstate_sequence extends base_seq;

//Fctory Registration
   `uvm_object_utils(functional_add_waitstate_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="functional_add_waitstate_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'b0001000111000101;
      bit[15:0] reg2_val = 16'b1000111111000110;
      bit[15:0] control_reg_val;
      bit[24:0] result;

      `uvm_info(get_type_name(), "Starting simple RAL sequence", UVM_MEDIUM)

      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // addition
      control_reg_val[15:8] = 8'b11000100;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);

      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
   endtask
endclass


//=========================================================================
//--------------------------NO-START-EXEC SEQUENCE----------------------
//=========================================================================
//Write data to registers 1 & 2.
//Perform an addition without start.Perform a multiplication without start.
//Read the result register. Write data to registers 1 & 2.
//Perform an operation with start = 0.
//Read the result register. 

class functional_no_start_exec_sequence extends base_seq;

//Fctory Registration
   `uvm_object_utils(functional_no_start_exec_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="functional_no_start_exec_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'h1234;
      bit[15:0] reg2_val = 16'hABCD;
      bit[15:0] control_reg_val;
      bit[24:0] result;
   
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //PERFORM AN ADDITION/ Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b01;    // ADD
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);
      //PERFORM A MULTIPLICATION/ Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b10;    // MUL
      control_reg_val[15:8] = 8'b11111000;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);

      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
   endtask
endclass

//=========================================================================
//--------------------------SEQUENCE-ORDER SEQUENCE----------------------
//=========================================================================
// Write data to registers 1 & 2. 
//Send multiple operations of different types (e.g., 2 additions, 2 multiplications).
//Read the result register as many times as the number of operations sent.

class functional_sequence_order_sequence extends base_seq;

//Fctory Registration
   `uvm_object_utils(functional_sequence_order_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="functional_sequence_order_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'h0; //16'h4222B;
      bit[15:0] reg2_val = 16'h01;//16'hCCA32;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

      `uvm_info(get_type_name(), "Starting simple RAL sequence", UVM_MEDIUM)
      
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (5) @(posedge  vintf.clk);
      //1.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // ADD
      control_reg_val[15:8] = 8'h1A;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

       repeat (33) @(posedge  vintf.clk);
      //2.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b10;    // MUL
      control_reg_val[15:8] = 8'h1B;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (33) @(posedge  vintf.clk);

       reg1_val = 16'h1;//16'h422B;
       reg2_val = 16'h2;//16'hCCA2;
   
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)
      
 		repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //3.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b10;    // MUL
      control_reg_val[15:8] = 8'h1C;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

       repeat (35) @(posedge  vintf.clk);
      //4.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // ADD
      control_reg_val[15:8] = 8'h1D;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);

        //READ MONITOR REGISTER
      m_ral_model.monitor.read(status, monitor);

      `uvm_info("SEQ", $sformatf("RESULT = %h", monitor), UVM_MEDIUM)

        //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);

      //1.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
 		repeat (10) @(posedge  vintf.clk);
 		
      //2.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
 		repeat (35) @(posedge  vintf.clk);
      //3.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
 		repeat (10) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
      m_ral_model.monitor.read(status, monitor);

      `uvm_info("SEQ", $sformatf("RESULT = %h", monitor), UVM_MEDIUM)

 		repeat (33) @(posedge  vintf.clk);
      //4.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)

   endtask
endclass

//=========================================================================
//-----------------------------EDGE CASE ----------------------------------
//=========================================================================
//=========================================================================
//----------------------EDGE CASE SEQUENCE SEQUENCE------------------------
//=========================================================================
// Read the monitor register. 
//Write data to registers 1 & 2.  
//Send one valid operation.  
//Read the monitor register. 
//Send traffic until the FIFO-OUT is full.  
//Read the monitor register again.  
//Read the result register. 
//Read the monitor register. 
//Continue reading the result register until all results have been read.  
//Read the monitor register. 
class my_rand extends base_seq;

  `uvm_object_utils(my_rand)

  rand bit [1:0] seq_op;      // 01=add, 10=mul
  rand bit [7:0] seq_id;     // id 
  rand bit [15:0] reg1;
  rand bit [15:0] reg2;

  constraint seq_op_only_valid {
  seq_op inside {2'b01, 2'b10};
}

function new(string name="my_rand");
    super.new(name);
  endfunction

endclass

class edge_case_sequence extends base_seq;
 
//Fctory Registration
   `uvm_object_utils(edge_case_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="edge_case_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
   
   
      bit[15:0] reg1_val = 16'b0001000111000101;
      bit[15:0] reg2_val = 16'b1000111111000110;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

      int i = 5;
      int j = 0;
      my_rand trans;

      `uvm_info(get_type_name(), "Starting simple RAL sequence", UVM_MEDIUM)

      //READ MONITOR REGISTER 
      m_ral_model.monitor.read(status, monitor);
        `uvm_info("SEQ", $sformatf("RESULT = %h", monitor), UVM_MEDIUM)

 repeat(i) begin

      trans = my_rand::type_id::create("trans");

      if (!trans.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed for b2gfifo_item!")
      end
      
      reg1_val = trans.reg1;
      reg2_val = trans.reg2;
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = trans.seq_op;    // addition
      control_reg_val[15:8] = trans.seq_id;   // ID example
		repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

     repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)
    
     repeat (5) @(posedge  vintf.clk);
      //PERFORM A VALID OPERATION / Write to control register
      m_ral_model.ctl.write(status, control_reg_val);
        j++ ;
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h, its the %h operation", control_reg_val, j), UVM_LOW)
  
        
      //Wait to make sure the operation is done 
       repeat (40) @(posedge  vintf.clk);

      //READ MONITOR REGISTER 
      m_ral_model.monitor.read(status, monitor);
      `uvm_info("SEQ", $sformatf("MONITOR STATUS AFTER WRITE = %h", monitor), UVM_MEDIUM)

      end 
    
        repeat(i) begin
          repeat (10) @(posedge  vintf.clk);
        //READ RESULT REGISTER
            m_ral_model.result.read(status, result);
            `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
         repeat (40) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS AFTER READ = %h", monitor), UVM_MEDIUM) 
        end
   endtask
endclass

//=========================================================================
//-----------------------------ERROR SCENARIOS ----------------------------
//=========================================================================
//=========================================================================
//--------------------INVALID WRITE ADDRESS TEST SEQUENCE------------------
//=========================================================================
//Send valid data to all addresses that are not write-only (WO).  
//Read the monitor register. 


class error_invalid_write_address_sequence extends uvm_sequence#(apb_transaction);
   `uvm_object_utils(error_invalid_write_address_sequence)
   `uvm_declare_p_sequencer(fifo_sequencer)
//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

   rand bit [`APB_BUS_SIZE-1 : 0] mdata;
   rand bit [`ADDR_W :0] maddr;
   rand wr_rd_type operation;
   bit[15:0] reg1_val = 16'b0001000111000101;
   bit[15:0] reg2_val = 16'b1000111111000110; 
   bit[15:0] control_reg_val;
   bit[24:0] monitor;

   constraint addr_c {maddr inside {3'b011, 3'b100, 3'b101, 3'b110, 3'b111};}
  // constraint addr_c {maddr inside {3'b011, 3'b101};}
   constraint mdata_c {
  	mdata[0] == 0;                 
  	mdata[2:1] inside {2'b01, 2'b10};
   }
   
   function new (string name ="");
      super.new(name);
   endfunction

 virtual task pre_body();
 		if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask
   virtual task body();
  `uvm_info(get_name(), "Inside seq body", UVM_DEBUG)
  repeat (20) begin
  // Randomize sequence-level variables
  if (!this.randomize())
    `uvm_fatal(get_name(), "Sequence randomization failed")

  // RAL writes
  m_ral_model.data0.write(status, reg1_val, .parent(this));
  `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

  m_ral_model.data1.write(status, reg2_val, .parent(this));
  `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

    req = apb_transaction::type_id::create("req");
    ///Deactivate address constraint  
		req.c_addr.constraint_mode(0);
    if (!req.randomize() with {
      addr == maddr;
      data == mdata;
      op   == operation;
      write == 1;
    })
      `uvm_fatal(get_name(), "APB item randomization failed")
    start_item(req);
    finish_item(req);
    get_response(rsp);
    `uvm_info(get_name(),
              $psprintf("Transaction sent:\n%s", req.sprint()),
              UVM_MEDIUM)
  end
  
   repeat (33) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
  
endtask
endclass : error_invalid_write_address_sequence
//=========================================================================
//--------------------INVALID READ ADDRESS TEST SEQUENCE------------------
//=========================================================================
//Send traffic. 
//Attempt to read from all invalid addresses . 
//Read the result register. 

class error_invalid_read_address_sequence extends uvm_sequence#(apb_transaction);
   `uvm_object_utils(error_invalid_read_address_sequence)
   `uvm_declare_p_sequencer(fifo_sequencer)
//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

   rand bit [`APB_BUS_SIZE-1 : 0] mdata;
   rand bit [`ADDR_W :0] maddr;
   rand wr_rd_type operation;
   bit[15:0] reg1_val = 16'b0001000111000101;
   bit[15:0] reg2_val = 16'b1000111111000110; 
   bit[15:0] control_reg_val;


   bit[24:0] monitor;
   bit[24:0] result;

 //  constraint addr_c {maddr inside {3'b011, 3'b100, 3'b101, 3'b110, 3'b111};}
   constraint addr_c {maddr inside {3'b000, 3'b001, 3'b010,3'b101, 3'b110, 3'b111};}
   
   
   function new (string name ="");
      super.new(name);
   endfunction

 virtual task pre_body();
 		if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask
   virtual task body();
   
   control_reg_val[0]   = 1'b1;     // start
   control_reg_val[2:1] = 2'b01;    // addition
   control_reg_val[15:8] = 11000110;   // ID example
  `uvm_info(get_name(), "Inside seq body", UVM_DEBUG)
 
  // RAL writes
  m_ral_model.data0.write(status, reg1_val, .parent(this));
  `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)
 repeat (5) @(posedge  vintf.clk);
  m_ral_model.data1.write(status, reg2_val, .parent(this));
  `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)
   repeat (5) @(posedge  vintf.clk); 
  m_ral_model.ctl.write(status, control_reg_val); 
   `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
   
  repeat (35) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
   
 repeat (3) begin
  // Randomize sequence-level variables
  if (!this.randomize())
    `uvm_fatal(get_name(), "Sequence randomization failed")


    req = apb_transaction::type_id::create("req");
      ///Deactivate address constraint  
		req.c_addr.constraint_mode(0);
    if (!req.randomize() with {
      addr == maddr;
      write == 0;
    })
      `uvm_fatal(get_name(), "APB item randomization failed")
    start_item(req);
    finish_item(req);
    get_response(rsp);
    `uvm_info(get_name(),
              $psprintf("Transaction sent:\n%s", req.sprint()),
              UVM_MEDIUM)
  end
   #100ns
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
  
endtask
endclass : error_invalid_read_address_sequence
//=========================================================================
//--------------------INVALID CTRL DATA TEST SEQUENCE------------------
//=========================================================================
//Write data to registers 1 & 2. 
//Write to register 0 using ctrl_data values that do not correspond to any valid operation.

class error_invalid_ctrl_data_sequence extends base_seq;
//Fctory Registration
   `uvm_object_utils(error_invalid_ctrl_data_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="error_invalid_ctrl_data_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'h1234;
      bit[15:0] reg2_val = 16'hABCD;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;
   
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (5) @(posedge  vintf.clk);
      //PERFORM AN ADDITION/ Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b11;    // INVALID
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);
      //PERFORM A MULTIPLICATION/ Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b00;    // INVALID
      control_reg_val[15:8] = 8'b11111000;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
        repeat (35) @(posedge  vintf.clk);

      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
        repeat (35) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
  
   endtask
endclass

 //=========================================================================
//--------------------UNDERFLOW TEST SEQUENCE------------------
//=========================================================================
//Read the monitor register. 
//Read the result register. 
//Send traffic. 
//Read the result register till the system gets empty. 
//Attempt to read the result register again. 

class error_underflow_sequence extends base_seq;
//Factory Registration
   `uvm_object_utils(error_underflow_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="error_underflow_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
   
      my_rand trans2;
      bit[15:0] reg1_val;
      bit[15:0] reg2_val;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

     //READ MONITOR REGISTER
       m_ral_model.monitor.read(status, monitor);
      `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
        
    repeat (20) @(posedge  vintf.clk);   
     //READ RESULT REGISTER
       m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
      repeat(3)begin
      
      trans2 = my_rand::type_id::create("trans2");

      if (!trans2.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed for b2gfifo_item!")
      end
      
      reg1_val = trans2.reg1;
      reg2_val = trans2.reg2;
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = trans2.seq_op;    // addition
      control_reg_val[15:8] = trans2.seq_id;   // ID example
      
     repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 1
       m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
    repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //PERFORM AN OPERATION
      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
     end
     
      //Wait to make sure the operation is done 
    repeat (40) @(posedge  vintf.clk);
    
	repeat(4)begin
      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
    repeat (20) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
  	end
   endtask
endclass

//=========================================================================
//--------------------OVERFLOW TEST SEQUENCE------------------
//=========================================================================
//Write on registers 1&2. 
//Perform an operation. 
//Repeat till system gets full. 
//Attempt a valid operation.

class error_overflow_sequence extends base_seq;
//Factory Registration
   `uvm_object_utils(error_overflow_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="error_overflow_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
  		if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
   
      my_rand trans2;
      bit[15:0] reg1_val;
      bit[15:0] reg2_val;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

   
      
      repeat(9)begin
      
      trans2 = my_rand::type_id::create("trans2");

      if (!trans2.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed for b2gfifo_item!")
      end
      
      reg1_val = trans2.reg1;
      reg2_val = trans2.reg2;
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = trans2.seq_op;    // addition
      control_reg_val[15:8] = trans2.seq_id;   // ID example
      
       //Wait to make sure the operation is done 
    repeat (33) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
    repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 1
       m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
   repeat (5) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
   repeat (5) @(posedge  vintf.clk);
      //PERFORM AN OPERATION
      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
     
     
  	end
   endtask
endclass
//===========================================================================
//--------------------------RANDOM TEST SEQUENCE---------------------------
//=========================================================================
//Send random traffic(reads and writes). 

class random_sequence extends uvm_sequence#(apb_transaction);
   `uvm_object_utils(random_sequence)
   `uvm_declare_p_sequencer(fifo_sequencer)
//Declare
// VIRTUAL INTERFACE
   virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status; 
   int reps;
   rand bit [`APB_BUS_SIZE-1 : 0] mdata;
   rand bit [`ADDR_W :0] maddr;
   rand bit operation;
  
  constraint c_addr {maddr inside{0,1,2,3,4};}
   
   function new (string name ="");
      super.new(name);
   endfunction


	
 virtual task pre_body();
	 if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")

      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");
      if (!uvm_config_db#(int)::get( null, "", "reps", reps))
         `uvm_fatal("CFG", "Cannot get repsfrom config DB")
   endtask
   
virtual task body();
    repeat(reps)begin
	 repeat (33) @(posedge  vintf.clk);
	  // Randomize sequence-level variables
	  if (!this.randomize())
	    `uvm_fatal(get_name(), "Sequence randomization failed")

	    req = apb_transaction::type_id::create("req");

	    if (!req.randomize() with {
	      addr == maddr;
	      write == operation;
	      data == mdata;
	    })begin
	      `uvm_fatal(get_name(), "APB item randomization failed")
	      end
	      
	    start_item(req);
	    finish_item(req);
	    get_response(rsp);
	    `uvm_info(get_name(),
		      $psprintf("Transaction sent:\n%s", req.sprint()),
		      UVM_MEDIUM)
	
	   
	  end
  
  
endtask
endclass : random_sequence


//===========================================================================
//--------------------------RESET TEST SEQUENCE---------------------------
//=========================================================================
//Send traffic.
//Perform a reset.
//Read the monitor register.
//Read the result register.
//Send traffic again.

class reset_sequence extends base_seq;
   `uvm_object_utils(reset_sequence)
  
//Declare
// VIRTUAL INTERFACE
   virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status; 

//Declare Sequence  

 error_overflow_sequence op_seq;
   
   function new (string name ="");
      super.new(name);
   endfunction


	
 virtual task pre_body();
	 if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")

      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask
   
virtual task body();
       
      fork 
       begin
     op_seq = error_overflow_sequence::type_id::create("op_seq");
      if (op_seq == null)
        `uvm_fatal("TEST", "Failed to create seq")
      else
        `uvm_info(get_type_name(), "Sequence created OK", UVM_LOW)
     
       op_seq.start(p_sequencer);
      end
      begin 
       repeat (200) @(posedge  vintf.clk);
      `uvm_info(get_name(), " Random reset triggered!", UVM_NONE)
         vintf.rst_n = 0;
         #40ns;
         vintf.rst_n = 1;
         #10ns;
	 m_ral_model.reset();
        end
      join
      disable fork;
   endtask
	
endclass : reset_sequence


//===========================================================================
//--------------------------CORNER VALUES TEST SEQUENCE---------------------
//=========================================================================
//Set data0 and data1 reg with the min and max values.
//Perform addition(checks add to zero)
//Set one operand to 1 
//Perform mul (checks identity mul)


class min_max_sequence extends base_seq;
//Factory Registration
   `uvm_object_utils(min_max_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="min_max_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
   
      my_rand trans2;
      bit[15:0] reg1_val;
      bit[15:0] reg2_val;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

    
        
      reg1_val = 16'h0;
      reg2_val =  16'hFFFF;
      control_reg_val[0]   = 1'b1;    // start
      control_reg_val[2:1] = 2'b01;    // addition
      control_reg_val[15:8] = 8'b10001111;  // ID example
      
     repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 1
       m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
    repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //PERFORM AN OPERATION
      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
  
      //Wait to make sure the operation is done 
    repeat (40) @(posedge  vintf.clk);
   
      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
    repeat (20) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
   ///////////////////////////         
     reg2_val = 16'h0;
      reg1_val =  16'hFFFF;
      control_reg_val[0]   = 1'b1;    // start
      control_reg_val[2:1] = 2'b01;    // addition
      control_reg_val[15:8] = 8'b10101111;  // ID example
      
     repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 1
       m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
    repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //PERFORM AN OPERATION
      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
  
      //Wait to make sure the operation is done 
    repeat (40) @(posedge  vintf.clk);
   
      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
    repeat (20) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM)       
     ///////////////////////////         
     reg2_val = 16'h1;
      reg1_val =  16'hFFFF;
      control_reg_val[0]   = 1'b1;    // start
      control_reg_val[2:1] = 2'b10;    // addition
      control_reg_val[15:8] = 8'b10001011;  // ID example
      
     repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 1
       m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
    repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //PERFORM AN OPERATION
      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
  
      //Wait to make sure the operation is done 
    repeat (40) @(posedge  vintf.clk);
   
      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
    repeat (20) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM)       
          
  
   endtask
endclass

//===========================================================================
//--------------------------HALF DIVISION CHECK TEST SEQUENCE---------------------
//=========================================================================
//Set data0 and data1 reg with values greater than FF.
//Perform mul

class half_div_sequence extends base_seq;
//Factory Registration
   `uvm_object_utils(half_div_sequence)

//Declare
	virtual interfc vintf;
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="half_div_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
   	if(!uvm_config_db#(virtual interfc)::get(null,"","interfc", vintf))
			  `uvm_fatal(get_type_name(), "Unable to get virtual interface")
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
   
      my_rand trans2;
      bit[15:0] reg1_val;
      bit[15:0] reg2_val;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

    
        
      reg1_val = 16'hFF4;
      reg2_val =  16'hFFB4;
      control_reg_val[0]   = 1'b1;    // start
      control_reg_val[2:1] = 2'b10;    // addition
      control_reg_val[15:8] = 8'b10001111;  // ID example
      
     repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 1
       m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //Wait to make sure the operation is done 
    repeat (10) @(posedge  vintf.clk);
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       repeat (10) @(posedge  vintf.clk);
      //PERFORM AN OPERATION
      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)
  
      //Wait to make sure the operation is done 
    repeat (40) @(posedge  vintf.clk);
   
      //READ RESULT REGISTER
      m_ral_model.result.read(status, result);
      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      
    repeat (20) @(posedge  vintf.clk);
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
            
    endtask
endclass
           
//=========================================================================
`endif
