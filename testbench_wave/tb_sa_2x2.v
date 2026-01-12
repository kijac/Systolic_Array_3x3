`timescale 1ns/1ns
// SA 2x2 TB: PE signals exposed for waveform (C11=87, C12=91, C21=102, C22=87)
module tb_sa_2x2;
    reg clk, rst_n, start;
    wire [3:0] a_addr, b_addr;
    wire [7:0] a_data, b_data, c11, c12, c21, c22;
    wire done;
    wire [15:0] cycle_count;
    // PE Top row signals
    wire [7:0] PE0_a_in, PE0_b_in, PE0_b_out, PE0_acc_out;
    wire [7:0] PE1_a_in, PE1_b_in, PE1_b_out, PE1_acc_out;
    // PE Bottom row signals
    wire [7:0] PE2_a_in, PE2_b_in, PE2_b_out, PE2_acc_out, PE2_c_out;
    wire [7:0] PE3_a_in, PE3_b_in, PE3_b_out, PE3_acc_out, PE3_c_out;
    
    memory_storage #(.INIT_A_0(2),.INIT_A_1(4),.INIT_A_2(2),.INIT_A_3(3),
        .INIT_A_4(4),.INIT_A_5(6),.INIT_A_6(5),.INIT_A_7(3),
        .INIT_A_8(3),.INIT_A_9(5),.INIT_A_10(4),.INIT_A_11(2),
        .INIT_A_12(2),.INIT_A_13(3),.INIT_A_14(2),.INIT_A_15(1),
        .INIT_B_0(1),.INIT_B_1(3),.INIT_B_2(0),.INIT_B_3(2),.INIT_B_4(4),
        .INIT_B_5(2),.INIT_B_6(7),.INIT_B_7(1),.INIT_B_8(4)
    ) u_mem (.rd_addr_a(a_addr), .rd_addr_b(b_addr), .rd_data_a(a_data), .rd_data_b(b_data));
    sa_2x2 uut (.clk(clk), .rst_n(rst_n), .start(start), .a_data(a_data), .b_data(b_data),
        .a_addr(a_addr), .b_addr(b_addr), .c11(c11), .c12(c12), .c21(c21), .c22(c22),
        .done(done), .cycle_count(cycle_count));
    
    // Expose PE internal signals for waveform viewing
    assign PE0_a_in = uut.PE0.a_in; assign PE0_b_in = uut.PE0.b_in; 
    assign PE0_b_out = uut.PE0.b_out; assign PE0_acc_out = uut.pe_acc_top[0]; 
    assign PE1_a_in = uut.PE1.a_in; assign PE1_b_in = uut.PE1.b_in; 
    assign PE1_b_out = uut.PE1.b_out; assign PE1_acc_out = uut.pe_acc_top[1];
    assign PE2_a_in = uut.PE2.a_in; assign PE2_b_in = uut.PE2.b_in; 
    assign PE2_b_out = uut.PE2.b_out; assign PE2_acc_out = uut.pe_acc_bot[0]; 
    assign PE2_c_out = uut.pe_c_out_bot[0];assign PE3_a_in = uut.PE3.a_in; 
    assign PE3_b_in = uut.PE3.b_in; assign PE3_b_out = uut.PE3.b_out; 
    assign PE3_acc_out = uut.pe_acc_bot[1]; assign PE3_c_out = uut.pe_c_out_bot[1];
    
    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin
        rst_n = 0; start = 0; #20 rst_n = 1;
        #10 start = 1; #10 start = 0;
        wait(done == 1); #100; $finish;  // ~36 cycles
    end
endmodule
