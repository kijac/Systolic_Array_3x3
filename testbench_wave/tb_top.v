`timescale 1ns/1ns
// Top TB: Full system (Auto-start, 3 modes, Display) - Expected: C11=87, C12=91, C21=102, C22=87
module tb_top;
    reg clk, rst_n;
    wire [7:0] digit, seg;
    top_fpga uut (.clk_100m(clk), .sys_rstb(rst_n), .digit(digit), .seg(seg[6:0]));
    defparam uut.u_display.DISPLAY_TIME = 100, uut.u_display.SCAN_DIV = 10;
    wire [7:0] serial_c11 = uut.serial_c11, serial_c12 = uut.serial_c12, serial_c21 = uut.serial_c21, serial_c22 = uut.serial_c22;
    wire [7:0] sa3x3_c11 = uut.sa3x3_c11, sa3x3_c12 = uut.sa3x3_c12, sa3x3_c21 = uut.sa3x3_c21, sa3x3_c22 = uut.sa3x3_c22;
    wire [7:0] sa2x2_c11 = uut.sa2x2_c11, sa2x2_c12 = uut.sa2x2_c12, sa2x2_c21 = uut.sa2x2_c21, sa2x2_c22 = uut.sa2x2_c22;
    wire all_done = uut.all_done;
    wire [1:0] mode = uut.mode;
    wire [2:0] ctrl_state = uut.u_ctrl.state;
    initial begin clk = 0; forever #0.5 clk = ~clk; end
    initial begin
        rst_n = 0; #50 rst_n = 1;
        force uut.u_ctrl.auto_cnt = 24'd999990; #100; release uut.u_ctrl.auto_cnt;
        wait(all_done == 1); #1000; $finish;
    end
endmodule
