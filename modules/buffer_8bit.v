// buffer_8bit: 8-bit Register Buffer (Behavioral Model)
// Purpose: Single-cycle delay element for pipeline stages
// Use case: Skew correction, pipeline registers

module buffer_8bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [7:0]  data_in,
    output reg  [7:0]  data_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 8'd0;
        else if (en)
            data_out <= data_in;
    end

endmodule
