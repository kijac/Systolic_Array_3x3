// Module: controller_fsm_fpga
// Description: FPGA Controller FSM with auto-start and simplified flow
//              Runs all three compute modes, then holds results for display
// Execution Flow:
//   IDLE → (auto-start) → SERIAL → SA3x3 → SA2x2 → DONE (hold)

module controller_fsm_fpga #(
    parameter AUTO_START_DELAY = 24'd1000000  // ~10ms at 100MHz
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        serial_done,
    input  wire        sa3x3_done,
    input  wire        sa2x2_done,
    output reg         serial_start,
    output reg         sa3x3_start,
    output reg         sa2x2_start,
    output reg         display_start,
    output reg  [1:0]  mode,
    output reg         all_done
);

    // State encoding
    localparam [2:0] S_IDLE=3'd0, S_AUTO=3'd1, S_SERIAL=3'd2, S_SA3X3=3'd3, S_SA2X2=3'd4, S_DONE=3'd5;
    localparam [1:0] MODE_IDLE=2'b00, MODE_SERIAL=2'b01, MODE_3X3=2'b10, MODE_2X2=2'b11;
    
    reg [2:0]  state;
    reg [23:0] auto_cnt;
    
    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; auto_cnt <= 0;
            serial_start <= 0; sa3x3_start <= 0; sa2x2_start <= 0; display_start <= 0;
            mode <= MODE_IDLE; all_done <= 0;
        end
        else begin
            // Default: deassert start pulses
            serial_start <= 0; sa3x3_start <= 0; sa2x2_start <= 0; display_start <= 0;
            
            case (state)
                S_IDLE: begin auto_cnt <= 0; all_done <= 0; state <= S_AUTO; end
                S_AUTO: begin
                    if (auto_cnt >= AUTO_START_DELAY - 1) begin
                        serial_start <= 1; mode <= MODE_SERIAL; state <= S_SERIAL;
                    end
                    else auto_cnt <= auto_cnt + 1'b1;
                end
                
                S_SERIAL: if (serial_done) begin sa3x3_start <= 1; mode <= MODE_3X3; state <= S_SA3X3; end
                S_SA3X3: if (sa3x3_done) begin sa2x2_start <= 1; mode <= MODE_2X2; state <= S_SA2X2; end
                S_SA2X2: if (sa2x2_done) begin display_start <= 1; all_done <= 1; state <= S_DONE; end
                S_DONE: begin end  // Hold state - display shows results continuously
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
