`timescale 1ns/1ps
// TB: PE Module
module tb_pe;
    parameter CLK_PERIOD = 10;
    
    reg clk, rst_n, clr_acc, en, load_b;
    reg [7:0] a_in, b_in, c_in;
    wire [7:0] a_out, b_out, acc_out, c_out;
    
    pe dut (.clk(clk),.rst_n(rst_n),.clr_acc(clr_acc),.en(en),.load_b(load_b),
            .a_in(a_in),.b_in(b_in),.c_in(c_in),
            .a_out(a_out),.b_out(b_out),.acc_out(acc_out),.c_out(c_out));
    
    initial begin clk=0; forever #(CLK_PERIOD/2) clk=~clk; end
    
    initial begin
        $display("=== PE Testbench ===");
        rst_n=1; clr_acc=0; en=0; load_b=1; a_in=0; b_in=0; c_in=0;
        #(CLK_PERIOD*2); rst_n=0; #(CLK_PERIOD*2); rst_n=1; #CLK_PERIOD;
        
        // Test 1: MAC (load_b=1 mode)
        $display("Test 1: MAC"); en=1; load_b=1; a_in=8'd3; b_in=8'd4; c_in=8'd0;
        #CLK_PERIOD; $display("  3*4=%d (exp 12)", acc_out);
        a_in=8'd5; b_in=8'd6;
        #CLK_PERIOD; $display("  +5*6=%d (exp 42)", acc_out);
        
        // Test 2: Clear
        $display("Test 2: Clear"); clr_acc=1; #CLK_PERIOD; clr_acc=0;
        $display("  acc=%d (exp 0)", acc_out);
        
        // Test 3: Weight Stationary (load_b=0, b_out reuse)
        $display("Test 3: Weight Stationary"); en=1; load_b=1; a_in=8'd2; b_in=8'd7;
        #CLK_PERIOD; $display("  2*7=%d (exp 14)", acc_out);
        load_b=0; a_in=8'd3; // b_out=7 재사용
        #CLK_PERIOD; $display("  +3*7=%d (exp 35)", acc_out);
        
        // Test 4: C_in to C_out path
        $display("Test 4: C_out path"); en=0; load_b=1; a_in=8'd10; b_in=8'd2; c_in=8'd5;
        #CLK_PERIOD; $display("  c_out=10*2+5=%d (exp 25)", c_out);
        
        #(CLK_PERIOD*5);
        $display("=== PE Test Complete ===");
        $finish;
    end
endmodule
