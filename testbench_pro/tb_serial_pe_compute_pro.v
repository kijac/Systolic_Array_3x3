//   A = [[2,4,2,3],[4,6,5,3],[3,5,4,2],[2,3,2,1]]
//   B = [[1,3,0],[2,4,2],[7,1,4]]  (After 180° rotation: [[4,1,7],[2,4,2],[0,3,1]])
//   Expected: C11=87, C12=91, C21=102, C22=87

`timescale 1ns/1ps
// TB: Serial PE Compute Module
module tb_serial_pe_compute;
    parameter CLK_PERIOD = 10;
    
    reg clk, rst_n, start;
    wire [3:0] a_addr, b_addr;
    wire [7:0] a_data, b_data, c11, c12, c21, c22;
    wire done;
    wire [15:0] cycle_count;
    
    memory_storage #(
        .INIT_A_0(2),.INIT_A_1(4),.INIT_A_2(2),.INIT_A_3(3),
        .INIT_A_4(4),.INIT_A_5(6),.INIT_A_6(5),.INIT_A_7(3),
        .INIT_A_8(3),.INIT_A_9(5),.INIT_A_10(4),.INIT_A_11(2),
        .INIT_A_12(2),.INIT_A_13(3),.INIT_A_14(2),.INIT_A_15(1),
        .INIT_B_0(1),.INIT_B_1(3),.INIT_B_2(0),
        .INIT_B_3(2),.INIT_B_4(4),.INIT_B_5(2),
        .INIT_B_6(7),.INIT_B_7(1),.INIT_B_8(4)
    ) u_mem (.rd_addr_a(a_addr),.rd_addr_b(b_addr),
             .rd_data_a(a_data),.rd_data_b(b_data));
    
    serial_pe_compute dut (.clk(clk),.rst_n(rst_n),.start(start),
                           .a_data(a_data),.b_data(b_data),
                           .a_addr(a_addr),.b_addr(b_addr),
                           .c11(c11),.c12(c12),.c21(c21),.c22(c22),
                           .done(done),.cycle_count(cycle_count));
    
    initial begin clk=0; forever #(CLK_PERIOD/2) clk=~clk; end
    
    initial begin
        $display("=== Serial PE Compute Testbench ===");
        $display("Expected: C11=87, C12=91, C21=102, C22=87");
        rst_n=1; start=0;
        #CLK_PERIOD; rst_n=0; #(CLK_PERIOD*2); rst_n=1; #(CLK_PERIOD*2);
        
        start=1; #CLK_PERIOD; start=0;
        wait(done==1); #CLK_PERIOD;
        
        $display("Results:");
        $display("  C11=%d %s", c11, (c11==87)?"PASS":"FAIL");
        $display("  C12=%d %s", c12, (c12==91)?"PASS":"FAIL");
        $display("  C21=%d %s", c21, (c21==102)?"PASS":"FAIL");
        $display("  C22=%d %s", c22, (c22==87)?"PASS":"FAIL");
        $display("  Cycles: %d", cycle_count);
        
        #(CLK_PERIOD*5);
        $display("=== Serial PE Test Complete ===");
        $finish;
    end
endmodule
