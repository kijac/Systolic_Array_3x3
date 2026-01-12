// SA 3x3: Systolic Array with Vertical Accumulation (Structural Model)
// Architecture: 3x3 PE Grid with Vertical Chaining
// Control: Distributed - FSM logic in sa_3x3_controller
// Datapath: Pure structural interconnection of PE instances
// Results: Extracted from bottom row (PE6 + PE7 + PE8)

module sa_3x3 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  a_data,
    input  wire [7:0]  b_data,
    output wire [3:0]  a_addr,
    output wire [3:0]  b_addr,
    output wire [7:0]  c11, c12, c21, c22,
    output wire        done,
    output wire [15:0] cycle_count
);
    // Constants
    localparam ZERO = 8'd0;

    // Interconnect Signals
    wire        pe_en, load_b;
    wire [7:0]  b_feed [0:2];           // B data feeds to top row
    wire [7:0]  a_val [0:2];            // A data feeds to each row
    wire [7:0]  total_sum;              // Final summed result
    
    // Wavefront Pipeline Registers (Vertical Delay)
    reg [7:0]   pipe_row0_to_1 [0:2];   // Delay between Row0 and Row1
    reg [7:0]   pipe_row1_to_2 [0:2];   // Delay between Row1 and Row2

    // Forward declaration of wires used in the always block
    wire [7:0]  c_out_row0 [0:2];       // Row 0 outputs
    wire [7:0]  c_out_row1 [0:2];       // Row 1 outputs

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pipe_row0_to_1[0] <= ZERO; pipe_row0_to_1[1] <= ZERO; pipe_row0_to_1[2] <= ZERO;
            pipe_row1_to_2[0] <= ZERO; pipe_row1_to_2[1] <= ZERO; pipe_row1_to_2[2] <= ZERO;
        end else if (pe_en) begin
            pipe_row0_to_1[0] <= c_out_row0[0];
            pipe_row0_to_1[1] <= c_out_row0[1];
            pipe_row0_to_1[2] <= c_out_row0[2];
            
            pipe_row1_to_2[0] <= c_out_row1[0];
            pipe_row1_to_2[1] <= c_out_row1[1];
            pipe_row1_to_2[2] <= c_out_row1[2];
        end
    end
    
    // 1. Controller Instance (FSM & Memory Management)
    sa_3x3_controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a_data(a_data),
        .b_data(b_data),
        .total_sum(total_sum),
        .a_addr(a_addr),
        .b_addr(b_addr),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22),
        .done(done),
        .cycle_count(cycle_count),
        // To Datapath
        .pe_en(pe_en),
        .load_b(load_b),
        .a_to_array_0(a_val[0]), .a_to_array_1(a_val[1]), .a_to_array_2(a_val[2]),
        .b_feed_0(b_feed[0]), .b_feed_1(b_feed[1]), .b_feed_2(b_feed[2])
    );

    // 2. Datapath (Systolic Array Structure)
    wire [7:0]  pe_a [0:8];             // PE A inputs
    wire [7:0]  pe_b_in [0:8];          // PE B inputs
    wire [7:0]  pe_a_cascade [0:8];     // Horizontal cascade (A)
    wire [7:0]  pe_b_cascade [0:8];     // Vertical cascade (B)
    wire [7:0]  pe_acc_unused [0:8];    // Unused accumulator outputs
    wire        pe_clr = 1'b0;          // Not used (vertical chaining mode)
    // c_out_row0 and c_out_row1 declared above
    wire [7:0]  c_out_row2 [0:2];       // Row 2 outputs (final)

    // A Input Routing: From Controller
    assign pe_a[0] = a_val[0]; 
    assign pe_a[1] = pe_a_cascade[0];       
    assign pe_a[2] = pe_a_cascade[1];       
    
    assign pe_a[3] = a_val[1]; 
    assign pe_a[4] = pe_a_cascade[3];       
    assign pe_a[5] = pe_a_cascade[4];       
    
    assign pe_a[6] = a_val[2]; 
    assign pe_a[7] = pe_a_cascade[6];       
    assign pe_a[8] = pe_a_cascade[7];       

    // B Input Routing: From Controller (top) or Cascade (vertical)
    assign pe_b_in[0] = b_feed[0];
    assign pe_b_in[1] = b_feed[1];
    assign pe_b_in[2] = b_feed[2];
    
    assign pe_b_in[3] = pe_b_cascade[0];
    assign pe_b_in[4] = pe_b_cascade[1];
    assign pe_b_in[5] = pe_b_cascade[2];
    
    assign pe_b_in[6] = pe_b_cascade[3];
    assign pe_b_in[7] = pe_b_cascade[4];
    assign pe_b_in[8] = pe_b_cascade[5];

    // 3. PE Array (3x3 Grid)
    pe PE0 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[0]), .b_in(pe_b_in[0]), .c_in(ZERO),
        .a_out(pe_a_cascade[0]), .b_out(pe_b_cascade[0]), .acc_out(pe_acc_unused[0]), .c_out(c_out_row0[0]));
    pe PE1 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[1]), .b_in(pe_b_in[1]), .c_in(ZERO),
        .a_out(pe_a_cascade[1]), .b_out(pe_b_cascade[1]), .acc_out(pe_acc_unused[1]), .c_out(c_out_row0[1]));
    pe PE2 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[2]), .b_in(pe_b_in[2]), .c_in(ZERO),
        .a_out(pe_a_cascade[2]), .b_out(pe_b_cascade[2]), .acc_out(pe_acc_unused[2]), .c_out(c_out_row0[2]));
    pe PE3 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[3]), .b_in(pe_b_in[3]), .c_in(pipe_row0_to_1[0]),
        .a_out(pe_a_cascade[3]), .b_out(pe_b_cascade[3]), .acc_out(pe_acc_unused[3]), .c_out(c_out_row1[0]));
    pe PE4 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[4]), .b_in(pe_b_in[4]), .c_in(pipe_row0_to_1[1]),
        .a_out(pe_a_cascade[4]), .b_out(pe_b_cascade[4]), .acc_out(pe_acc_unused[4]), .c_out(c_out_row1[1]));
    pe PE5 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[5]), .b_in(pe_b_in[5]), .c_in(pipe_row0_to_1[2]),
        .a_out(pe_a_cascade[5]), .b_out(pe_b_cascade[5]), .acc_out(pe_acc_unused[5]), .c_out(c_out_row1[2]));
    pe PE6 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[6]), .b_in(pe_b_in[6]), .c_in(pipe_row1_to_2[0]),
        .a_out(pe_a_cascade[6]), .b_out(pe_b_cascade[6]), .acc_out(pe_acc_unused[6]), .c_out(c_out_row2[0]));
    pe PE7 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[7]), .b_in(pe_b_in[7]), .c_in(pipe_row1_to_2[1]),
        .a_out(pe_a_cascade[7]), .b_out(pe_b_cascade[7]), .acc_out(pe_acc_unused[7]), .c_out(c_out_row2[1]));
    pe PE8 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[8]), .b_in(pe_b_in[8]), .c_in(pipe_row1_to_2[2]),
        .a_out(pe_a_cascade[8]), .b_out(pe_b_cascade[8]), .acc_out(pe_acc_unused[8]), .c_out(c_out_row2[2]));

    // Output Registers for Temporal Alignment (Skew Correction)
    // Skew Analysis:
    // Col 0: Valid at T.
    // Col 1: Valid at T+2 (1 horizontal shift + 1 input sequence shift).
    // Col 2: Valid at T+4.    
    // Col 0 Delay Chain (4 buffers)
    wire [7:0] col0_d1, col0_d2, col0_d3, col0_d4;
    buffer_8bit buf_col0_s1 (.clk(clk), .rst_n(rst_n), .en(pe_en), .data_in(c_out_row2[0]), .data_out(col0_d1));
    buffer_8bit buf_col0_s2 (.clk(clk), .rst_n(rst_n), .en(pe_en), .data_in(col0_d1), .data_out(col0_d2));
    buffer_8bit buf_col0_s3 (.clk(clk), .rst_n(rst_n), .en(pe_en), .data_in(col0_d2), .data_out(col0_d3));
    buffer_8bit buf_col0_s4 (.clk(clk), .rst_n(rst_n), .en(pe_en), .data_in(col0_d3), .data_out(col0_d4));
    
    // Col 1 Delay Chain (2 buffers)
    wire [7:0] col1_d1, col1_d2;
    buffer_8bit buf_col1_s1 (.clk(clk), .rst_n(rst_n), .en(pe_en), .data_in(c_out_row2[1]), .data_out(col1_d1));
    buffer_8bit buf_col1_s2 (.clk(clk), .rst_n(rst_n), .en(pe_en), .data_in(col1_d1), .data_out(col1_d2));

    // 4. Final Result Adder Tree (Aligned inputs)
    wire [7:0] sum_col01;
    adder_8bit u_add_col01(.a(col0_d4), .b(col1_d2), .cin(1'b0), .sum(sum_col01), .cout());
    adder_8bit u_add_total(.a(sum_col01), .b(c_out_row2[2]), .cin(1'b0), .sum(total_sum), .cout());

endmodule
