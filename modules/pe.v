// PE: MAC Unit (Multiply-Accumulate)
// Supports Output Stationary (OS) and Weight Stationary (WS) modes

module pe (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clr_acc,
    input  wire        en,
    input  wire        load_b,
    input  wire [7:0]  a_in,
    input  wire [7:0]  b_in,
    input  wire [7:0]  c_in,
    output reg  [7:0]  a_out,
    output reg  [7:0]  b_out,
    output reg  [7:0]  acc_out,
    output wire [7:0]  c_out
);

    wire [7:0] b_mult = load_b ? b_in : b_out;
    wire [7:0] mult_out, add_sum, acc_sum;

    multiplier_8bit u_mult (.a(a_in), .b(b_mult), .product(mult_out));
    adder_8bit u_add_ext (.a(mult_out), .b(c_in), .cin(1'b0), .sum(add_sum), .cout());
    assign c_out = add_sum;
    adder_8bit u_add_acc (.a(mult_out), .b(acc_out), .cin(1'b0), .sum(acc_sum), .cout());

    // Registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 8'd0;
            b_out <= 8'd0;
            acc_out <= 8'd0;
        end
        else if (clr_acc) begin
            a_out <= 8'd0;
            b_out <= 8'd0;
            acc_out <= 8'd0;
        end
        else if (en) begin
            a_out <= a_in;
            if (load_b) b_out <= b_in;
            acc_out <= acc_sum;
        end
    end
endmodule
