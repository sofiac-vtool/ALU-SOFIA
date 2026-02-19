
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
////////////////// Coverage 
// TODO: * * * Call the imp_decl macro * * *
//-------------------------------------------------------------------------------------------------------------
// TODO: * * * Call the imp_decl macro * * *

class alu_coverage;

 // `uvm_component_utils(alu_coverage)
/*  `uvm_analysis_imp_decl(_)
`uvm_analysis_imp_decl(_rst_detected) 
  // Analysis port from monitor
  uvm_analysis_imp#(apb_transaction, alu_coverage) alu_analysis_export;
  uvm_analysis_imp_rst_detected#(bit, alu_coverage) rst_imp;*/
//-------------------------------------------------------------------
   

    // Local sampled vars (for RAL-based coverage)
   bit write;
   bit [15:0] data;
   bit [2:0] addr;
   bit slv_err;
   bit [1:0]  operation;
   bit        start_bit;
   bit [7:0]  id;
   bit [15:0] data0;
   bit [15:0] data1;
   bit [24:0] result;
   bit empty;
   bit full;
   bit [1:0] operation_transition;
   bit add_carry_out;
   bit reset_detected;
   bit overflow;
   bit underflow;
   
//   virtual interfc vintf;
 //  reg_block ral;
//--------------------------------------------------------------------------
/////////////////////*********Bus level***********////////////////////////
//------------------------------------------------------------------------
//Smples σε κάθε transaction
covergroup apb_transaction_cg;
      option.per_instance = 1;
      
   wr_rd_cp: coverpoint write{
         bins rd = {0};
         bins wr = {1};
      }
      
      wr_rd_transition_cp : coverpoint write{
         bins write_read = (1 => 0);
         bins read_write = (0 => 1);
         bins write_write = (1 => 1);
         bins read_read = (0 => 0);
      }

      data_cp: coverpoint data;

       addr_cp : coverpoint addr {
      bins ctrl    = {3'b000};
      bins data0   = {3'b001};
      bins data1   = {3'b010};
      bins result  = {3'b011};
      bins monitor = {3'b100};
		bins inv5 = {3'b101};
		bins inv6 = {3'b110};
		bins inv7 = {3'b111};
    }

      slv_err_cp : coverpoint slv_err{
      bins ok  = {0};
      bins err = {1};
    }

///Cross write and address
      write_x_addr: cross wr_rd_cp, addr_cp;
      
///Error cases

    err_cross : cross wr_rd_cp, addr_cp, slv_err_cp
  //iff (slv_err == 1) 
  {
  option.cross_auto_bin_max = 0;
  // -------------------------
  // WRITE error bins (5)
  // -------------------------
  bins wr_err_3 =
    binsof(wr_rd_cp.wr) && binsof(addr_cp.result)&& binsof(slv_err_cp.err);

  bins wr_err_4 =
    binsof(wr_rd_cp.wr) && binsof(addr_cp.monitor)&& binsof(slv_err_cp.err);

  bins wr_err_5 =
    binsof(wr_rd_cp.wr) && binsof(addr_cp.inv5)&& binsof(slv_err_cp.err);

  bins wr_err_6 =
    binsof(wr_rd_cp.wr) && binsof(addr_cp.inv6)&& binsof(slv_err_cp.err);

  bins wr_err_7 =
    binsof(wr_rd_cp.wr) && binsof(addr_cp.inv7)&& binsof(slv_err_cp.err);

  // -------------------------
  // READ error bins (6)
  // -------------------------
  bins rd_err_0 =
    binsof(wr_rd_cp.rd) && binsof(addr_cp.ctrl)&& binsof(slv_err_cp.err);

  bins rd_err_1 =
    binsof(wr_rd_cp.rd) && binsof(addr_cp.data0)&& binsof(slv_err_cp.err);

  bins rd_err_2 =
    binsof(wr_rd_cp.rd) && binsof(addr_cp.data1)&& binsof(slv_err_cp.err);

  bins rd_err_5 =
    binsof(wr_rd_cp.rd) && binsof(addr_cp.inv5)&& binsof(slv_err_cp.err);

  bins rd_err_6 =
    binsof(wr_rd_cp.rd) && binsof(addr_cp.inv6)&& binsof(slv_err_cp.err);

  bins rd_err_7 =
    binsof(wr_rd_cp.rd) && binsof(addr_cp.inv7)&& binsof(slv_err_cp.err);
    
// ignore_bins ignore_ok =  binsof(wr_rd_cp) && binsof(addr_cp) && binsof(slv_err_cp.ok);


}
   endgroup : apb_transaction_cg
   
//------------------------------------------------------------------------
////////////////**********Input Data quality**********////////////////////
//------------------------------------------------------------------------
covergroup wdata_bit_toggle_cg;
  option.per_instance = 1;


  bit0_cp : coverpoint data[0] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit1_cp : coverpoint data[1] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit2_cp : coverpoint data[2] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

 bit3_cp : coverpoint data[3] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit4_cp : coverpoint data[4] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit5_cp : coverpoint data[5] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }
    bit6_cp : coverpoint data[6] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit7_cp : coverpoint data[7] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit8_cp : coverpoint data[8] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

 bit9_cp : coverpoint data[9] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit10_cp : coverpoint data[10] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit11_cp : coverpoint data[11] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }
  bit12_cp : coverpoint data[12] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

 bit13_cp : coverpoint data[13] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit14_cp : coverpoint data[14] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

  bit15_cp : coverpoint data[15] {
      bins is0 = {0};
      bins is1 = {1};
      bins t01 = (0 => 1);
      bins t10 = (1 => 0);
  }

endgroup : wdata_bit_toggle_cg


//------------------------------------------------------------------------
///////////////////***********Registers***********////////////////////////
//------------------------------------------------------------------------
covergroup ctl_reg_cg;
	option.per_instance = 1;
    //bit [1:0] operation;
  //  bit       start;
   // bit [7:0] id;
    
    operation_transition_cp : coverpoint operation{
         bins addition_addition = (01 => 01);
         bins multiplication_multiplication = (10=> 10);
         bins multiplication_addition = (10 => 01);
         bins addition_multiplication = (01 => 10);
      }

      operation_cp: coverpoint operation{
         bins addition = {01};
         bins multiplication = {10};// θα τα συνδεσω στη λογικη με το item
         bins err_op = {00};
         bins err_op2 = {11};
      }  
      
      start_bit_cp :coverpoint start_bit; 
      
     id_cp : coverpoint id {
       // bins zero = {0};
        bins mid  = {[1:254]};
        bins max  = {255};
    }
    
     overflow_cp: coverpoint overflow{
		      ignore_bins overflow = {0};//πως μπορω να ξέρω πότε να κάνω sample και τι θα κάνω sample
		   }
  
 // Special operations
    add_zero_cp : coverpoint (data0 == 0 || data1 == 0) iff (operation == 2'b01);
    mul_one_cp  : coverpoint (data0 == 1 || data1 == 1) iff (operation == 2'b10);
    half_div_cp : coverpoint ((data0 > 16'hFF) && (data1 > 16'hFF)) iff (operation == 2'b10); // multiplication/division
  
   endgroup: ctl_reg_cg
//------------------------------------------------------------------------
 covergroup data0_reg_cg;
    option.per_instance = 1;
    
    data0_cp : coverpoint data0 {
      bins zero  = {16'h0000};
      bins till_half = {[1:16'h00FF]};
      bins bigger_than_half = {[16'h0100:16'h7FFF]};
      bins max   = {16'hFFFF};
    }
  endgroup: data0_reg_cg
//------------------------------------------------------------------------
  covergroup data1_reg_cg;
	option.per_instance = 1;
    data1_cp : coverpoint data1 {
      bins zero  = {16'h0000};
      bins till_hlaf = {[1:16'h00FF]};
      bins bigger_than_half = {[16'h0100:16'h7FFF]};
      bins max   = {16'hFFFF};
    }
  endgroup: data1_reg_cg
//------------------------------------------------------------------------
///////////////************Monitor Reg**************///////////////
//------------------------------------------------------------------------
covergroup monitor_reg_cg;
option.per_instance = 1;
  fifo_out_empty_cp: coverpoint empty;//reg monitor
  fifo_out_full_cp: coverpoint full;//reg monitor
endgroup: monitor_reg_cg

//------------------------------------------------------------------------
///////////////************Result Reg**************///////////////
//------------------------------------------------------------------------
covergroup result_reg_cg;
option.per_instance = 1;
 underflow_cp: coverpoint underflow{
		      ignore_bins underflow = {0};//reg monitor bit0 =1 + read
		   }

//COVERGROUP ADD X OPERANDS >16'b1000000000000000(so that there will be a carry out)
			add_carry_out_cp: coverpoint add_carry_out{
		      ignore_bins add_carry_out = {0};
		   }	   
endgroup: result_reg_cg
//------------------------------------------------------------------------
///////////////************Reset**************///////////////
//------------------------------------------------------------------------		   
covergroup reset_cg;
option.per_instance = 1;

  reset_sample_cp: coverpoint reset_detected {
    bins reset_asserted = {1};
  }
endgroup: reset_cg
//----------------------------------------------------------------------------------------------------------------------------------
// Constructor
function new();
 //super.new(name, parent);
	 
	 
    apb_transaction_cg      = new();//sample on transaction
    wdata_bit_toggle_cg     = new();//sample on transaction
    ctl_reg_cg              = new();//sample every time I hit addr 0
    data0_reg_cg            = new();//sample every time I hit addr 1
    data1_reg_cg            = new();//sample every time I hit addr 2
    monitor_reg_cg          = new();//sample every time I hit addr 4
    result_reg_cg   	    	 = new();//sample every time I hit addr 3
    reset_cg     	   		 = new();
    
  
endfunction

endclass


