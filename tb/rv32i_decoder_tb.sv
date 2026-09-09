`timescale 1ns/1ps

module rv32i_decoder_tb;
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

    logic [31:0] instruction;
    logic valid;
    logic register_write;
    logic [3:0] alu_operation;
    logic [4:0] source_register_a;
    logic [4:0] source_register_b;
    logic [4:0] destination_register;
    integer checks_run = 0;

    rv32i_decoder dut (
        .instruction_i(instruction),
        .valid_o(valid),
        .register_write_o(register_write),
        .alu_operation_o(alu_operation),
        .source_register_a_o(source_register_a),
        .source_register_b_o(source_register_b),
        .destination_register_o(destination_register)
    );

    function automatic logic [31:0] encode_register_instruction(
        input logic [6:0] funct7,
        input logic [2:0] funct3
    );
        encode_register_instruction = {funct7, 5'd11, 5'd7, funct3, 5'd13, 7'b0110011};
    endfunction

    task automatic check_valid(
        input logic [6:0] funct7,
        input logic [2:0] funct3,
        input logic [3:0] expected_operation,
        input string test_name
    );
        begin
            instruction = encode_register_instruction(funct7, funct3);
            #1;
            if (!valid || !register_write || alu_operation !== expected_operation) begin
                $fatal(1, "%s: unexpected decoder controls", test_name);
            end
            if (source_register_a !== 5'd7 || source_register_b !== 5'd11 ||
                destination_register !== 5'd13) begin
                $fatal(1, "%s: register addresses were not extracted correctly", test_name);
            end
            checks_run = checks_run + 1;
        end
    endtask

    task automatic check_invalid(
        input logic [31:0] test_instruction,
        input string test_name
    );
        begin
            instruction = test_instruction;
            #1;
            if (valid || register_write) begin
                $fatal(1, "%s: illegal instruction enabled architectural state", test_name);
            end
            checks_run = checks_run + 1;
        end
    endtask

    initial begin
        check_valid(7'b0000000, 3'b000, ALU_ADD,  "ADD");
        check_valid(7'b0100000, 3'b000, ALU_SUB,  "SUB");
        check_valid(7'b0000000, 3'b001, ALU_SLL,  "SLL");
        check_valid(7'b0000000, 3'b010, ALU_SLT,  "SLT");
        check_valid(7'b0000000, 3'b011, ALU_SLTU, "SLTU");
        check_valid(7'b0000000, 3'b100, ALU_XOR,  "XOR");
        check_valid(7'b0000000, 3'b101, ALU_SRL,  "SRL");
        check_valid(7'b0100000, 3'b101, ALU_SRA,  "SRA");
        check_valid(7'b0000000, 3'b110, ALU_OR,   "OR");
        check_valid(7'b0000000, 3'b111, ALU_AND,  "AND");

        check_invalid(32'h00000013, "unsupported opcode");
        check_invalid(encode_register_instruction(7'b0000001, 3'b000),
                      "unsupported multiply encoding");
        check_invalid(encode_register_instruction(7'b0100000, 3'b001),
                      "illegal shift encoding");

        $display("PASS: %0d R-type decoder checks", checks_run);
        $finish;
    end
endmodule

