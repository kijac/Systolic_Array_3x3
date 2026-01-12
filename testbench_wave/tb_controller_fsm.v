`timescale 1ns/1ns
// Student TB: Controller FSM - Verify state transitions and start/done handshake
module tb_controller_fsm;
    reg clk, rst_n;
    reg serial_done, sa3x3_done, sa2x2_done;
    wire serial_start, sa3x3_start, sa2x2_start, display_start;
    wire [1:0] mode;
    wire all_done;
    
    controller_fsm_fpga #(.AUTO_START_DELAY(24'd50)) uut (
        .clk(clk), .rst_n(rst_n),
        .serial_done(serial_done), .sa3x3_done(sa3x3_done), .sa2x2_done(sa2x2_done),
        .serial_start(serial_start), .sa3x3_start(sa3x3_start), .sa2x2_start(sa2x2_start),
        .display_start(display_start), .mode(mode), .all_done(all_done)
    );
    
    wire [2:0] state = uut.state;
    initial begin clk = 0; forever #0.5 clk = ~clk; end
    
    initial begin
        rst_n = 0; serial_done = 0; sa3x3_done = 0; sa2x2_done = 0;
        #10 rst_n = 1;
        #60;
        #20 serial_done = 1; #2 serial_done = 0;
        #30 sa3x3_done = 1; #2 sa3x3_done = 0;
        #25 sa2x2_done = 1; #2 sa2x2_done = 0;
        #30 $finish;
    end
endmodule
