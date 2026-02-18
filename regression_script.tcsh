#!/bin/tcsh



#for summary
# Define summary file and ensure the directory exists
set RESULTS_DIR = "results"
set SUMMARY_FILE = "$RESULTS_DIR/summary.log"

# Create the results directory if it doesn't exist
if (! -d $RESULTS_DIR) then
    mkdir $RESULTS_DIR
endif

# Clear the summary file at the beginning
echo "Test Summary Results" > $SUMMARY_FILE
echo "====================" >> $SUMMARY_FILE
echo "Test Name       Run    Result" >> $SUMMARY_FILE
echo "====================" >> $SUMMARY_FILE



# Array of test names
set TESTNAMES = ( base_test sanity_operation_test sanity_no_start_operation_test sanity_monitor_register_test functional_add_waitstate_test functional_no_start_exec_test functional_sequence_order_test error_invalid_write_address_test error_invalid_read_address_test error_invalid_ctrl_data_test error_underflow_test error_overflow_test random_test reset_test min_max_test edge_case_test half_div_test)
#set TESTNAMES = (alu_base_test)

# Number of times to run each test
set N = 10

@ total_tests = 0


# Iterate over test names
foreach TESTNAME ($TESTNAMES)
   # Inner loop to run each test N times
   foreach i (`seq 1 $N`)
      # Run the command with the current test name and seed
      echo "\n\nRunning test: $TESTNAME, seed: $i\n\n"
      xrun -timescale 1ns/1ns -sysv -access +rw -uvm -coverage ALL -dutinst top_tb/dut/alu_top_module -covoverwrite -nolibcell -seed RANDOM -f compile_files.f -uvmhome CDNS-1.2 \
      top_tb.sv \
      +UVM_VERBOSITY=UVM_LOW\
      +UVM_TESTNAME=$TESTNAME -l logs/${TESTNAME}_$i.log \
      +DUMPNAME="${TESTNAME}_$i.vcd" -covtest ${TESTNAME}_$i

      #summary
  # Extract and append UVM report summary to the results file
        echo "\nTest: ${TESTNAME}_$i" >> $SUMMARY_FILE
        grep -A 4 "\*\* Report counts by severity" logs/${TESTNAME}_$i.log >> $SUMMARY_FILE

        # Extract UVM_ERROR and UVM_FATAL counts for pass/fail evaluation
        set error_count = `grep "UVM_ERROR" ${TESTNAME}_$i.log | awk '{print $NF}'`
        set fatal_count = `grep "UVM_FATAL" ${TESTNAME}_$i.log | awk '{print $NF}'`

        

        # Append result to the summary file

        echo "--------------------" >> $SUMMARY_FILE

        # Increment total tests counter
        @ total_tests++
        
   end

end


# Final message
echo "Regression run completed. Summary can be found in $SUMMARY_FILE."
