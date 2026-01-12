// 7-Segment Display Controller - Sequential display of 8 values (1 sec each)
// Display: 3x3(C11,C12,C21,C22) → 2x2(C11,C12,C21,C22), Active-High for FSK3

module display_7seg_fpga #(
    parameter CLK_FREQ     = 100000000,
    parameter SCAN_FREQ    = 1000,
    parameter DISPLAY_TIME = 100000000
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  sa3x3_c11, sa3x3_c12, sa3x3_c21, sa3x3_c22,
    input  wire [7:0]  sa2x2_c11, sa2x2_c12, sa2x2_c21, sa2x2_c22,
    output reg  [7:0]  digit,
    output reg  [6:0]  seg,
    output reg         done
);
    localparam SCAN_DIV = CLK_FREQ / SCAN_FREQ / 8, S_IDLE = 2'd0, S_DISPLAY = 2'd1, S_DONE = 2'd2;

    reg [1:0] state;
    reg [2:0] value_idx, digit_idx;
    reg [26:0] time_cnt;
    reg [16:0] scan_cnt;
    
    // Value MUX: 0-3 = 3x3, 4-7 = 2x2
    wire [7:0] current_val = (value_idx == 3'd0) ? sa3x3_c11 :
                             (value_idx == 3'd1) ? sa3x3_c12 :
                             (value_idx == 3'd2) ? sa3x3_c21 :
                             (value_idx == 3'd3) ? sa3x3_c22 :
                             (value_idx == 3'd4) ? sa2x2_c11 :
                             (value_idx == 3'd5) ? sa2x2_c12 :
                             (value_idx == 3'd6) ? sa2x2_c21 : sa2x2_c22;

    // Digit scan counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin scan_cnt <= 0; digit_idx <= 0; end
        else if (scan_cnt >= SCAN_DIV - 1) begin scan_cnt <= 0; digit_idx <= digit_idx + 1'b1; end
        else scan_cnt <= scan_cnt + 1'b1;
    end

    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state <= S_IDLE; value_idx <= 0; time_cnt <= 0; done <= 0; end
        else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin state <= S_DISPLAY; value_idx <= 0; time_cnt <= 0; end
                end
                S_DISPLAY: begin
                    if (time_cnt >= DISPLAY_TIME - 1) begin
                        time_cnt <= 0;
                        if (value_idx == 3'd7) state <= S_DONE; else value_idx <= value_idx + 1'b1;
                    end
                    else time_cnt <= time_cnt + 1'b1;
                end
                S_DONE: done <= 1;
                default: state <= S_IDLE;
            endcase
        end
    end

    // Binary to BCD (Double Dabble)
    function [11:0] bin_to_bcd;
        input [7:0] bin;
        integer i;
        reg [19:0] temp;
        begin
            temp = {12'd0, bin};
            for (i = 0; i < 8; i = i + 1) begin
                if (temp[11:8] >= 5) temp[11:8] = temp[11:8] + 3;
                if (temp[15:12] >= 5) temp[15:12] = temp[15:12] + 3;
                if (temp[19:16] >= 5) temp[19:16] = temp[19:16] + 3;
                temp = temp << 1;
            end
            bin_to_bcd = temp[19:8];
        end
    endfunction

    // Digit to 7-segment (Active-High, 0-9 only)
    function [6:0] digit_to_seg;
        input [3:0] d;
        case (d)
            4'd0: digit_to_seg = 7'b1111110;  4'd1: digit_to_seg = 7'b0110000;
            4'd2: digit_to_seg = 7'b1101101;  4'd3: digit_to_seg = 7'b1111001;
            4'd4: digit_to_seg = 7'b0110011;  4'd5: digit_to_seg = 7'b1011011;
            4'd6: digit_to_seg = 7'b1011111;  4'd7: digit_to_seg = 7'b1110000;
            4'd8: digit_to_seg = 7'b1111111;  4'd9: digit_to_seg = 7'b1111011;
            default: digit_to_seg = 7'b0000000;
        endcase
    endfunction

    wire [11:0] bcd = bin_to_bcd(current_val);
    wire [3:0] hundreds = bcd[11:8], tens = bcd[7:4], ones = bcd[3:0];

    // Output generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin digit <= 8'b00000001; seg <= 7'b1111111; end
        else if (state == S_IDLE) begin
            // Show "88" pattern during IDLE
            digit <= (digit_idx == 3'd0) ? 8'b00000001 :
                     (digit_idx == 3'd1) ? 8'b00000010 : 8'b00000000;
            seg <= (digit_idx <= 3'd1) ? 7'b1111111 : 7'b0000000;
        end
        else begin
            case (digit_idx)
                3'd2: begin
                    digit <= (hundreds != 0) ? 8'b00000100 : 8'b00000000;
                    seg <= (hundreds != 0) ? digit_to_seg(hundreds) : 7'b0000000;
                end
                3'd1: begin
                    digit <= (hundreds != 0 || tens != 0) ? 8'b00000010 : 8'b00000000;
                    seg <= (hundreds != 0 || tens != 0) ? digit_to_seg(tens) : 7'b0000000;
                end
                3'd0: begin digit <= 8'b00000001; seg <= digit_to_seg(ones); end
                default: begin digit <= 8'b00000000; seg <= 7'b0000000; end
            endcase
        end
    end
endmodule
