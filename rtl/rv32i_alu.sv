module rv32i_alu (
    input  logic [31:0] lhs_i,
    input  logic [31:0] rhs_i,
    input  logic [3:0]  operation_i,
    output logic [31:0] result_o,
    output logic        zero_o
);
    timeunit 1ns;
    timeprecision 1ps;

    localparam logic [3:0] ALU_ADD  = 4'h0;
    localparam logic [3:0] ALU_SUB  = 4'h1;
    localparam logic [3:0] ALU_SLL  = 4'h2;
    localparam logic [3:0] ALU_SLT  = 4'h3;
    localparam logic [3:0] ALU_SLTU = 4'h4;
    localparam logic [3:0] ALU_XOR  = 4'h5;
    localparam logic [3:0] ALU_SRL  = 4'h6;
    localparam logic [3:0] ALU_SRA  = 4'h7;
    localparam logic [3:0] ALU_OR   = 4'h8;
    localparam logic [3:0] ALU_AND  = 4'h9;

    always @* begin
        case (operation_i)
            ALU_ADD:  result_o = lhs_i + rhs_i;
            ALU_SUB:  result_o = lhs_i - rhs_i;
            ALU_SLL:  result_o = lhs_i << rhs_i[4:0];
            ALU_SLT:  result_o = {31'b0, $signed(lhs_i) < $signed(rhs_i)};
            ALU_SLTU: result_o = {31'b0, lhs_i < rhs_i};
            ALU_XOR:  result_o = lhs_i ^ rhs_i;
            ALU_SRL:  result_o = lhs_i >> rhs_i[4:0];
            ALU_SRA:  result_o = $signed(lhs_i) >>> rhs_i[4:0];
            ALU_OR:   result_o = lhs_i | rhs_i;
            ALU_AND:  result_o = lhs_i & rhs_i;
            default:  result_o = 32'b0;
        endcase
    end

    assign zero_o = (result_o == 32'b0);
endmodule
