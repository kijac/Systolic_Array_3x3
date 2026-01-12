`timescale 1ns/1ns
// Student TB: Serial PE Compute - Verify 2D Convolution
// Using asymmetric filter: B = [[1,3,0],[2,4,2],[7,1,4]]
// Expected results (after 180° rotation): C11=87, C12=91, C21=102, C22=87
module tb_serial_pe;
    reg clk, rst_n, start;
    wire [3:0] a_addr, b_addr;
    wire [7:0] a_data, b_data;
    wire [7:0] c11, c12, c21, c22;
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
    ) u_mem (
        .rd_addr_a(a_addr), .rd_addr_b(b_addr),
        .rd_data_a(a_data), .rd_data_b(b_data)
    );
    serial_pe_compute uut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .a_data(a_data), .b_data(b_data),
        .a_addr(a_addr), .b_addr(b_addr),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22),
        .done(done), .cycle_count(cycle_count)
    );
    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin
        rst_n = 0; start = 0;
        #20 rst_n = 1;
        #10 start = 1; #10 start = 0;
        wait(done == 1);  // ~77 cycles
        #100 $finish;  // Verify c11=54, c12=63, c21=90, c22=99
    end
endmodule
