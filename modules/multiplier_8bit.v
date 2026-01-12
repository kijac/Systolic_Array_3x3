module multiplier_8bit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] product
);
    // Wires for structural modeling
    wire [35:0] pp;      // Partial Products (AND outputs)
    wire [27:0] fa_sum;  // Full Adder sums
    wire [27:0] fa_cout; // Full Adder carries

    // MULTIPLIER: 36 AND gates for Partial Products
    // Row 0: a[0..7] & b[0]
    and_gate pp00(.a(a[0]), .b(b[0]), .out(pp[0]));
    and_gate pp01(.a(a[1]), .b(b[0]), .out(pp[1]));
    and_gate pp02(.a(a[2]), .b(b[0]), .out(pp[2]));
    and_gate pp03(.a(a[3]), .b(b[0]), .out(pp[3]));
    and_gate pp04(.a(a[4]), .b(b[0]), .out(pp[4]));
    and_gate pp05(.a(a[5]), .b(b[0]), .out(pp[5]));
    and_gate pp06(.a(a[6]), .b(b[0]), .out(pp[6]));
    and_gate pp07(.a(a[7]), .b(b[0]), .out(pp[7]));
    // Row 1: a[0..6] & b[1]
    and_gate pp10(.a(a[0]), .b(b[1]), .out(pp[8]));
    and_gate pp11(.a(a[1]), .b(b[1]), .out(pp[9]));
    and_gate pp12(.a(a[2]), .b(b[1]), .out(pp[10]));
    and_gate pp13(.a(a[3]), .b(b[1]), .out(pp[11]));
    and_gate pp14(.a(a[4]), .b(b[1]), .out(pp[12]));
    and_gate pp15(.a(a[5]), .b(b[1]), .out(pp[13]));
    and_gate pp16(.a(a[6]), .b(b[1]), .out(pp[14]));
    // Row 2: a[0..5] & b[2]
    and_gate pp20(.a(a[0]), .b(b[2]), .out(pp[15]));
    and_gate pp21(.a(a[1]), .b(b[2]), .out(pp[16]));
    and_gate pp22(.a(a[2]), .b(b[2]), .out(pp[17]));
    and_gate pp23(.a(a[3]), .b(b[2]), .out(pp[18]));
    and_gate pp24(.a(a[4]), .b(b[2]), .out(pp[19]));
    and_gate pp25(.a(a[5]), .b(b[2]), .out(pp[20]));
    // Row 3: a[0..4] & b[3]
    and_gate pp30(.a(a[0]), .b(b[3]), .out(pp[21]));
    and_gate pp31(.a(a[1]), .b(b[3]), .out(pp[22]));
    and_gate pp32(.a(a[2]), .b(b[3]), .out(pp[23]));
    and_gate pp33(.a(a[3]), .b(b[3]), .out(pp[24]));
    and_gate pp34(.a(a[4]), .b(b[3]), .out(pp[25]));
    // Row 4: a[0..3] & b[4]
    and_gate pp40(.a(a[0]), .b(b[4]), .out(pp[26]));
    and_gate pp41(.a(a[1]), .b(b[4]), .out(pp[27]));
    and_gate pp42(.a(a[2]), .b(b[4]), .out(pp[28]));
    and_gate pp43(.a(a[3]), .b(b[4]), .out(pp[29]));
    // Row 5: a[0..2] & b[5]
    and_gate pp50(.a(a[0]), .b(b[5]), .out(pp[30]));
    and_gate pp51(.a(a[1]), .b(b[5]), .out(pp[31]));
    and_gate pp52(.a(a[2]), .b(b[5]), .out(pp[32]));
    // Row 6: a[0..1] & b[6]
    and_gate pp60(.a(a[0]), .b(b[6]), .out(pp[33]));
    and_gate pp61(.a(a[1]), .b(b[6]), .out(pp[34]));
    // Row 7: a[0] & b[7]
    and_gate pp70(.a(a[0]), .b(b[7]), .out(pp[35]));

    // MULTIPLIER: 28 Full Adders for Partial Product Reduction
    // mult_out[0] = pp[0] (no adder needed)
    assign product[0] = pp[0];
    
    // Calculate product[1]: pp[1] + pp[8]
    full_adder_behavioral_module fa_m1(.a(pp[1]), .b(pp[8]), .cin(1'b0), .sum(product[1]), .cout(fa_cout[0]));
    full_adder_behavioral_module fa_m2(.a(pp[2]), .b(pp[9]), .cin(fa_cout[0]), .sum(fa_sum[0]), .cout(fa_cout[1]));
    full_adder_behavioral_module fa_m3(.a(pp[3]), .b(pp[10]), .cin(fa_cout[1]), .sum(fa_sum[1]), .cout(fa_cout[2]));
    full_adder_behavioral_module fa_m4(.a(pp[4]), .b(pp[11]), .cin(fa_cout[2]), .sum(fa_sum[2]), .cout(fa_cout[3]));
    full_adder_behavioral_module fa_m5(.a(pp[5]), .b(pp[12]), .cin(fa_cout[3]), .sum(fa_sum[3]), .cout(fa_cout[4]));
    full_adder_behavioral_module fa_m6(.a(pp[6]), .b(pp[13]), .cin(fa_cout[4]), .sum(fa_sum[4]), .cout(fa_cout[5]));
    full_adder_behavioral_module fa_m7(.a(pp[7]), .b(pp[14]), .cin(fa_cout[5]), .sum(fa_sum[5]), .cout(fa_cout[6]));

    // Calculate product[2]: fa_sum[0] + pp[15]
    full_adder_behavioral_module fa_m8(.a(fa_sum[0]), .b(pp[15]), .cin(1'b0), .sum(product[2]), .cout(fa_cout[7]));
    full_adder_behavioral_module fa_m9(.a(fa_sum[1]), .b(pp[16]), .cin(fa_cout[7]), .sum(fa_sum[6]), .cout(fa_cout[8]));
    full_adder_behavioral_module fa_m10(.a(fa_sum[2]), .b(pp[17]), .cin(fa_cout[8]), .sum(fa_sum[7]), .cout(fa_cout[9]));
    full_adder_behavioral_module fa_m11(.a(fa_sum[3]), .b(pp[18]), .cin(fa_cout[9]), .sum(fa_sum[8]), .cout(fa_cout[10]));
    full_adder_behavioral_module fa_m12(.a(fa_sum[4]), .b(pp[19]), .cin(fa_cout[10]), .sum(fa_sum[9]), .cout(fa_cout[11]));
    full_adder_behavioral_module fa_m13(.a(fa_sum[5]), .b(pp[20]), .cin(fa_cout[11]), .sum(fa_sum[10]), .cout(fa_cout[12]));

    // Calculate product[3]: fa_sum[6] + pp[21]
    full_adder_behavioral_module fa_m14(.a(fa_sum[6]), .b(pp[21]), .cin(1'b0), .sum(product[3]), .cout(fa_cout[13]));
    full_adder_behavioral_module fa_m15(.a(fa_sum[7]), .b(pp[22]), .cin(fa_cout[13]), .sum(fa_sum[11]), .cout(fa_cout[14]));
    full_adder_behavioral_module fa_m16(.a(fa_sum[8]), .b(pp[23]), .cin(fa_cout[14]), .sum(fa_sum[12]), .cout(fa_cout[15]));
    full_adder_behavioral_module fa_m17(.a(fa_sum[9]), .b(pp[24]), .cin(fa_cout[15]), .sum(fa_sum[13]), .cout(fa_cout[16]));
    full_adder_behavioral_module fa_m18(.a(fa_sum[10]), .b(pp[25]), .cin(fa_cout[16]), .sum(fa_sum[14]), .cout(fa_cout[17]));

    // Calculate product[4]: fa_sum[11] + pp[26]
    full_adder_behavioral_module fa_m19(.a(fa_sum[11]), .b(pp[26]), .cin(1'b0), .sum(product[4]), .cout(fa_cout[18]));
    full_adder_behavioral_module fa_m20(.a(fa_sum[12]), .b(pp[27]), .cin(fa_cout[18]), .sum(fa_sum[15]), .cout(fa_cout[19]));
    full_adder_behavioral_module fa_m21(.a(fa_sum[13]), .b(pp[28]), .cin(fa_cout[19]), .sum(fa_sum[16]), .cout(fa_cout[20]));
    full_adder_behavioral_module fa_m22(.a(fa_sum[14]), .b(pp[29]), .cin(fa_cout[20]), .sum(fa_sum[17]), .cout(fa_cout[21]));

    // Calculate product[5]: fa_sum[15] + pp[30]
    full_adder_behavioral_module fa_m23(.a(fa_sum[15]), .b(pp[30]), .cin(1'b0), .sum(product[5]), .cout(fa_cout[22]));
    full_adder_behavioral_module fa_m24(.a(fa_sum[16]), .b(pp[31]), .cin(fa_cout[22]), .sum(fa_sum[18]), .cout(fa_cout[23]));
    full_adder_behavioral_module fa_m25(.a(fa_sum[17]), .b(pp[32]), .cin(fa_cout[23]), .sum(fa_sum[19]), .cout(fa_cout[24]));

    // Calculate product[6]: fa_sum[18] + pp[33]
    full_adder_behavioral_module fa_m26(.a(fa_sum[18]), .b(pp[33]), .cin(1'b0), .sum(product[6]), .cout(fa_cout[25]));
    full_adder_behavioral_module fa_m27(.a(fa_sum[19]), .b(pp[34]), .cin(fa_cout[25]), .sum(fa_sum[20]), .cout(fa_cout[26]));

    // Calculate product[7]: fa_sum[20] + pp[35]
    full_adder_behavioral_module fa_m28(.a(fa_sum[20]), .b(pp[35]), .cin(1'b0), .sum(product[7]), .cout(fa_cout[27]));

endmodule