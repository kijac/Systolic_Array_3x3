`timescale 1ns/1ns

// Memory Storage: A (4x4) and B (3x3) matrices
// Test Data (Asymmetric filter for 180° rotation verification):
//   A = [[2,4,2,3],[4,6,5,3],[3,5,4,2],[2,3,2,1]]
//   B = [[1,3,0],[2,4,2],[7,1,4]]  (After 180° rotation: [[4,1,7],[2,4,2],[0,3,1]])
//   Expected: C11=87, C12=91, C21=102, C22=87

module memory_storage #(
    // ====== A matrix (4x4) - Values can be modified ======
    parameter [7:0] INIT_A_0=2,   INIT_A_1=4,   INIT_A_2=2,   INIT_A_3=3,
    parameter [7:0] INIT_A_4=4,   INIT_A_5=6,   INIT_A_6=5,   INIT_A_7=3,
    parameter [7:0] INIT_A_8=3,   INIT_A_9=5,   INIT_A_10=4,  INIT_A_11=2,
    parameter [7:0] INIT_A_12=2,  INIT_A_13=3,  INIT_A_14=2,  INIT_A_15=1,
    // ====== B filter (3x3) - Values can be modified ======
    parameter [7:0] INIT_B_0=1, INIT_B_1=3, INIT_B_2=0,
    parameter [7:0] INIT_B_3=2, INIT_B_4=4, INIT_B_5=2,
    parameter [7:0] INIT_B_6=7, INIT_B_7=1, INIT_B_8=4
)(
    input  wire [3:0]  rd_addr_a,
    input  wire [3:0]  rd_addr_b,
    output wire [7:0]  rd_data_a,
    output wire [7:0]  rd_data_b
);
    reg [7:0] mem_a [0:15];
    reg [7:0] mem_b [0:8];

    // Initialize memory with parameters
    initial begin
        mem_a[0]=INIT_A_0;  mem_a[1]=INIT_A_1;  mem_a[2]=INIT_A_2;  mem_a[3]=INIT_A_3;
        mem_a[4]=INIT_A_4;  mem_a[5]=INIT_A_5;  mem_a[6]=INIT_A_6;  mem_a[7]=INIT_A_7;
        mem_a[8]=INIT_A_8;  mem_a[9]=INIT_A_9;  mem_a[10]=INIT_A_10;mem_a[11]=INIT_A_11;
        mem_a[12]=INIT_A_12;mem_a[13]=INIT_A_13;mem_a[14]=INIT_A_14;mem_a[15]=INIT_A_15;
        mem_b[0]=INIT_B_0; mem_b[1]=INIT_B_1; mem_b[2]=INIT_B_2;
        mem_b[3]=INIT_B_3; mem_b[4]=INIT_B_4; mem_b[5]=INIT_B_5;
        mem_b[6]=INIT_B_6; mem_b[7]=INIT_B_7; mem_b[8]=INIT_B_8;
    end

    // Read-only access
    assign rd_data_a = mem_a[rd_addr_a];
    assign rd_data_b = (rd_addr_b <= 4'd8) ? mem_b[rd_addr_b] : 8'd0;
endmodule
