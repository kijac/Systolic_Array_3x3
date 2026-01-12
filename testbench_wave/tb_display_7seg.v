`timescale 1ns/1ns
// Display TB: Verify 54→63→90→99→54→63→90→99 sequence (10 cycles each)
module tb_display_7seg;
    reg clk, rst_n, start;
    reg [7:0] sa3x3_c11, sa3x3_c12, sa3x3_c21, sa3x3_c22, sa2x2_c11, sa2x2_c12, sa2x2_c21, sa2x2_c22;
    wire [7:0] digit;
    wire [6:0] seg;
    wire done;
    display_7seg_fpga #(.CLK_FREQ(80), .SCAN_FREQ(10), .DISPLAY_TIME(10)
    ) uut (.clk(clk), .rst_n(rst_n), .start(start),
        .sa3x3_c11(sa3x3_c11), .sa3x3_c12(sa3x3_c12), .sa3x3_c21(sa3x3_c21), .sa3x3_c22(sa3x3_c22),
        .sa2x2_c11(sa2x2_c11), .sa2x2_c12(sa2x2_c12), .sa2x2_c21(sa2x2_c21), .sa2x2_c22(sa2x2_c22),
        .digit(digit), .seg(seg), .done(done));
    initial begin clk = 0; forever #10 clk = ~clk; end
    initial begin
        rst_n = 1; start = 0;
        sa3x3_c11 = 54; sa3x3_c12 = 63; sa3x3_c21 = 90; sa3x3_c22 = 99;
        sa2x2_c11 = 54; sa2x2_c12 = 63; sa2x2_c21 = 90; sa2x2_c22 = 99;
        #20 rst_n = 0; #20 rst_n = 1; #20;
        start = 1; #10 start = 0;
        #2000; $finish;
    end
endmodule
