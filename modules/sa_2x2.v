// SA 2x2: Systolic Array with Output Stationary (Structural Model)
// Architecture: 2x2 PE Grid with Internal Accumulation
// Control: Distributed - FSM logic in sa_2x2_controller
// Datapath: Pure structural interconnection of PE instances
// Results: c11/c12 from c_out (combinational), c21/c22 from acc_out (registered)

module sa_2x2 (
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
    // Control signals
    wire        pe_en, pe_clr, load_b;
    
    // Data feeds from controller
    wire [7:0]  b_feed_left, b_feed_right;    // B inputs (2 columns)
    wire [7:0]  a_feed_top_row;               // A input to top row
    wire [7:0]  a_feed_bot_row;               // A input to bottom row
    
    // PE interconnects
    wire [7:0]  pe_a [0:3];                   // PE A inputs
    wire [7:0]  pe_b_in [0:3];                // PE B inputs
    wire [7:0]  pe_c_in [0:3];                // PE C inputs (vertical)
    wire [7:0]  pe_a_cascade [0:3];           // Horizontal cascade
    wire [7:0]  pe_b_cascade [0:3];           // Vertical cascade
    wire [7:0]  pe_acc_top [0:1];             // Top row accumulators
    wire [7:0]  pe_acc_bot [0:1];             // Bottom row accumulators
    wire [7:0]  pe_c_out_bot [0:1];           // Bottom row combinational outputs

    // 1. Controller Instance (FSM & Memory Management)
    sa_2x2_controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a_data(a_data),
        .b_data(b_data),
        .pe_c_out_bot_0(pe_c_out_bot[0]), .pe_c_out_bot_1(pe_c_out_bot[1]),
        .pe_acc_bot_0(pe_acc_bot[0]),     .pe_acc_bot_1(pe_acc_bot[1]),
        .a_addr(a_addr),
        .b_addr(b_addr),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22),
        .done(done),
        .cycle_count(cycle_count),
        // To Datapath
        .pe_en(pe_en),
        .pe_clr(pe_clr),
        .load_b(load_b),
        .b_feed_left(b_feed_left),
        .b_feed_right(b_feed_right),
        .a_feed_top_row(a_feed_top_row),
        .a_feed_bot_row(a_feed_bot_row)
    );

    // 2. Datapath Interconnect
    // A routing (horizontal)
    assign pe_a[0] = a_feed_top_row; 
    assign pe_a[1] = pe_a_cascade[0];
    assign pe_a[2] = a_feed_bot_row; 
    assign pe_a[3] = pe_a_cascade[2];
    
    // B routing (vertical)
    assign pe_b_in[0] = b_feed_left; 
    assign pe_b_in[1] = b_feed_right;
    assign pe_b_in[2] = pe_b_cascade[0]; 
    assign pe_b_in[3] = pe_b_cascade[1];
    
    // C routing (vertical accumulation)
    assign pe_c_in[0] = ZERO; 
    assign pe_c_in[1] = ZERO;
    assign pe_c_in[2] = pe_acc_top[0]; 
    assign pe_c_in[3] = pe_acc_top[1];

    // 3. PE Array (2x2 Grid)
    pe PE0 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[0]), .b_in(pe_b_in[0]), .c_in(pe_c_in[0]),
        .a_out(pe_a_cascade[0]), .b_out(pe_b_cascade[0]), .acc_out(pe_acc_top[0]),
        .c_out()); // C-out unused for Top Row
    
    pe PE1 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[1]), .b_in(pe_b_in[1]), .c_in(pe_c_in[1]),
        .a_out(pe_a_cascade[1]), .b_out(pe_b_cascade[1]), .acc_out(pe_acc_top[1]),
        .c_out()); 
    
    pe PE2 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[2]), .b_in(pe_b_in[2]), .c_in(pe_c_in[2]),
        .a_out(pe_a_cascade[2]), .b_out(pe_b_cascade[2]), .acc_out(pe_acc_bot[0]),
        .c_out(pe_c_out_bot[0])); // Use Combinational Output
    
    pe PE3 (.clk(clk), .rst_n(rst_n), .clr_acc(pe_clr), .en(pe_en), .load_b(load_b),
        .a_in(pe_a[3]), .b_in(pe_b_in[3]), .c_in(pe_c_in[3]),
        .a_out(pe_a_cascade[3]), .b_out(pe_b_cascade[3]), .acc_out(pe_acc_bot[1]),
        .c_out(pe_c_out_bot[1])); 

endmodule
