// SA 2x2 Controller
// Purpose: FSM and control signal generation for SA 2x2 datapath
// Features:
//   - Memory loading (16 A elements, 9 B elements) in 18 cycles
//   - Sequential computation with diagonal data flow (17 cycles)
//   - Dual result extraction (c_out and acc_out)

module sa_2x2_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  a_data,
    input  wire [7:0]  b_data,
    input  wire [7:0]  pe_c_out_bot_0,
    input  wire [7:0]  pe_c_out_bot_1,
    input  wire [7:0]  pe_acc_bot_0,
    input  wire [7:0]  pe_acc_bot_1, // Not used but kept for consistency
    output reg  [3:0]  a_addr,
    output reg  [3:0]  b_addr,
    output reg  [7:0]  c11, c12, c21, c22,
    output reg         done,
    output reg  [15:0] cycle_count,
    
    // Internal Control Signals to Datapath
    output wire        pe_en,
    output wire        pe_clr,
    output wire        load_b,
    output reg  [7:0]  b_feed_left,
    output reg  [7:0]  b_feed_right,
    output reg  [7:0]  a_feed_top_row,
    output reg  [7:0]  a_feed_bot_row
);

    // FSM States
    localparam ZERO       = 8'd0;
    localparam S_IDLE     = 3'd0;
    localparam S_LOAD_MEM = 3'd1;  // Load A[0:15], B[0:8] from memory
    localparam S_CALC     = 3'd2;  // Sequential computation
    localparam S_DONE     = 3'd3;  // Completion
    
    // Internal Registers
    reg [2:0]  state; 
    reg [4:0]  load_cnt;               // Memory load counter
    reg [4:0]  seq_cnt;                // Sequence counter for diagonal flow
    reg [7:0]  A [0:15];               // Input matrix A (4x4)
    reg [7:0]  B [0:8];                // Filter matrix B (3x3)

    // Control Signal Generation
    assign pe_en  = (state == S_CALC); 
    assign pe_clr = (state == S_IDLE);    // Clear accumulators at IDLE
    assign load_b = 1'b1;                 // Always load B in this design
    
    // B Weight Distribution Logic (Column-wise)
    always @(*) begin
        b_feed_left = ZERO; b_feed_right = ZERO;
        if (state == S_CALC) begin
             case (seq_cnt)
                 5'd0: b_feed_left = B[8]; 5'd1: b_feed_left = B[7]; 5'd2: b_feed_left = B[6];
                 5'd4: b_feed_left = B[5]; 5'd5: b_feed_left = B[4]; 5'd6: b_feed_left = B[3];
                 5'd8: b_feed_left = B[2]; 5'd9: b_feed_left = B[1]; 5'd10: b_feed_left = B[0];
                 default: b_feed_left = ZERO;
             endcase
             case (seq_cnt)
                 5'd2: b_feed_right = B[8]; 5'd3: b_feed_right = B[7]; 5'd4: b_feed_right = B[6];
                 5'd6: b_feed_right = B[5]; 5'd7: b_feed_right = B[4]; 5'd8: b_feed_right = B[3];
                 5'd10: b_feed_right = B[2]; 5'd11: b_feed_right = B[1]; 5'd12: b_feed_right = B[0];
                 default: b_feed_right = ZERO;
             endcase
        end
    end

    // A Input Distribution Logic (Row-wise with Diagonal Shift)
    always @(*) begin
        a_feed_top_row = ZERO; a_feed_bot_row = ZERO;
        if (state == S_CALC) begin
            case (seq_cnt)
                5'd0: a_feed_top_row = A[0]; 5'd1: a_feed_top_row = A[1]; 5'd2: a_feed_top_row = A[2]; 5'd3: a_feed_top_row = A[3];
                5'd4: a_feed_top_row = A[4]; 5'd5: a_feed_top_row = A[5]; 5'd6: a_feed_top_row = A[6]; 5'd7: a_feed_top_row = A[7];
                5'd8: a_feed_top_row = A[8]; 5'd9: a_feed_top_row = A[9]; 5'd10: a_feed_top_row = A[10]; 5'd11: a_feed_top_row = A[11];
                default: a_feed_top_row = ZERO;
            endcase
            case (seq_cnt)
                5'd1: a_feed_bot_row = A[4]; 5'd2: a_feed_bot_row = A[5]; 5'd3: a_feed_bot_row = A[6]; 5'd4: a_feed_bot_row = A[7];
                5'd5: a_feed_bot_row = A[8]; 5'd6: a_feed_bot_row = A[9]; 5'd7: a_feed_bot_row = A[10]; 5'd8: a_feed_bot_row = A[11];
                5'd9: a_feed_bot_row = A[12]; 5'd10: a_feed_bot_row = A[13]; 5'd11: a_feed_bot_row = A[14]; 5'd12: a_feed_bot_row = A[15];
                default: a_feed_bot_row = ZERO;
            endcase
        end 
    end
    
    // Main FSM (Finite State Machine)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            done <= 0;
            cycle_count <= 0; load_cnt <= 0; seq_cnt <= 0;
            a_addr <= 0; b_addr <= 0;
            c11 <= 0; c12 <= 0; c21 <= 0; c22 <= 0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= S_LOAD_MEM;
                        cycle_count <= 1; load_cnt <= 0;
                    end
                end
                
                S_LOAD_MEM: begin
                    cycle_count <= cycle_count + 1;
                    if (load_cnt > 0) begin
                        if (load_cnt <= 16) A[load_cnt-1] <= a_data;
                        if (load_cnt <= 9)  B[load_cnt-1] <= b_data;
                    end
                    if (load_cnt < 16) a_addr <= load_cnt[3:0];
                    if (load_cnt < 9)  b_addr <= load_cnt[3:0];
                    load_cnt <= load_cnt + 1;
                    
                    if (load_cnt == 17) begin
                        state <= S_CALC; 
                        seq_cnt <= 0;
                    end
                end

                S_CALC: begin 
                    cycle_count <= cycle_count + 1;
                    if (seq_cnt == 16) begin
                        state <= S_DONE;
                        // In SA 2x2, results are collected differently
                        // c11, c12 come from COMBINATIONAL port (c_out) of bottom PEs
                        // c21, c22 come from ACCUMULATOR port (acc_out) of bottom PEs
                        // Logic copied from original code:
                        c11 <= pe_c_out_bot_0; c12 <= pe_c_out_bot_1;
                        c21 <= pe_acc_bot_0;   c22 <= pe_acc_bot_1;
                    end else seq_cnt <= seq_cnt + 1;
                end
                
                S_DONE: begin
                    done <= 1;
                end
            endcase
        end
    end
endmodule
