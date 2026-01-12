// Serial PE Compute: 2D Convolution using single PE (36 MACs total)
// Structural Model with Distributed Control

module serial_pe_compute (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  a_data,
    input  wire [7:0]  b_data,
    output wire [3:0]  a_addr,
    output wire [3:0]  b_addr,
    output reg  [7:0]  c11, c12, c21, c22,
    output wire        done,
    output wire [15:0] cycle_count
);

    // Internal Signals
    wire        pe_clr;
    wire        pe_en;
    wire        save_en;
    wire [1:0]  out_idx;
    wire [7:0]  pe_acc_out;

    // 1. Controller Instance
    serial_pe_controller u_ctrl (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start),
        .a_addr(a_addr), 
        .b_addr(b_addr),
        .pe_clr(pe_clr),
        .pe_en(pe_en),
        .save_en(save_en),
        .out_idx(out_idx),
        .done(done),
        .cycle_count(cycle_count)
    );

    // 2. Processing Element (PE) Instance
    pe u_pe (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(pe_clr),
        .en(pe_en),
        .load_b(1'b1),      // Serial mode: Always load new B weight
        .a_in(a_data),
        .b_in(b_data),
        .c_in(8'd0),        
        .a_out(),           
        .b_out(),           
        .acc_out(pe_acc_out),
        .c_out()            
    );

    // 3. Output Result Registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c11 <= 8'd0; 
            c12 <= 8'd0; 
            c21 <= 8'd0; 
            c22 <= 8'd0;
        end
        else if (save_en) begin
            case (out_idx)
                2'd0: c11 <= pe_acc_out;
                2'd1: c12 <= pe_acc_out;
                2'd2: c21 <= pe_acc_out;
                2'd3: c22 <= pe_acc_out;
            endcase
        end
    end

endmodule
