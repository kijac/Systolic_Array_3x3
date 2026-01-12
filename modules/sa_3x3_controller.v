// SA 3x3 Controller
// Purpose: FSM and control signal generation for SA 3x3 datapath
// Features:
//   - Memory loading (16 A elements, 9 B elements) in 16 cycles
//   - Weight distribution to PE array (3 cycles)
//   - Computation control (8 cycles)
//   - Result capture from bottom row

module sa_3x3_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  a_data,
    input  wire [7:0]  b_data,
    input  wire [7:0]  total_sum,
    output reg  [3:0]  a_addr,
    output reg  [3:0]  b_addr,
    output reg  [7:0]  c11, c12, c21, c22,
    output reg         done,
    output reg  [15:0] cycle_count,
    
    // Internal Control Signals to Datapath
    output wire        pe_en,
    output wire        load_b,
    output reg  [7:0]  a_to_array_0,
    output reg  [7:0]  a_to_array_1,
    output reg  [7:0]  a_to_array_2,
    output reg  [7:0]  b_feed_0,
    output reg  [7:0]  b_feed_1,
    output reg  [7:0]  b_feed_2
);

    // FSM States
    localparam ZERO         = 8'd0;
    localparam S_IDLE       = 3'd0;
    localparam S_LOAD       = 3'd1;  // Load A[0:15], B[0:8] from memory
    localparam S_LOAD_WEIGHT= 3'd2;  // Distribute B to PE array
    localparam S_COMP       = 3'd3;  // Computation phase
    localparam S_DONE       = 3'd4;  // Completion
    
    // Internal Registers
    reg [2:0]  state;
    reg [4:0]  load_cnt;                // Memory load counter
    reg [7:0]  A [0:15];                // Input matrix A (4x4)
    reg [7:0]  B [0:8];                 // Filter matrix B (3x3)
    reg [3:0]  comp_step;               // Computation step counter
    reg [2:0]  weight_step;             // Weight distribution step

    // Control Signal Generation
    assign pe_en  = (state == S_LOAD_WEIGHT || state == S_COMP);
    assign load_b = (state == S_LOAD_WEIGHT);

    // B Weight Distribution Logic (Vertical Shift)
    always @(*) begin
        if (state == S_LOAD_WEIGHT) begin
            case (weight_step)
                3'd0: begin b_feed_0=B[2]; b_feed_1=B[1]; b_feed_2=B[0]; end
                3'd1: begin b_feed_0=B[5]; b_feed_1=B[4]; b_feed_2=B[3]; end
                3'd2: begin b_feed_0=B[8]; b_feed_1=B[7]; b_feed_2=B[6]; end
                default: begin b_feed_0=ZERO; b_feed_1=ZERO; b_feed_2=ZERO; end
            endcase
         end else begin
            b_feed_0=ZERO; b_feed_1=ZERO; b_feed_2=ZERO;
         end
    end

    // A Input Distribution Logic (Horizontal Flow - Wavefront)
    wire [3:0] feed_row0_idx = comp_step;           
    wire [3:0] feed_row1_idx = comp_step - 4'd1 + 4'd4; // 1 cycle delay
    wire [3:0] feed_row2_idx = comp_step - 4'd2 + 4'd8; // 2 cycle delay
    
    always @(*) begin
        if (state == S_LOAD_WEIGHT) begin
            a_to_array_0 = ZERO;
            a_to_array_1 = ZERO;
            a_to_array_2 = ZERO;
        end else begin
            a_to_array_0 = A[feed_row0_idx[3:0]];
            a_to_array_1 = (comp_step < 4'd1) ? ZERO : A[feed_row1_idx[3:0]];
            a_to_array_2 = (comp_step < 4'd2) ? ZERO : A[feed_row2_idx[3:0]];
        end
    end

    // Main FSM (Finite State Machine)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            done <= 0;
            cycle_count <= 0;
            load_cnt <= 0;
            a_addr <= 0;
            b_addr <= 0;
            c11 <= 0; c12 <= 0; c21 <= 0; c22 <= 0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= S_LOAD;
                        cycle_count <= 1;
                        load_cnt <= 0;
                        a_addr <= 0;
                        b_addr <= 0;
                        weight_step <= 0;
                    end
                end
                
                S_LOAD: begin
                    cycle_count <= cycle_count + 1;
                    
                    // Optimized Loading
                    A[load_cnt] <= a_data;
                    if (load_cnt < 9) B[load_cnt] <= b_data;
                    
                    if (load_cnt < 15) begin
                        a_addr <= load_cnt[3:0] + 4'd1;
                        if (load_cnt < 8) b_addr <= load_cnt[3:0] + 4'd1;
                        load_cnt <= load_cnt + 1;
                    end else begin
                        state <= S_LOAD_WEIGHT; // Loading done
                        weight_step <= 0;
                    end
                end

                S_LOAD_WEIGHT: begin
                    cycle_count <= cycle_count + 1;
                    if (weight_step == 2) begin state <= S_COMP; comp_step <= 0; end
                    else weight_step <= weight_step + 1;
                end
                
                S_COMP: begin
                    cycle_count <= cycle_count + 1;
                    // Wavefront Latency: +2 cycles (vertical) + 4 cycles (Col 2 skew) = 6 cycles total validity delay
                    // C11 Valid @ comp_step 6
                    // C12 Valid @ comp_step 7
                    // C21 Valid @ comp_step 10
                    // C22 Valid @ comp_step 11
                    case (comp_step)
                        4'd6: c11 <= total_sum; 4'd7: c12 <= total_sum;
                        4'd10: c21 <= total_sum; 4'd11: c22 <= total_sum;
                    endcase
                    if (comp_step == 4'd11) state <= S_DONE;
                    else comp_step <= comp_step + 1;
                end
                
                S_DONE: begin
                    done <= 1;
                end
            endcase
        end
    end
endmodule
