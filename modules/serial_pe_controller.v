// Serial PE Controller: FSM for Single PE Convolution
// Handles memory addressing and PE control signals
// Distributed Control Architecture

module serial_pe_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    output reg  [3:0]  a_addr,
    output reg  [3:0]  b_addr,
    output wire        pe_clr,      // Clear PE accumulator
    output wire        pe_en,       // Enable PE accumulation
    output wire        save_en,     // Save result to Cxx register
    output reg  [1:0]  out_idx,     // Index for result register (0..3)
    output reg         done,
    output reg  [15:0] cycle_count
);

    // FSM States
    localparam S_IDLE  = 3'd0;
    localparam S_LOAD  = 3'd1;  // Load A/B addresses
    localparam S_MAC   = 3'd2;  // Execute MAC
    localparam S_STORE = 3'd3;  // Store result
    localparam S_DONE  = 3'd4;
    
    reg [2:0] state;
    reg [3:0] mac_cnt;  // MAC counter (0-8)

    // Window base address calc
    wire [3:0] a_base = (out_idx==2'd0) ? 4'd0 : (out_idx==2'd1) ? 4'd1 :
                        (out_idx==2'd2) ? 4'd4 : 4'd5;

    // Control Signals (Combinational)
    assign pe_en   = (state == S_MAC);
    assign save_en = (state == S_STORE);
    assign pe_clr  = (state == S_IDLE && start) || (state == S_STORE && out_idx != 2'd3);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            out_idx <= 2'd0;
            mac_cnt <= 4'd0;
            a_addr <= 4'd0;
            b_addr <= 4'd0;
            done <= 1'b0;
            cycle_count <= 16'd0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= S_LOAD;
                        out_idx <= 2'd0;
                        mac_cnt <= 4'd0;
                        cycle_count <= 16'd1;
                        // Initial Address Setup for first pixel
                        a_addr <= 4'd0; 
                        b_addr <= 4'd8; // Start from B[8]
                    end
                end

                S_LOAD: begin
                    state <= S_MAC;
                    cycle_count <= cycle_count + 16'd1;
                    // Addresses are already set in S_IDLE or previous S_MAC/S_STORE
                end

                S_MAC: begin
                    cycle_count <= cycle_count + 16'd1;
                    // pe_en handled combinationally

                    if (mac_cnt == 4'd8) begin
                        state <= S_STORE;
                    end
                    else begin
                        mac_cnt <= mac_cnt + 4'd1;
                        state <= S_LOAD;
                        
                        // Calculate next address
                        case (mac_cnt + 4'd1)
                            4'd1: begin a_addr <= a_base + 4'd1;  b_addr <= 4'd7; end
                            4'd2: begin a_addr <= a_base + 4'd2;  b_addr <= 4'd6; end
                            4'd3: begin a_addr <= a_base + 4'd4;  b_addr <= 4'd5; end
                            4'd4: begin a_addr <= a_base + 4'd5;  b_addr <= 4'd4; end
                            4'd5: begin a_addr <= a_base + 4'd6;  b_addr <= 4'd3; end
                            4'd6: begin a_addr <= a_base + 4'd8;  b_addr <= 4'd2; end
                            4'd7: begin a_addr <= a_base + 4'd9;  b_addr <= 4'd1; end
                            4'd8: begin a_addr <= a_base + 4'd10; b_addr <= 4'd0; end
                            default: begin a_addr <= a_base; b_addr <= 4'd8; end
                        endcase
                    end
                end

                S_STORE: begin
                    cycle_count <= cycle_count + 16'd1;
                    // save_en, pe_clr handled combinationally

                    if (out_idx == 2'd3) begin
                        state <= S_DONE;
                    end
                    else begin
                        out_idx <= out_idx + 2'd1;
                        mac_cnt <= 4'd0;
                        state <= S_LOAD;
                        
                        // Setup addresses for next window's first pixel
                        case (out_idx + 2'd1)
                            2'd1: a_addr <= 4'd1;
                            2'd2: a_addr <= 4'd4;
                            2'd3: a_addr <= 4'd5;
                            default: a_addr <= 4'd0;
                        endcase
                        b_addr <= 4'd8;
                    end
                end

                S_DONE: begin
                    done <= 1'b1;
                    state <= S_IDLE;
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

