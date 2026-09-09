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
    logic branch;
    logic alu_source_immediate;
    logic [3:0] alu_operation;
    logic [4:0] source_register_a;
    logic [4:0] source_register_b;
    logic [4:0] destination_register;
    integer checks_run = 0;

    rv32i_decoder dut (
        .instruction_i(instruction),
        .valid_o(valid),
        .register_write_o(register_write),
        .branch_o(branch),
        .alu_source_immediate_o(alu_source_immediate),
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

    function automatic logic [31:0] encode_branch_instruction(
        input logic [2:0] funct3
    );
        encode_branch_instruction = {
            1'b0, 6'b000100, 5'd11, 5'd7, funct3, 4'b1000, 1'b0, 7'b1100011
        };
    endfunction

    function automatic logic [31:0] encode_immediate_instruction(
        input logic [11:0] immediate_value,
        input logic [2:0] funct3
    );
        encode_immediate_instruction = {
            immediate_value, 5'd7, funct3, 5'd13, 7'b0010011
        };
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
            if (!valid || !register_write || branch || alu_source_immediate ||
                alu_operation !== expected_operation) begin
                $fatal(1, "%s: unexpected decoder controls", test_name);
            end
            if (source_register_a !== 5'd7 || source_register_b !== 5'd11 ||
                destination_register !== 5'd13) begin
                $fatal(1, "%s: register addresses were not extracted correctly", test_name);
            end
            checks_run = checks_run + 1;
        end
    endtask

    task automatic check_immediate(
        input logic [11:0] immediate_value,
        input logic [2:0] funct3,
        input logic [3:0] expected_operation,
        input string test_name
    );
        begin
            instruction = encode_immediate_instruction(immediate_value, funct3);
            #1;
            if (!valid || !register_write || branch || !alu_source_immediate ||
                alu_operation !== expected_operation) begin
                $fatal(1, "%s: unexpected immediate decoder controls", test_name);
            end
            if (source_register_a !== 5'd7 || destination_register !== 5'd13) begin
                $fatal(1, "%s: register addresses were not extracted correctly", test_name);
            end
            checks_run = checks_run + 1;
        end
    endtask

    task automatic check_branch(
        input logic [2:0] funct3,
        input string test_name
    );
        begin
            instruction = encode_branch_instruction(funct3);
            #1;
            if (!valid || register_write || !branch || alu_source_immediate) begin
                $fatal(1, "%s: unexpected branch decoder controls", test_name);
            end
            if (source_register_a !== 5'd7 || source_register_b !== 5'd11) begin
                $fatal(1, "%s: branch register addresses were not extracted correctly", test_name);
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
            if (valid || register_write || branch || alu_source_immediate) begin
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

        check_immediate(12'habc, 3'b000, ALU_ADD,  "ADDI");
        check_immediate(12'h123, 3'b010, ALU_SLT,  "SLTI");
        check_immediate(12'hfed, 3'b011, ALU_SLTU, "SLTIU");
        check_immediate(12'h456, 3'b100, ALU_XOR,  "XORI");
        check_immediate(12'h789, 3'b110, ALU_OR,   "ORI");
        check_immediate(12'h321, 3'b111, ALU_AND,  "ANDI");
        check_immediate(12'b0000000_11111, 3'b001, ALU_SLL, "SLLI");
        check_immediate(12'b0000000_11111, 3'b101, ALU_SRL, "SRLI");
        check_immediate(12'b0100000_11111, 3'b101, ALU_SRA, "SRAI");

        check_branch(3'b000, "BEQ");
        check_branch(3'b001, "BNE");
        check_branch(3'b100, "BLT");
        check_branch(3'b101, "BGE");
        check_branch(3'b110, "BLTU");
        check_branch(3'b111, "BGEU");

        check_invalid(32'h00000003, "unsupported load opcode");
        check_invalid(encode_register_instruction(7'b0000001, 3'b000),
                      "unsupported multiply encoding");
        check_invalid(encode_register_instruction(7'b0100000, 3'b001),
                      "illegal shift encoding");
        check_invalid(encode_immediate_instruction(12'b0100000_00001, 3'b001),
                      "illegal SLLI encoding");
        check_invalid(encode_immediate_instruction(12'b1111111_00001, 3'b101),
                      "illegal right-shift immediate encoding");
        check_invalid(encode_branch_instruction(3'b010), "reserved branch encoding 010");
        check_invalid(encode_branch_instruction(3'b011), "reserved branch encoding 011");

        $display("PASS: %0d decoder checks", checks_run);
        $finish;
    end
endmodule
