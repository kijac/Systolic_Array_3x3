`timescale 1ns/1ps
// TB: Memory Storage Module (Read-Only)
module tb_memory;
    parameter CLK_PERIOD = 10;
    
    reg [3:0] rd_addr_a, rd_addr_b;
    wire [7:0] rd_data_a, rd_data_b;
    integer i;
    
    memory_storage #(
        .INIT_A_0(1),.INIT_A_1(2),.INIT_A_2(3),.INIT_A_3(4),
        .INIT_A_4(5),.INIT_A_5(6),.INIT_A_6(7),.INIT_A_7(8),
        .INIT_A_8(9),.INIT_A_9(10),.INIT_A_10(11),.INIT_A_11(12),
        .INIT_A_12(13),.INIT_A_13(14),.INIT_A_14(15),.INIT_A_15(16),
        .INIT_B_0(1),.INIT_B_1(2),.INIT_B_2(3),
        .INIT_B_3(4),.INIT_B_4(5),.INIT_B_5(6),
        .INIT_B_6(7),.INIT_B_7(8),.INIT_B_8(9)
    ) dut (
        .rd_addr_a(rd_addr_a),.rd_addr_b(rd_addr_b),
        .rd_data_a(rd_data_a),.rd_data_b(rd_data_b)
    );
    
    initial begin
        $display("=== Memory Testbench (Read-Only) ===");
        rd_addr_a=0; rd_addr_b=0;
        
        // Test 1: Read A matrix (first 8 values)
        $display("Test 1: Read A Matrix");
        #CLK_PERIOD;
        for(i=0;i<8;i=i+1) begin rd_addr_a=i; #1; $display("  A[%0d]=%d (exp %0d)",i,rd_data_a,i+1); end
        
        // Test 2: Read B matrix (all 9 values)
        $display("Test 2: Read B Matrix");
        #CLK_PERIOD;
        for(i=0;i<9;i=i+1) begin rd_addr_b=i; #1; $display("  B[%0d]=%d (exp %0d)",i,rd_data_b,i+1); end
        
        // Test 3: Read A matrix (last 8 values)
        $display("Test 3: Read A Matrix (continued)");
        #CLK_PERIOD;
        for(i=8;i<16;i=i+1) begin rd_addr_a=i; #1; $display("  A[%0d]=%d (exp %0d)",i,rd_data_a,i+1); end
        
        #(CLK_PERIOD*2);
        $display("=== Memory Test Complete ===");
        $finish;
    end
endmodule
