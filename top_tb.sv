`include "alu_test_pkg.sv"

module top_tb;
    `include "uvm_macros.svh"
   //import pkg::*;
    import uvm_pkg::*;
  // import alu_pkg::*;
  // import env_pkg::*;
  //  import seq_pkg::*;
   import alu_test_pkg::*;

    // -------------------------------------------------
    // Declare clock and single reset
    // -------------------------------------------------
     reg  clk,RST_n ;
     wire psel,penable,ready,slv_err, pwrite, rst_n;
     wire [15:0] pwdata;
     wire [31:0] prdata;
     wire [(`REG_NUMBER-1):0]  paddr;
    // -------------------------------------------------
    // Declare APB signals and interface
    // -------------------------------------------------
    interfc vintf();

   assign vintf.clk = clk; 
   //assign vintf.RST_n= rst_n;
   assign rst_n = vintf.rst_n;

   assign pwdata = vintf.pwdata;
   assign psel = vintf.psel;
   assign penable = vintf.penable;
   assign pwrite = vintf.pwrite;
   assign paddr = vintf.paddr;


   assign vintf.ready = ready;
   assign vintf.slv_err = slv_err;
   assign vintf.prdata = prdata;
   assign vintf.presetn = vintf.rst_n & RST_n;

    // -------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------
   alu_top_module dut(

      .clk(clk),
      //.rst_n(rst_n),
      .rst_n(rst_n & RST_n ),
      .sel(psel),
      .en(penable),
      .write(pwrite),
      .addr(paddr),
      .wdata(pwdata),
      .ready(ready),
      .slv_err(slv_err),
      .rdata(prdata)

   );

    // -------------------------------------------------
    // Clock generation
    // -------------------------------------------------
    initial clk = 0;
    always #10 clk = ~clk;  // 50MHz clock period 20ns

    // -------------------------------------------------
    // Reset sequence
    // -------------------------------------------------
    initial begin
        //RST_n = 1;     // Initially out of reset
         RST_n = 0; // Assert reset
        #50 RST_n = 1; // Deassert reset
    end

    // -------------------------------------------------
    // Pass virtual interface to UVM components and run test
    // -------------------------------------------------
initial begin
   uvm_config_db#(virtual interfc)::set(null, "*", "interfc", vintf);
  // uvm_config_db#(fifo_config)::set(null, "*", "cfg", cfg);
//uvm_config_db#(env_config)::set(null, "*", "env_cfg", env_cfg);
        run_test();  // Start UVM test
    end

    // -------------------------------------------------
    // Optional waveform dump
    // -------------------------------------------------
    initial begin
        $recordfile("dump.vcd");
        $recordvars(top_tb);
        #100000000; // Simulation timeout
        $finish();
    end

endmodule

