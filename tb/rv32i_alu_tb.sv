`timescale 1ns/1ps

module rv32i_alu_tb;
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

    logic [31:0] lhs;
    logic [31:0] rhs;
    logic [3:0] operation;
    logic [31:0] result;
    logic zero;
    integer tests_run = 0;

    rv32i_alu dut (
        .lhs_i(lhs),
        .rhs_i(rhs),
        .operation_i(operation),
        .result_o(result),
        .zero_o(zero)
    );

    task automatic check(
        input logic [3:0] test_operation,
        input logic [31:0] test_lhs,
        input logic [31:0] test_rhs,
        input logic [31:0] expected,
        input string test_name
    );
        begin
            operation = test_operation;
            lhs = test_lhs;
            rhs = test_rhs;
            #1;
            if (result !== expected) begin
                $fatal(1, "%s: expected %08h, got %08h", test_name, expected, result);
            end
            if (zero !== (expected == 32'b0)) begin
                $fatal(1, "%s: zero flag mismatch", test_name);
            end
            tests_run = tests_run + 1;
        end
    endtask

    initial begin
        check(ALU_ADD,  32'd20,       32'd22,       32'd42,       "add");
        check(ALU_ADD,  32'hffffffff, 32'd1,        32'd0,        "add wraparound");
        check(ALU_SUB,  32'd42,       32'd17,       32'd25,       "subtract");
        check(ALU_SUB,  32'd3,        32'd5,        32'hfffffffe, "subtract negative");
        check(ALU_AND,  32'hf0f00f0f, 32'h0ff0ffff, 32'h00f00f0f, "and");
        check(ALU_OR,   32'hf000000f, 32'h0f0000f0, 32'hff0000ff, "or");
        check(ALU_XOR,  32'haaaa5555, 32'hffff0000, 32'h55555555, "xor");
        check(ALU_SLL,  32'd1,        32'd31,       32'h80000000, "shift left");
        check(ALU_SLL,  32'h12345678, 32'd32,       32'h12345678, "shift amount mask");
        check(ALU_SRL,  32'h80000000, 32'd31,       32'd1,        "logical shift right");
        check(ALU_SRA,  32'h80000000, 32'd31,       32'hffffffff, "arithmetic shift right");
        check(ALU_SLT,  32'hffffffff, 32'd1,        32'd1,        "signed less than");
        check(ALU_SLT,  32'd1,        32'hffffffff, 32'd0,        "signed greater than");
        check(ALU_SLTU, 32'hffffffff, 32'd1,        32'd0,        "unsigned greater than");
        check(ALU_SLTU, 32'd1,        32'hffffffff, 32'd1,        "unsigned less than");
        check(4'hf,     32'hdeadbeef, 32'h12345678, 32'd0,        "invalid operation");

        $display("PASS: %0d RV32I ALU checks", tests_run);
        $finish;
    end
endmodule

