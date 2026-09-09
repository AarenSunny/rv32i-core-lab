`timescale 1ns/1ps

module rv32i_immediate_generator_tb;
    logic [31:0] instruction;
    logic [31:0] immediate;
    logic valid;
    integer checks_run = 0;

    rv32i_immediate_generator dut (
        .instruction_i(instruction),
        .immediate_o(immediate),
        .valid_o(valid)
    );

    function automatic logic [31:0] encode_i(
        input logic [11:0] value,
        input logic [6:0] opcode
    );
        encode_i = {value, 5'd3, 3'b000, 5'd5, opcode};
    endfunction

    function automatic logic [31:0] encode_s(input logic [11:0] value);
        encode_s = {value[11:5], 5'd9, 5'd4, 3'b010, value[4:0], 7'b0100011};
    endfunction

    function automatic logic [31:0] encode_b(input logic [12:0] value);
        encode_b = {
            value[12], value[10:5], 5'd9, 5'd4, 3'b000,
            value[4:1], value[11], 7'b1100011
        };
    endfunction

    function automatic logic [31:0] encode_u(
        input logic [19:0] value,
        input logic [6:0] opcode
    );
        encode_u = {value, 5'd5, opcode};
    endfunction

    function automatic logic [31:0] encode_j(input logic [20:0] value);
        encode_j = {
            value[20], value[10:1], value[11], value[19:12], 5'd5, 7'b1101111
        };
    endfunction

    task automatic check(
        input logic [31:0] test_instruction,
        input logic [31:0] expected,
        input string test_name
    );
        begin
            instruction = test_instruction;
            #1;
            if (!valid || immediate !== expected) begin
                $fatal(1, "%s: expected %08h, got %08h", test_name, expected, immediate);
            end
            checks_run = checks_run + 1;
        end
    endtask

    initial begin
        check(encode_i(12'h7ff, 7'b0000011), 32'h000007ff, "I positive load");
        check(encode_i(12'hfff, 7'b0010011), 32'hffffffff, "I negative ALU");
        check(encode_i(12'h800, 7'b1100111), 32'hfffff800, "I minimum JALR");
        check(encode_s(12'h123), 32'h00000123, "S positive");
        check(encode_s(12'hff0), 32'hfffffff0, "S negative");
        check(encode_b(13'h010), 32'h00000010, "B forward");
        check(encode_b(13'h1ffc), 32'hfffffffc, "B backward");
        check(encode_u(20'h12345, 7'b0110111), 32'h12345000, "U LUI");
        check(encode_u(20'hfffff, 7'b0010111), 32'hfffff000, "U AUIPC");
        check(encode_j(21'h00800), 32'h00000800, "J forward");
        check(encode_j(21'h1ffffe), 32'hfffffffe, "J backward");

        instruction = 32'h00000033;
        #1;
        if (valid || immediate !== 32'b0) begin
            $fatal(1, "R-type instruction should not produce an immediate");
        end
        checks_run = checks_run + 1;

        $display("PASS: %0d immediate-generator checks", checks_run);
        $finish;
    end
endmodule

