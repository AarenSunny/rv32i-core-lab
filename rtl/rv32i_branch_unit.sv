module rv32i_branch_unit (
    input  logic [2:0]  funct3_i,
    input  logic [31:0] lhs_i,
    input  logic [31:0] rhs_i,
    output logic        valid_o,
    output logic        taken_o
);
    timeunit 1ns;
    timeprecision 1ps;

    always @* begin
        valid_o = 1'b1;

        case (funct3_i)
            3'b000: taken_o = (lhs_i == rhs_i);
            3'b001: taken_o = (lhs_i != rhs_i);
            3'b100: taken_o = ($signed(lhs_i) < $signed(rhs_i));
            3'b101: taken_o = ($signed(lhs_i) >= $signed(rhs_i));
            3'b110: taken_o = (lhs_i < rhs_i);
            3'b111: taken_o = (lhs_i >= rhs_i);
            default: begin
                valid_o = 1'b0;
                taken_o = 1'b0;
            end
        endcase
    end
endmodule
