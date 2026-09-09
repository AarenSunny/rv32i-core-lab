`timescale 1ns/1ps

module rv32i_branch_unit_tb;
    logic [2:0] funct3;
    logic [31:0] lhs;
    logic [31:0] rhs;
    logic valid;
    logic taken;
    integer checks_run = 0;

    rv32i_branch_unit dut (
        .funct3_i(funct3),
        .lhs_i(lhs),
        .rhs_i(rhs),
        .valid_o(valid),
        .taken_o(taken)
    );

    task automatic check_branch(
        input logic [2:0] test_funct3,
        input logic [31:0] test_lhs,
        input logic [31:0] test_rhs,
        input logic expected_valid,
        input logic expected_taken,
        input string test_name
    );
        begin
            funct3 = test_funct3;
            lhs = test_lhs;
            rhs = test_rhs;
            #1;
            if (valid !== expected_valid) begin
                $fatal(1, "%s: expected valid=%b, got %b", test_name, expected_valid, valid);
            end
            if (taken !== expected_taken) begin
                $fatal(1, "%s: expected taken=%b, got %b", test_name, expected_taken, taken);
            end
            checks_run = checks_run + 1;
        end
    endtask

    initial begin
        check_branch(3'b000, 32'd42,       32'd42, 1'b1, 1'b1, "BEQ equal");
        check_branch(3'b000, 32'd42,       32'd41, 1'b1, 1'b0, "BEQ unequal");
        check_branch(3'b001, 32'd42,       32'd41, 1'b1, 1'b1, "BNE unequal");
        check_branch(3'b001, 32'd42,       32'd42, 1'b1, 1'b0, "BNE equal");
        check_branch(3'b100, 32'hffffffff, 32'd1,  1'b1, 1'b1, "BLT signed true");
        check_branch(3'b100, 32'd1,        32'hffffffff, 1'b1, 1'b0, "BLT signed false");
        check_branch(3'b101, 32'd1,        32'hffffffff, 1'b1, 1'b1, "BGE signed true");
        check_branch(3'b101, 32'hffffffff, 32'd1,  1'b1, 1'b0, "BGE signed false");
        check_branch(3'b110, 32'd1,        32'hffffffff, 1'b1, 1'b1, "BLTU true");
        check_branch(3'b110, 32'hffffffff, 32'd1,  1'b1, 1'b0, "BLTU false");
        check_branch(3'b111, 32'hffffffff, 32'd1,  1'b1, 1'b1, "BGEU true");
        check_branch(3'b111, 32'd1,        32'hffffffff, 1'b1, 1'b0, "BGEU false");
        check_branch(3'b010, 32'd7,        32'd7,  1'b0, 1'b0, "reserved funct3 010");
        check_branch(3'b011, 32'd7,        32'd8,  1'b0, 1'b0, "reserved funct3 011");

        $display("PASS: %0d branch-unit checks", checks_run);
        $finish;
    end
endmodule
