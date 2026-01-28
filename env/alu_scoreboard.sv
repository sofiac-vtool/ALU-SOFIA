//--------------------------------------------------------------
`ifndef ALU_SCOREBOARD_SV
`define ALU_SCOREBOARD_SV

// TODO: * * * Call the imp_decl macro * * *
`uvm_analysis_imp_decl(_)
`uvm_analysis_imp_decl(_rst_detected)

class alu_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(alu_scoreboard)

// TODO: * * * Declare the analysis import for received data items * * * 
	uvm_analysis_imp#(apb_transaction, alu_scoreboard) alu_analysis_export;
    uvm_analysis_imp_rst_detected#(bit, alu_scoreboard) rst_imp;

   // INPUT REGISTERS
   bit [15:0] reg1;
   bit [15:0] reg2;
   bit [1:0]  operation;
   bit        start_bit;
   bit        expected_error;
   bit [24:0] exp_data;
   bit [1:0] exp_monitor;
   bit [7:0] req_id;

   // INPUT BUS STRUC
   typedef struct {
      bit [1:0]  op;
      bit [9:2]  id_in;
      bit [25:10] oper1;
      bit [41:26] oper2;
   } alu_fifo_in_t;

   // OUTPUT RESULT STRUCT
   typedef struct {
      bit [24:17] id;
      bit [16:16]  carry_out;
      bit [15:0]  result;
   } alu_result_t;

   // INPUT FIFO 
   alu_fifo_in_t fifo_in_queue[$];

   // OUTPUT FIFO 
   alu_result_t expected_queue[$];

   // INTERNAL STATE FOR FIFO & ALU 
   // ---------------------------------------------------------
   localparam int FIFO_IN_DEPTH  = 4;
   localparam int FIFO_OUT_DEPTH = 4;

   int fifo_in_count  = 0;   
   int fifo_out_count = 0;  

   bit alu_add_busy = 0;     // add slot
   bit alu_mul_busy = 0;     // mul slot

   // monitor register based on OUT FIFO
   bit [1:0] monitor_reg;

   int monitoraki;
   
   // ---------------------------------------------------------
   // VIRTUAL INTERFACE
   virtual interfc vintf;
   reg_block   m_ral_model;

   // ---------------------------------------------------------
   //Extern Functions
	
	extern function new(string name="alu_scoreboard", uvm_component parent=null);
	extern function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);


	// Declare the write function //
	extern function void write(apb_transaction pkt);
	extern function void write_rst_detected(bit reset_bit);
    extern function void operation_make();
	extern function void do_write(apb_transaction pkt);
    extern function void do_read(apb_transaction pkt);


	// Helper functions
	extern function bit[16:0] do_operation  (bit [15:0] A, bit [15:0] B, bit [1:0] op);// DO ADD AND MUL OPERATION
	extern function automatic bit input_fifo_full(); //CHECKS WHETHER SYSTEM IS FULL	

 //  extern function void reg_address(); 

endclass

// ---------------------------------------------------------
// Constructor
// ---------------------------------------------------------
function alu_scoreboard::new(string name="alu_scoreboard", uvm_component parent=null);
   super.new(name,parent);
endfunction

// ---------------------------------------------------------
// BUILD PHASE 
// ---------------------------------------------------------
function void alu_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase);
	alu_analysis_export = new("alu_analysis_export", this);
	rst_imp = new("rst_imp", this);
   if(!uvm_config_db#(virtual interfc)::get(this,"","interfc", vintf))
      `uvm_fatal(get_type_name(), "Unable to get virtual interface")
endfunction


// ---------------------------------------------------------
// RUN PHASE 
// ---------------------------------------------------------
task alu_scoreboard::run_phase(uvm_phase phase);

  `uvm_info("run_phase", $sformatf("inside the run phase"), UVM_NONE)
  
    /*forever begin
        @(negedge vintf.rst_n);
        fifo_in_queue.delete();
        expected_queue.delete();
        fifo_in_count  = 0;
        fifo_out_count = 0;
        alu_add_busy = 0;
        alu_mul_busy = 0;
        expected_error = 0;
        @(posedge vintf.rst_n);
    end*/
endtask

// =========================================================
//          C A L L B A C K   W R I T E   F U N C T I O N
// =========================================================
function void alu_scoreboard::write(apb_transaction pkt);
`uvm_info("SB_DEBUG",
  $sformatf("SB GOT pkt: write=%0b addr=%0h data=%0h",
            pkt.write, pkt.addr, pkt.data),
  UVM_LOW)
   // If packet is WRITE operation

   if(pkt.write) begin         
	  do_write(pkt); // Call do write  function
   end

   // If packet is READ operation
   else if(!pkt.write)begin    
	do_read(pkt); // Call do read task
   end

endfunction

// ---------------------------------------------------------
// ALU IMPLEMENTATION 
// ---------------------------------------------------------
function automatic bit [16:0] alu_scoreboard::do_operation(bit [15:0] A, bit [15:0] B, bit [1:0] op);
   case(op)
      2'b01: do_operation = A + B;             // ADD
      2'b10: do_operation = (A[7:0] * B[7:0]); // MUL (8-bit operands)
      default: do_operation = 0;
   endcase
endfunction

// ---------------------------------------------------------
// SYSTEM CAPACITY = input FIFO + ALU slots + output FIFO
// ---------------------------------------------------------
function bit alu_scoreboard::input_fifo_full();
	 	return (fifo_in_count == FIFO_IN_DEPTH);
endfunction 
//-------------------------------------------------------------

function void alu_scoreboard::operation_make();

alu_result_t res;
bit [16:0] add_result;
alu_fifo_in_t mul_bus;
alu_fifo_in_t add_bus;
alu_fifo_in_t bus;
bus = fifo_in_queue.pop_front();
 `uvm_info("MONITORAKI", $sformatf("BUSSSSS=%b", bus.op), UVM_LOW)

case(bus.op)
   
// ADD
2'b01: begin
     // `uvm_info("MONITORAKI", $sformatf("ADD count=%b", fifo_in_count), UVM_LOW)
    if(!alu_add_busy) begin
        alu_add_busy = 1;
        fifo_in_count--;
        add_bus = bus;

        add_result = do_operation(add_bus.oper1, add_bus.oper2, add_bus.op);
		res.carry_out = add_result[16];
		res.result = add_result[15:0];
        res.id = bus.id_in;

     //if(fifo_out_count < FIFO_OUT_DEPTH) begin
        expected_queue.push_back(res);
        fifo_out_count++;
        alu_add_busy = 0;
     end

end
// MUL
2'b10:begin
     // `uvm_info("MONITORAKI", $sformatf("ADD count=%b", fifo_in_count), UVM_LOW)
      if(!alu_mul_busy) begin
         alu_mul_busy = 1;
         fifo_in_count--;
    	 mul_bus = bus;

         res.result = do_operation(mul_bus.oper1, mul_bus.oper2, mul_bus.op);
         res.id = bus.id_in;

         //if(fifo_out_count < FIFO_OUT_DEPTH) begin
            expected_queue.push_back(res);
            fifo_out_count++;
            alu_mul_busy = 0;
      end
end
default: begin
            `uvm_info("SCOREBOARD", "Not valid operation", UVM_LOW)
             expected_error = 1;
         end
       
endcase

endfunction

// =========================================================
//                      DO WRITE FUNCTION
// =========================================================
function void alu_scoreboard::do_write(apb_transaction pkt);
  // alu_result_t res;
	//bit [16:0] add_result;
    alu_fifo_in_t data_in;
	//alu_fifo_in_t mul_bus;
 	//alu_fifo_in_t add_bus;

   case(pkt.addr)
        
      // ---------------------------------------------------
      // CONTROL REGISTER (addr 0)
      // ---------------------------------------------------
    3'b000: begin
     start_bit = pkt.data[0];
     operation = pkt.data[2:1];
     req_id    = pkt.data[15:8];

     if(start_bit) begin
        // -------------------------------
        // CHECK TOTAL CAPACITY 
        // -------------------------------
        if(input_fifo_full()) begin
           `uvm_info("SCOREBOARD", "SYSTEM FULL,cannot accept new operation", UVM_LOW)
            expected_error = 1;
             if (pkt.slv_err !== expected_error)
                `uvm_error("SCOREBOARD",$sformatf("Mismatch  FIFO_OUT EMPTY with slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
        end
        // -------------------------------
        // PUSH INTO INPUT FIFO
        // -------------------------------
        else begin
            fifo_in_count++;
            data_in.op = operation ; 
		    data_in.id_in = req_id;
     		data_in.oper1 = reg1;
		    data_in.oper2 = reg2;
            fifo_in_queue.push_back(data_in);
            ////////////////
            monitoraki = fifo_in_count + fifo_out_count ; 
            `uvm_info("MONITORAKI", $sformatf(" count=%d", monitoraki), UVM_LOW)
            if(fifo_out_count == 4)
               `uvm_info("SCOREBOARD", "FIFO OUT FULL,cannot accept new operation", UVM_LOW)
            else begin
                expected_error = 0;
                operation_make();
                
                if (pkt.slv_err !== expected_error)
                     `uvm_error("SCOREBOARD",$sformatf("Mismatch  FIFO_OUT EMPTY with slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
                end
            end
        end
    end
      // ---------------------------------------------------
      // INPUT REGISTERS addr 1&2
      // ---------------------------------------------------
      3'b001:begin 
                if(input_fifo_full()) begin
                    `uvm_info("SCOREBOARD", "SYSTEM FULL,cannot accept new operation", UVM_LOW)
                    expected_error = 1;
                    if (pkt.slv_err !== expected_error)
                     `uvm_error("SCOREBOARD",$sformatf("Mismatch  FIFO_OUT EMPTY with slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
                 return;
                end else begin
                reg1 = pkt.data;
                end
             end
      3'b010: begin 
                if(input_fifo_full()) begin
                    `uvm_info("SCOREBOARD", "SYSTEM FULL,cannot accept new operation", UVM_LOW)
                    expected_error = 1;
                    if (pkt.slv_err !== expected_error)
                     `uvm_error("SCOREBOARD",$sformatf("Mismatch  FIFO_OUT EMPTY with slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
                 return;
                end else begin
                reg2 = pkt.data;
                end
               end
      // ---------------------------------------------------
      // RO ADDRESSES
      // ---------------------------------------------------
      3'b011, 3'b100: begin 
        expected_error = 1;
          if (pkt.slv_err !== expected_error)
        `uvm_error("SCOREBOARD RO ADDRESSES",$sformatf("Mismatch slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
        end
      // ---------------------------------------------------
      // INVALID ADDRESSES
      // ---------------------------------------------------
      default: begin
         expected_error = 1;
          if (pkt.slv_err !== expected_error)
            `uvm_error("SCOREBOARD NOT USED ADDRESSES",$sformatf("Mismatch slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
        end
   endcase
endfunction


// =========================================================
//                       R E A D
// =========================================================

function void alu_scoreboard::do_read(apb_transaction pkt);
   alu_result_t exp;
   int idx;
   int found_res;
   case(pkt.addr)

   // ---------------------------------------------------
   // READ RESULT (addr 3)with wait-state + ID match
   // ---------------------------------------------------
   3'b011: begin
    //`uvm_info("MONITORAKI", $sformatf(" count=%d", fifo_in_count), UVM_LOW)
     // wait until output FIFO has somethingE
     if(fifo_out_count <= 0)begin
      expected_error =1;
      if (pkt.slv_err !== expected_error)
        `uvm_error("SCOREBOARD",$sformatf("Mismatch  FIFO_OUT EMPTY with slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
       end
     else begin
        expected_error = 0;
        if (pkt.slv_err !== expected_error)
            `uvm_error("SCOREBOARD WO ADDRESSES",$sformatf("Mismatch slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
         found_res = 0;
         // search for matching ID
         for(idx=0; idx < expected_queue.size(); idx++) begin
              //  `uvm_info("SCORE", $sformatf("size=%d", pkt.data[24:17]), UVM_LOW)

            if(expected_queue[idx].id == pkt.data[24:17]) begin
               exp = expected_queue[idx];
               expected_queue.delete(idx);
               `uvm_info("SCORE", $sformatf("size=%d", exp.id), UVM_LOW)
               fifo_out_count--;
               found_res = 1;
               if(fifo_in_count !=0) 
                operation_make();
               break;
            end
         end
	//Check if I found result 
	if(!found_res)begin
	`uvm_error("SCOREBOARD",$sformatf("Did not find matching data"));
	end
        exp_data = {7'b0, exp.id, exp.carry_out, exp.result};
        `uvm_info("SCORE", $sformatf("ID=%d carry = %h result = %h", exp.id, exp.carry_out, exp.result), UVM_LOW)
        monitoraki = fifo_in_count + fifo_out_count ; 
        `uvm_info("MONITORAKI", $sformatf(" count=%d", monitoraki), UVM_LOW)
      // ===== COMPARE RESULT DATA =====
      if (pkt.data !== exp_data)
         `uvm_error("SB_DATA_MISMATCH",
            $sformatf("Expected=0x%0h Actual=0x%0h",
                      exp_data, pkt.data))
    end
end
   // ---------------------------------------------------
   // MONITOR REGISTER (addr 4)
   // ---------------------------------------------------
   3'b100: begin
        expected_error = 0;
        if (pkt.slv_err !== expected_error)
            `uvm_error("SCOREBOARD WO ADDRESSES",$sformatf("Mismatch slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
	    exp_monitor[0] = (fifo_out_count == 0); // empty
      // `uvm_info("MONITORAKI",$sformatf("Expected count=%b", exp_monitor[0]),UVM_LOW)
      exp_monitor[1] = (fifo_out_count == 4); // full
    
    
    // ===== COMPARE MONITOR STATUS =====
      if (pkt.data[1:0] !== exp_monitor)
         `uvm_error("SB_MONITOR_MISMATCH",
            $sformatf("Expected monitor=%b Actual=%b",
                      exp_monitor, pkt.data[1:0]))
   end

   // ---------------------------------------------------
   // WO READ ADDRESS
   // ---------------------------------------------------
	3'b000, 3'b001, 3'b010 :begin
     expected_error=1;
      if (pkt.slv_err !== expected_error)
            `uvm_error("SCOREBOARD WO ADDRESSES",$sformatf("Mismatch slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
        end
   // ---------------------------------------------------
   // INVALID READ ADDRESS
   // ---------------------------------------------------
   default:begin
      expected_error = 1;
      if (pkt.slv_err !== expected_error)
            `uvm_error("SCOREBOARD NOT USED ADDRESSES",$sformatf("Mismatch slv_error=%0h expected=%0h",pkt.slv_err,expected_error));
      end
   endcase 
    
endfunction

function void alu_scoreboard::write_rst_detected(bit reset_bit);
  `uvm_info("SCBD", $sformatf("MID LIFE ",), UVM_NONE)

  if(reset_bit == 1) begin
     `uvm_info("SCBD", $sformatf("reset detected"), UVM_NONE)
     `uvm_info("SCBD", $sformatf("MID LIFE 2",), UVM_NONE)
	 fifo_in_queue.delete();
     expected_queue.delete();
     fifo_in_count  = 0;
     fifo_out_count = 0;
     alu_add_busy = 0;
     alu_mul_busy = 0;
     expected_error = 0;
  end

 // cvg_obj.mid_rst_cg.sample();

endfunction




`endif

