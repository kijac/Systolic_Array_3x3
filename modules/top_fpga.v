// Module: top_fpga
// Description: FPGA Top-level module (pure interconnect only)
// Target: FPGA Starter Kit III (XC7A75T-1FGG484C)

module top_fpga (
    input  wire        clk_100m,
    input  wire        sys_rstb,    // Active-Low reset
    output wire [7:0]  digit,
    output wire [6:0]  seg
);

    reg [1:0] rst_sync;
    wire rst_n = rst_sync[1];
    
    always @(posedge clk_100m or negedge sys_rstb) begin
        if (!sys_rstb) rst_sync <= 2'b00;
        else           rst_sync <= {rst_sync[0], 1'b1};
    end
    
    wire        serial_start, sa3x3_start, sa2x2_start, display_start;
    wire        serial_done,  sa3x3_done,  sa2x2_done;
    wire [1:0]  mode;
    wire        all_done;
    
    wire [3:0]  mem_addr_a, mem_addr_b;
    wire [7:0]  mem_data_a, mem_data_b;
    
    wire [3:0]  serial_addr_a, serial_addr_b;
    wire [3:0]  sa3x3_addr_a,  sa3x3_addr_b;
    wire [3:0]  sa2x2_addr_a,  sa2x2_addr_b;
    
    wire [7:0]  serial_c11, serial_c12, serial_c21, serial_c22;
    wire [7:0]  sa3x3_c11,  sa3x3_c12,  sa3x3_c21,  sa3x3_c22;
    wire [7:0]  sa2x2_c11,  sa2x2_c12,  sa2x2_c21,  sa2x2_c22;
    
    wire [15:0] serial_cycles, sa3x3_cycles, sa2x2_cycles;
    
    assign mem_addr_a = (mode == 2'b01) ? serial_addr_a :
                        (mode == 2'b10) ? sa3x3_addr_a  :
                        (mode == 2'b11) ? sa2x2_addr_a  : 4'd0;
                        
    assign mem_addr_b = (mode == 2'b01) ? serial_addr_b :
                        (mode == 2'b10) ? sa3x3_addr_b  :
                        (mode == 2'b11) ? sa2x2_addr_b  : 4'd0;
    
    controller_fsm_fpga #(
        .AUTO_START_DELAY(24'd1000000)
    ) u_ctrl (
        .clk(clk_100m),
        .rst_n(rst_n),
        .serial_done(serial_done),
        .sa3x3_done(sa3x3_done),
        .sa2x2_done(sa2x2_done),
        .serial_start(serial_start),
        .sa3x3_start(sa3x3_start),
        .sa2x2_start(sa2x2_start),
        .display_start(display_start),
        .mode(mode),
        .all_done(all_done)
    );
    
    memory_storage u_mem (
        .rd_addr_a(mem_addr_a),
        .rd_addr_b(mem_addr_b),
        .rd_data_a(mem_data_a),
        .rd_data_b(mem_data_b)
    );
    
    serial_pe_compute u_serial (
        .clk(clk_100m),
        .rst_n(rst_n),
        .start(serial_start),
        .a_data(mem_data_a),
        .b_data(mem_data_b),
        .a_addr(serial_addr_a),
        .b_addr(serial_addr_b),
        .c11(serial_c11), .c12(serial_c12), .c21(serial_c21), .c22(serial_c22),
        .done(serial_done),
        .cycle_count(serial_cycles)
    );
    
    sa_3x3 u_sa3x3 (
        .clk(clk_100m),
        .rst_n(rst_n),
        .start(sa3x3_start),
        .a_data(mem_data_a),
        .b_data(mem_data_b),
        .a_addr(sa3x3_addr_a),
        .b_addr(sa3x3_addr_b),
        .c11(sa3x3_c11), .c12(sa3x3_c12), .c21(sa3x3_c21), .c22(sa3x3_c22),
        .done(sa3x3_done),
        .cycle_count(sa3x3_cycles)
    );
    
    sa_2x2 u_sa2x2 (
        .clk(clk_100m),
        .rst_n(rst_n),
        .start(sa2x2_start),
        .a_data(mem_data_a),
        .b_data(mem_data_b),
        .a_addr(sa2x2_addr_a),
        .b_addr(sa2x2_addr_b),
        .c11(sa2x2_c11),
        .c12(sa2x2_c12),
        .c21(sa2x2_c21),
        .c22(sa2x2_c22),
        .done(sa2x2_done),
        .cycle_count(sa2x2_cycles)
    );
    
    display_7seg_fpga #(
        .CLK_FREQ(100000000),
        .SCAN_FREQ(1000),
        .DISPLAY_TIME(100000000)
    ) u_display (
        .clk(clk_100m),
        .rst_n(rst_n),
        .start(display_start),
        .sa3x3_c11(sa3x3_c11),
        .sa3x3_c12(sa3x3_c12),
        .sa3x3_c21(sa3x3_c21),
        .sa3x3_c22(sa3x3_c22),
        .sa2x2_c11(sa2x2_c11),
        .sa2x2_c12(sa2x2_c12),
        .sa2x2_c21(sa2x2_c21),
        .sa2x2_c22(sa2x2_c22),
        .digit(digit),
        .seg(seg),
        .done()
    );

endmodule
