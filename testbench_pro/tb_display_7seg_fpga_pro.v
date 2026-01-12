`timescale 1ns/1ps
// TB: Sequential 7-Segment Display FPGA Module (Requirement 5)
// Displays 3x3 results then 2x2 results, 1 second per value
module tb_display_7seg_fpga;
    parameter CLK_PERIOD = 10;  // 100MHz
    parameter CLK_FREQ = 100000000;
    parameter SCAN_FREQ = 1000;      // Fast scan for simulation
    parameter DISPLAY_TIME = 100;    // Very short for simulation (100 cycles instead of 100M)
    
    reg clk, rst_n;
    reg start;
    reg [7:0] sa3x3_c11, sa3x3_c12, sa3x3_c21, sa3x3_c22;
    reg [7:0] sa2x2_c11, sa2x2_c12, sa2x2_c21, sa2x2_c22;
    wire [7:0] digit;
    wire [6:0] seg;
    wire done;
    
    display_7seg_fpga #(
        .CLK_FREQ(CLK_FREQ),
        .SCAN_FREQ(SCAN_FREQ),
        .DISPLAY_TIME(DISPLAY_TIME)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start),
        .sa3x3_c11(sa3x3_c11), .sa3x3_c12(sa3x3_c12),
        .sa3x3_c21(sa3x3_c21), .sa3x3_c22(sa3x3_c22),
        .sa2x2_c11(sa2x2_c11), .sa2x2_c12(sa2x2_c12),
        .sa2x2_c21(sa2x2_c21), .sa2x2_c22(sa2x2_c22),
        .digit(digit), .seg(seg),
        .done(done)
    );
    
    initial begin clk=0; forever #(CLK_PERIOD/2) clk=~clk; end
    
    // Monitor variables (declared at module level for Verilog-2001)
    reg [7:0] current_value;
    reg [2:0] prev_value_idx;
    integer timeout_count;
    
    initial begin
        $display("=== Sequential Display 7-Segment FPGA Testbench ===");
        $display("Testing Requirement 5: 3x3 -> 2x2 sequential display");
        
        // Initialize
        prev_value_idx = 3'd7;  // Initialize to detect first value (0)
        rst_n = 1; start = 0;
        sa3x3_c11 = 8'd54; sa3x3_c12 = 8'd63;
        sa3x3_c21 = 8'd90; sa3x3_c22 = 8'd99;
        sa2x2_c11 = 8'd54; sa2x2_c12 = 8'd63;
        sa2x2_c21 = 8'd90; sa2x2_c22 = 8'd99;
        
        // Reset
        #CLK_PERIOD; rst_n = 0; #(CLK_PERIOD*2); rst_n = 1; #CLK_PERIOD;
        
        $display("\nTest: Sequential display flow");
        $display("  3x3 Results: C11=%d, C12=%d, C21=%d, C22=%d", 
                 sa3x3_c11, sa3x3_c12, sa3x3_c21, sa3x3_c22);
        $display("  2x2 Results: C11=%d, C12=%d, C21=%d, C22=%d",
                 sa2x2_c11, sa2x2_c12, sa2x2_c21, sa2x2_c22);
        
        // Start display
        start = 1;
        #CLK_PERIOD;
        start = 0;
        
        // Wait for done signal
        $display("\n  Display sequence started...");
        $display("  (Each value displays for %0d cycles in simulation)", DISPLAY_TIME);
        
        // Wait for done with timeout (Verilog-2001 compatible)
        timeout_count = 0;
        while (!done && timeout_count < DISPLAY_TIME * 10) begin
            #CLK_PERIOD;
            timeout_count = timeout_count + 1;
        end
        
        if (done)
            $display("\n  DONE signal received!");
        else
            $display("\n  Timeout waiting for done!");
        
        #(CLK_PERIOD*10);
        
        if (done)
            $display("\n=== TEST PASSED: Sequential display completed ===");
        else
            $display("\n=== TEST FAILED: Display did not complete ===");
        
        $finish;
    end
    
    // Monitor value_idx transitions
    always @(posedge clk) begin
        if (dut.state == 1 && dut.value_idx != prev_value_idx) begin
            case(dut.value_idx)
                0: $display("  -> Displaying 3x3 C11 = %d", sa3x3_c11);
                1: $display("  -> Displaying 3x3 C12 = %d", sa3x3_c12);
                2: $display("  -> Displaying 3x3 C21 = %d", sa3x3_c21);
                3: $display("  -> Displaying 3x3 C22 = %d", sa3x3_c22);
                4: $display("  -> Displaying 2x2 C11 = %d", sa2x2_c11);
                5: $display("  -> Displaying 2x2 C12 = %d", sa2x2_c12);
                6: $display("  -> Displaying 2x2 C21 = %d", sa2x2_c21);
                7: $display("  -> Displaying 2x2 C22 = %d", sa2x2_c22);
            endcase
            prev_value_idx <= dut.value_idx;
        end
    end
endmodule
