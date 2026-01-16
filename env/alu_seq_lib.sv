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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="sanity_operation_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
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
       #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // valid operation
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #300ns

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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="sanity_no_start_operation_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
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
       #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b01;    // valid operation
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #200ns

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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="sanity_monitor_register_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
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
       #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // valid operation
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #200ns

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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="functional_add_waitstate_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
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
       #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // addition
      control_reg_val[15:8] = 8'b11000100;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #200ns

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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="functional_no_start_exec_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
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
       #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //PERFORM AN ADDITION/ Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b01;    // ADD
      control_reg_val[15:8] = 8'h10;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #200ns
      //PERFORM A MULTIPLICATION/ Write to control register
      control_reg_val[0]   = 1'b0;     // start
      control_reg_val[2:1] = 2'b10;    // MUL
      control_reg_val[15:8] = 8'b11111000;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #200ns

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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="functional_sequence_order_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
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
      // #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //1.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // ADD
      control_reg_val[15:8] = 8'h1A;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

        #50ns
      //2.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b10;    // MUL
      control_reg_val[15:8] = 8'h1B;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #100ns

       reg1_val = 16'h1;//16'h422B;
       reg2_val = 16'h2;//16'hCCA2;
   
      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //3.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b10;    // MUL
      control_reg_val[15:8] = 8'h1C;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      #50ns
      //4.PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // ADD
      control_reg_val[15:8] = 8'h1D;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #100ns

        //READ MONITOR REGISTER
      m_ral_model.monitor.read(status, monitor);

      `uvm_info("SEQ", $sformatf("RESULT = %h", monitor), UVM_MEDIUM)

        //Wait to make sure the operation is done 
       #100ns

              //Wait to make sure the operation is done 
     /*  #50ns
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b10;    // ADD
      control_reg_val[15:8] = 8'h1B;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)*/

      //Wait to make sure the operation is done 
       #500ns

      //1.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)

      //2.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)

      //3.READ RESULT REGISTER
      m_ral_model.result.read(status, result);

      `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)

         //READ MONITOR REGISTER
      m_ral_model.monitor.read(status, monitor);

      `uvm_info("SEQ", $sformatf("RESULT = %h", monitor), UVM_MEDIUM)


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
   reg_block m_ral_model;
   uvm_status_e status;

//Constructor
   function new(string name="edge_case_sequence");
      super.new(name);
   endfunction

   virtual task pre_body();
      if(!uvm_config_db #(reg_block)::get(null, "", "m_ral_model", m_ral_model))
         `uvm_fatal("RAL", "Cannot get RAL model from config DB");

   endtask

   virtual task body();
      bit[15:0] reg1_val = 16'b0001000111000101;
      bit[15:0] reg2_val = 16'b1000111111000110;
      bit[15:0] control_reg_val;
      bit[24:0] result;
      bit[24:0] monitor;

      int i = 9;
      int j = 0;
      my_rand trans;

      `uvm_info(get_type_name(), "Starting simple RAL sequence", UVM_MEDIUM)

      //READ MONITOR REGISTER 
      m_ral_model.monitor.read(status, monitor);
        `uvm_info("SEQ", $sformatf("RESULT = %h", monitor), UVM_MEDIUM)

    /*  //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA2 = %h", reg2_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns
      //PERFORM A VALID OPERATION / Write to control register
      control_reg_val[0]   = 1'b1;     // start
      control_reg_val[2:1] = 2'b01;    // addition
      control_reg_val[15:8] = 8'b11000100;   // ID example

      m_ral_model.ctl.write(status, control_reg_val);
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h", control_reg_val), UVM_LOW)

      //Wait to make sure the operation is done 
       #50ns

       //READ MONITOR REGISTER 
        m_ral_model.monitor.read(status, monitor);
        `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM)
*/
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

      //WRITE REGISTER 1
      m_ral_model.data0.write(status, reg1_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA0 = %h", reg1_val), UVM_LOW)

    #50ns
      //WRITE REGISTER 2
      m_ral_model.data1.write(status, reg2_val);
      `uvm_info("SEQ", $sformatf("Wrote DATA1 = %h", reg2_val), UVM_LOW)
    
    #100ns
      //PERFORM A VALID OPERATION / Write to control register
      m_ral_model.ctl.write(status, control_reg_val);
        j++ ;
      `uvm_info("SEQ", $sformatf("Wrote CONTROL = %h, its the %h operation", control_reg_val, j), UVM_LOW)
  
        
      //Wait to make sure the operation is done 
      #600ns

      //READ MONITOR REGISTER 
      m_ral_model.monitor.read(status, monitor);
      `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM)

//READ //RESULT REGISTER
        //    m_ral_model.result.read(status, result);
        //    `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
      end 
    
        repeat(i) begin
         #50ns
        //READ RESULT REGISTER
            m_ral_model.result.read(status, result);
            `uvm_info("SEQ", $sformatf("RESULT = %h", result), UVM_MEDIUM)
        #100ns
         //READ MONITOR REGISTER
             m_ral_model.monitor.read(status, monitor);
            `uvm_info("SEQ", $sformatf("MONITOR STATUS = %h", monitor), UVM_MEDIUM) 
        end
   endtask
endclass


`endif
