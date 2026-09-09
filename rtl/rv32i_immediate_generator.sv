module rv32i_immediate_generator (
    input  logic [31:0] instruction_i,
    output logic [31:0] immediate_o,
    output logic        valid_o
);
    timeunit 1ns;
    timeprecision 1ps;

    localparam logic [6:0] OPCODE_LOAD      = 7'b0000011;
    localparam logic [6:0] OPCODE_IMMEDIATE = 7'b0010011;
    localparam logic [6:0] OPCODE_AUIPC     = 7'b0010111;
    localparam logic [6:0] OPCODE_STORE     = 7'b0100011;
    localparam logic [6:0] OPCODE_LUI       = 7'b0110111;
    localparam logic [6:0] OPCODE_BRANCH    = 7'b1100011;
    localparam logic [6:0] OPCODE_JALR      = 7'b1100111;
    localparam logic [6:0] OPCODE_JAL       = 7'b1101111;

    always @* begin
        immediate_o = 32'b0;
        valid_o = 1'b1;

        case (instruction_i[6:0])
            OPCODE_LOAD,
            OPCODE_IMMEDIATE,
            OPCODE_JALR: begin
                immediate_o = {{20{instruction_i[31]}}, instruction_i[31:20]};
            end
            OPCODE_STORE: begin
                immediate_o = {
                    {20{instruction_i[31]}},
                    instruction_i[31:25],
                    instruction_i[11:7]
                };
            end
            OPCODE_BRANCH: begin
                immediate_o = {
                    {19{instruction_i[31]}},
                    instruction_i[31],
                    instruction_i[7],
                    instruction_i[30:25],
                    instruction_i[11:8],
                    1'b0
                };
            end
            OPCODE_LUI,
            OPCODE_AUIPC: begin
                immediate_o = {instruction_i[31:12], 12'b0};
            end
            OPCODE_JAL: begin
                immediate_o = {
                    {11{instruction_i[31]}},
                    instruction_i[31],
                    instruction_i[19:12],
                    instruction_i[20],
                    instruction_i[30:21],
                    1'b0
                };
            end
            default: begin
                immediate_o = 32'b0;
                valid_o = 1'b0;
            end
        endcase
    end
endmodule

