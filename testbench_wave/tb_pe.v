`timescale 1ns/1ns
// Student TB: PE Module - Verify MAC operations
module tb_pe;
    reg clk, rst_n, clr_acc, en, load_b;
    reg [7:0] a_in, b_in, c_in;
    wire [7:0] a_out, b_out, acc_out, c_out;
    
    pe uut (.clk(clk), .rst_n(rst_n), .clr_acc(clr_acc), .en(en), .load_b(load_b),
            .a_in(a_in), .b_in(b_in), .c_in(c_in),
            .a_out(a_out), .b_out(b_out), .acc_out(acc_out), .c_out(c_out));
    
    initial begin clk = 0; forever #0.5 clk = ~clk; end
    
    initial begin
        rst_n = 0; clr_acc = 0; en = 0; load_b = 1; 
        a_in = 0; b_in = 0; c_in = 0;
        #5 rst_n = 1; #3;
        // Test 1: MAC operation (3x4 + 2x5 = 22)
        @(posedge clk); clr_acc = 1;
        @(posedge clk); clr_acc = 0; en = 1;
                        a_in = 8'd3; b_in = 8'd4; c_in = 8'd0;  // 3x4=12
        @(posedge clk); a_in = 8'd2; b_in = 8'd5;  // +2x5=10 → acc=22
        // Test 2: Weight Stationary mode (load_b=0, reuse b_out)
        @(posedge clk); load_b = 0;
                        a_in = 8'd1;  // 1x5=5 → acc=27
        @(posedge clk); en = 0;
        // Verify acc_out=27
        repeat(5) @(posedge clk);
        $finish;
    end
endmodule
