`timescale 1ns/1ps

module rv32i_core_tb;
    logic clk = 1'b0;
    logic reset_n = 1'b1;
    logic [31:0] instruction = 32'b0;
    logic [31:0] program_counter;
    logic instruction_valid;
    logic register_write;
    logic [4:0] destination_register;
    logic [31:0] writeback_data;
    integer checks_run = 0;

    always #5 clk = ~clk;

    rv32i_core dut (
        .clk_i(clk),
        .reset_ni(reset_n),
        .instruction_i(instruction),
        .program_counter_o(program_counter),
        .instruction_valid_o(instruction_valid),
        .register_write_o(register_write),
        .destination_register_o(destination_register),
        .writeback_data_o(writeback_data)
    );

    function automatic logic [31:0] encode_register_instruction(
        input logic [6:0] funct7,
        input logic [4:0] rs2,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [4:0] rd
    );
        encode_register_instruction = {funct7, rs2, rs1, funct3, rd, 7'b0110011};
    endfunction

    function automatic logic [31:0] encode_immediate_instruction(
        input logic [11:0] immediate_value,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [4:0] rd
    );
        encode_immediate_instruction = {
            immediate_value, rs1, funct3, rd, 7'b0010011
        };
    endfunction

    function automatic logic [31:0] encode_branch_instruction(
        input logic [12:0] immediate_value,
        input logic [4:0] rs2,
        input logic [4:0] rs1,
        input logic [2:0] funct3
    );
        encode_branch_instruction = {
            immediate_value[12], immediate_value[10:5], rs2, rs1, funct3,
            immediate_value[4:1], immediate_value[11], 7'b1100011
        };
    endfunction

    task automatic execute_and_check(
        input logic [31:0] test_instruction,
        input logic [31:0] expected_pc,
        input logic [4:0] expected_destination,
        input logic [31:0] expected_writeback,
        input string test_name
    );
        begin
            instruction = test_instruction;
            #1;
            if (program_counter !== expected_pc || !instruction_valid ||
                !register_write || destination_register !== expected_destination ||
                writeback_data !== expected_writeback) begin
                $fatal(1, "%s: unexpected execution result", test_name);
            end

            @(posedge clk);
            #1;
            if (program_counter !== expected_pc + 32'd4) begin
                $fatal(1, "%s: program counter did not advance", test_name);
            end
            checks_run = checks_run + 1;
            @(negedge clk);
        end
    endtask

    task automatic branch_and_check(
        input logic [31:0] test_instruction,
        input logic [31:0] expected_pc,
        input logic [31:0] expected_next_pc,
        input string test_name
    );
        begin
            instruction = test_instruction;
            #1;
            if (program_counter !== expected_pc || !instruction_valid ||
                register_write) begin
                $fatal(1, "%s: unexpected branch controls", test_name);
            end

            @(posedge clk);
            #1;
            if (program_counter !== expected_next_pc) begin
                $fatal(1, "%s: expected next PC %08h, got %08h",
                       test_name, expected_next_pc, program_counter);
            end
            checks_run = checks_run + 1;
            @(negedge clk);
        end
    endtask

    initial begin
        #1;
        reset_n = 1'b0;
        #1;
        if (program_counter !== 32'b0 || register_write) begin
            $fatal(1, "reset did not hold architectural state");
        end
        checks_run = checks_run + 1;

        @(negedge clk);
        reset_n = 1'b1;

        execute_and_check(
            encode_immediate_instruction(12'd5, 5'd0, 3'b000, 5'd1),
            32'd0, 5'd1, 32'd5, "ADDI x1, x0, 5"
        );
        execute_and_check(
            encode_immediate_instruction(12'hffe, 5'd1, 3'b000, 5'd2),
            32'd4, 5'd2, 32'd3, "ADDI x2, x1, -2"
        );
        execute_and_check(
            encode_register_instruction(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3),
            32'd8, 5'd3, 32'd8, "ADD x3, x1, x2"
        );
        execute_and_check(
            encode_immediate_instruction(12'b0000000_00010, 5'd3, 3'b001, 5'd4),
            32'd12, 5'd4, 32'd32, "SLLI x4, x3, 2"
        );
        execute_and_check(
            encode_register_instruction(7'b0100000, 5'd1, 5'd4, 3'b000, 5'd5),
            32'd16, 5'd5, 32'd27, "SUB x5, x4, x1"
        );
        execute_and_check(
            encode_immediate_instruction(12'h00f, 5'd5, 3'b111, 5'd6),
            32'd20, 5'd6, 32'd11, "ANDI x6, x5, 15"
        );

        instruction = 32'b0;
        #1;
        if (instruction_valid || register_write) begin
            $fatal(1, "illegal instruction enabled architectural state");
        end
        @(posedge clk);
        #1;
        if (program_counter !== 32'd28) begin
            $fatal(1, "program counter did not advance past illegal instruction");
        end
        checks_run = checks_run + 1;
        @(negedge clk);

        branch_and_check(
            encode_branch_instruction(13'd8, 5'd2, 5'd1, 3'b000),
            32'd28, 32'd32, "BEQ not taken"
        );
        branch_and_check(
            encode_branch_instruction(13'd12, 5'd2, 5'd1, 3'b001),
            32'd32, 32'd44, "BNE taken forward"
        );
        branch_and_check(
            encode_branch_instruction(13'h1ff8, 5'd1, 5'd2, 3'b100),
            32'd44, 32'd36, "BLT taken backward"
        );
        branch_and_check(
            encode_branch_instruction(13'd8, 5'd1, 5'd2, 3'b101),
            32'd36, 32'd40, "BGE not taken"
        );

        $display("PASS: %0d core-integration checks", checks_run);
        $finish;
    end
endmodule
