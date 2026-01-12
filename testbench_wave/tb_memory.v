`timescale 1ns/1ns
// Student TB: Memory Storage - Verify read operations with waveform
module tb_memory;
    reg [3:0] rd_addr_a, rd_addr_b;
    wire [7:0] rd_data_a, rd_data_b;
    
    memory_storage #(
        .INIT_A_0(1),.INIT_A_1(2),.INIT_A_2(3),.INIT_A_3(4),
        .INIT_A_4(5),.INIT_A_5(6),.INIT_A_6(7),.INIT_A_7(8),
        .INIT_A_8(9),.INIT_A_9(10),.INIT_A_10(11),.INIT_A_11(12),
        .INIT_A_12(13),.INIT_A_13(14),.INIT_A_14(15),.INIT_A_15(16),
        .INIT_B_0(1),.INIT_B_1(2),.INIT_B_2(3),
        .INIT_B_3(4),.INIT_B_4(5),.INIT_B_5(6),
        .INIT_B_6(7),.INIT_B_7(8),.INIT_B_8(9)
    ) uut (
        .rd_addr_a(rd_addr_a), .rd_addr_b(rd_addr_b),
        .rd_data_a(rd_data_a), .rd_data_b(rd_data_b)
    );
    
    initial begin
        rd_addr_a = 0; rd_addr_b = 0;
        #10;
        // A memory: verify rd_data_a = 1,2,3,4
        #10 rd_addr_a = 0;  // expect 1
        #10 rd_addr_a = 1;  // expect 2 
        #10 rd_addr_a = 2;  // expect 3
        #10 rd_addr_a = 3;  // expect 4
        // B memory: verify rd_data_b = 1,2,3
        #10 rd_addr_b = 0;  // expect 1
        #10 rd_addr_b = 1;  // expect 2
        #10 rd_addr_b = 2;  // expect 3
        #20 $finish;
    end
endmodule
