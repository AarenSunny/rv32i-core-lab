module rv32i_decoder (
    input  logic [31:0] instruction_i,
    output logic        valid_o,
    output logic        register_write_o,
    output logic [3:0]  alu_operation_o,
    output logic [4:0]  source_register_a_o,
    output logic [4:0]  source_register_b_o,
    output logic [4:0]  destination_register_o
);
    timeunit 1ns;
    timeprecision 1ps;

    localparam logic [6:0] OPCODE_REGISTER = 7'b0110011;

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

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction_i[6:0];
    assign destination_register_o = instruction_i[11:7];
    assign funct3 = instruction_i[14:12];
    assign source_register_a_o = instruction_i[19:15];
    assign source_register_b_o = instruction_i[24:20];
    assign funct7 = instruction_i[31:25];

    always @* begin
        valid_o = 1'b0;
        register_write_o = 1'b0;
        alu_operation_o = ALU_ADD;

        if (opcode == OPCODE_REGISTER) begin
            case ({funct7, funct3})
                10'b0000000_000: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_ADD;
                end
                10'b0100000_000: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_SUB;
                end
                10'b0000000_001: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_SLL;
                end
                10'b0000000_010: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_SLT;
                end
                10'b0000000_011: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_SLTU;
                end
                10'b0000000_100: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_XOR;
                end
                10'b0000000_101: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_SRL;
                end
                10'b0100000_101: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_SRA;
                end
                10'b0000000_110: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_OR;
                end
                10'b0000000_111: begin
                    valid_o = 1'b1;
                    register_write_o = 1'b1;
                    alu_operation_o = ALU_AND;
                end
                default: begin
                    valid_o = 1'b0;
                    register_write_o = 1'b0;
                    alu_operation_o = ALU_ADD;
                end
            endcase
        end
    end
endmodule

