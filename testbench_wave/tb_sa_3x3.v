`timescale 1ns/1ns
// SA 3x3 TB: PE signals exposed for waveform (C11=87, C12=91, C21=102, C22=87)
module tb_sa_3x3;
    reg clk, rst_n, start;
    wire [3:0] a_addr, b_addr;
    wire [7:0] a_data, b_data, c11, c12, c21, c22;
    wire done;
    wire [15:0] cycle_count;
    // PE Row 0 (Top row)
    wire [7:0] PE0_a_in, PE0_b_in, PE0_b_out;
    wire [7:0] PE1_a_in, PE1_b_in, PE1_b_out;
    wire [7:0] PE2_a_in, PE2_b_in, PE2_b_out;
    // PE Row 1 (Middle row)
    wire [7:0] PE3_a_in, PE3_b_in, PE3_b_out;
    wire [7:0] PE4_a_in, PE4_b_in, PE4_b_out;
    wire [7:0] PE5_a_in, PE5_b_in, PE5_b_out;
    // PE Row 2 (Bottom row - final outputs)
    wire [7:0] PE6_a_in, PE6_b_in, PE6_b_out, PE6_c_out;
    wire [7:0] PE7_a_in, PE7_b_in, PE7_b_out, PE7_c_out;
    wire [7:0] PE8_a_in, PE8_b_in, PE8_b_out, PE8_c_out;
    
    memory_storage #(.INIT_A_0(2),.INIT_A_1(4),.INIT_A_2(2),.INIT_A_3(3),
        .INIT_A_4(4),.INIT_A_5(6),.INIT_A_6(5),.INIT_A_7(3),
        .INIT_A_8(3),.INIT_A_9(5),.INIT_A_10(4),.INIT_A_11(2),
        .INIT_A_12(2),.INIT_A_13(3),.INIT_A_14(2),.INIT_A_15(1),
        .INIT_B_0(1),.INIT_B_1(3),.INIT_B_2(0),.INIT_B_3(2),.INIT_B_4(4),
        .INIT_B_5(2),.INIT_B_6(7),.INIT_B_7(1),.INIT_B_8(4)
    ) u_mem (.rd_addr_a(a_addr), .rd_addr_b(b_addr),
        .rd_data_a(a_data), .rd_data_b(b_data));
    
    sa_3x3 uut (.clk(clk), .rst_n(rst_n), .start(start),
        .a_data(a_data), .b_data(b_data),
        .a_addr(a_addr), .b_addr(b_addr),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22),
        .done(done), .cycle_count(cycle_count));

    assign PE0_a_in = uut.PE0.a_in; assign PE0_b_in = uut.PE0.b_in; 
    assign PE0_b_out = uut.PE0.b_out; assign PE1_a_in = uut.PE1.a_in; 
    assign PE1_b_in = uut.PE1.b_in; assign PE1_b_out = uut.PE1.b_out;
    assign PE2_a_in = uut.PE2.a_in; assign PE2_b_in = uut.PE2.b_in; 
    assign PE2_b_out = uut.PE2.b_out; assign PE3_a_in = uut.PE3.a_in; 
    assign PE3_b_in = uut.PE3.b_in; assign PE3_b_out = uut.PE3.b_out;
    assign PE4_a_in = uut.PE4.a_in; assign PE4_b_in = uut.PE4.b_in; 
    assign PE4_b_out = uut.PE4.b_out; assign PE5_a_in = uut.PE5.a_in; 
    assign PE5_b_in = uut.PE5.b_in; assign PE5_b_out = uut.PE5.b_out;
    assign PE6_a_in = uut.PE6.a_in; assign PE6_b_in = uut.PE6.b_in; 
    assign PE6_b_out = uut.PE6.b_out; assign PE6_c_out = uut.c_out_row2[0]; 
    assign PE7_a_in = uut.PE7.a_in; assign PE7_b_in = uut.PE7.b_in; 
    assign PE7_b_out = uut.PE7.b_out; assign PE7_c_out = uut.c_out_row2[1];
    assign PE8_a_in = uut.PE8.a_in; assign PE8_b_in = uut.PE8.b_in; 
    assign PE8_b_out = uut.PE8.b_out; assign PE8_c_out = uut.c_out_row2[2];
    
    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin rst_n = 0; start = 0; #20 rst_n = 1; #10 start = 1; #10 start = 0; 
    wait(done == 1); #100; $finish; end
    
endmodule
