// File name:   tb_sample_rate_clkdiv.v
// Author:      Vishnu Lagudu
// Description: Testbench for sample rate

`timescale 1ns/10ps

module tb_sample_rate_clkdiv ();

    // Local parameters used by the testbench
    localparam CLK_PERIOD         = 100;
    localparam RESET_OUTPUT_VALUE = 1'b0;

    // DUT portmap signals
    reg  tb_clk, tb_n_rst; 
    wire tb_divide_now;

    // Test Bench Signals
    integer      tb_test_num, wrong;
    reg [1023:0] tb_test_case;

    // Task for standard DUT reset procedure
    task reset_dut;
    begin
        // Activate the reset
        tb_n_rst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from the rising edge of the clock before releasing
        @(negedge tb_clk);
        tb_n_rst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask

    // Task to cleanly and consistently check DUT output values
    task check_output;
    input reg expected_divide_now;
    begin
        wrong = 0;
        if (expected_divide_now != tb_divide_now) begin
            $error ("Incorrect count_out output during %d", tb_test_num);
        end else begin
            $display ("Correct outputs during %d", tb_test_num);
        end
    end
    endtask

    // 10 MHz Clock
    always begin
        // Start with clock low to avoid false rising edge events at t=0
        tb_clk = 1'b0;
        // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
    end

    /* --- Port Map (One for gl sim and the other for RTL sim) --- */
    `ifdef USE_POWER_PINS
    sample_rate_clkdiv DUT
    (
        .VPWR(1),
        .VGND(0),
        .clk(tb_clk),
        .n_rst(tb_n_rst),
        .divide_now(tb_divide_now)
    );
    `else
    sample_rate_clkdiv DUT
    (
        .clk(tb_clk),
        .n_rst(tb_n_rst),
        .divide_now(tb_divide_now)
    );
    `endif
    /* -------------------------- END ---------------------------- */

    // Create a file for Signal Dump
    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    /* --------- SDF annotation to simulate time for the verilog model -------- */
    `ifdef ENABLE_SDF
    initial begin
        $sdf_annotate("mapped/synth.sdf", DUT,,);
    end
    `endif
    /* ------ Please do not modify this code should be there in every tb ------ */

    initial begin
        // Initialize all of the test inputs
        tb_n_rst = 1'b1;
        tb_test_num = 0;
        // Wait some time before starting first test case
        #(0.1);

        // ************************************************************************
        // Test Case 1: Power-on Reset of the DUT
        // ************************************************************************
        tb_test_num = tb_test_num + 1;

        // Wait for some time before applying the test case stimulus
        #(0.1);
        // Apply the test case initial stimulus
        tb_n_rst = 1'b0; // Activate reset

        // Wait for a bit before checking the functionality
        #(CLK_PERIOD * 0.5);

        // Check that the internal state was correctly reset
        check_output(RESET_OUTPUT_VALUE);

        // Check that the reset value is maintained during a clock cycle
        #(CLK_PERIOD);
        check_output(RESET_OUTPUT_VALUE);
    
        // Wait for the negedge of the clock and release reset
        @(negedge tb_clk);
        tb_n_rst  = 1'b1;   // Deactivate the chip reset
        #(0.1);
        // Check that internal state was correctly keep after reset release
        check_output(RESET_OUTPUT_VALUE);

        // ************************************************************************
        // Test Case 2: Count to the Max value
        // ************************************************************************
        @(negedge tb_clk);
        tb_test_num = tb_test_num + 1;
        tb_test_case = "Count to the Max value";

        // Reset the DUT
        reset_dut();

        // Wait for DUT to process stimulus before checking results
        repeat (253) @(posedge tb_clk);

       // Move away from risign edge and allow for propagation delays before checking
        @(negedge tb_clk);
        check_output(1'b1);

        // ************************************************************************
        // Test Case 3: Count Midway
        // ************************************************************************
        @(negedge tb_clk);
        tb_test_num = tb_test_num + 1;
        tb_test_case = "Continous Midway";

        // Reset the DUT
        reset_dut();
        
        // Wait for DUT to process stimulus before checking results
        repeat (125) @(posedge tb_clk);

       // Move away from risign edge and allow for propagation delays before checking
        @(negedge tb_clk);
        check_output(1'b0);

        // ************************************************************************
        // Test Case 4: Over Count
        // ************************************************************************
        @(negedge tb_clk);
        tb_test_num = tb_test_num + 1;
        tb_test_case = "Over Count";

        // Reset the DUT
        reset_dut();
        
        // Wait for DUT to process stimulus before checking results
        repeat (400) @(posedge tb_clk);

       // Move away from risign edge and allow for propagation delays before checking
        @(negedge tb_clk);
        check_output(1'b0);

        // ************************************************************************
        // Test Case 5: Wrap Twice
        // ************************************************************************
        @(negedge tb_clk);
        tb_test_num = tb_test_num + 1;
        tb_test_case = "Wrap Twice";

        // Reset the DUT
        reset_dut();

        // Wait for DUT to process stimulus before checking results
        repeat (509) @(posedge tb_clk);

        // Move away from rising edge to allow propogation delays before checking
        @(negedge tb_clk);
        check_output(1'b1);

        $display("TEST COMPLETE");
        $finish;
    end

endmodule