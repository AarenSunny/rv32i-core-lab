module rv32i_core (
    input  logic        clk_i,
    input  logic        reset_ni,
    input  logic [31:0] instruction_i,
    output logic [31:0] program_counter_o,
    output logic        instruction_valid_o,
    output logic        register_write_o,
    output logic [4:0]  destination_register_o,
    output logic [31:0] writeback_data_o
);
    timeunit 1ns;
    timeprecision 1ps;

    logic decoder_valid;
    logic decoder_register_write;
    logic decoder_branch;
    logic alu_source_immediate;
    logic [3:0] alu_operation;
    logic [4:0] source_register_a;
    logic [4:0] source_register_b;
    logic [31:0] register_data_a;
    logic [31:0] register_data_b;
    logic [31:0] immediate;
    logic immediate_valid;
    logic branch_condition_valid;
    logic branch_taken;
    logic [31:0] branch_target;
    logic [31:0] alu_rhs;
    logic alu_zero;

    rv32i_program_counter program_counter (
        .clk_i(clk_i),
        .reset_ni(reset_ni),
        .stall_i(1'b0),
        .redirect_i(reset_ni && instruction_valid_o && decoder_branch && branch_taken),
        .redirect_address_i(branch_target),
        .program_counter_o(program_counter_o)
    );

    rv32i_decoder decoder (
        .instruction_i(instruction_i),
        .valid_o(decoder_valid),
        .register_write_o(decoder_register_write),
        .branch_o(decoder_branch),
        .alu_source_immediate_o(alu_source_immediate),
        .alu_operation_o(alu_operation),
        .source_register_a_o(source_register_a),
        .source_register_b_o(source_register_b),
        .destination_register_o(destination_register_o)
    );

    rv32i_immediate_generator immediate_generator (
        .instruction_i(instruction_i),
        .immediate_o(immediate),
        .valid_o(immediate_valid)
    );

    assign instruction_valid_o = decoder_valid &&
        (decoder_branch
            ? (immediate_valid && branch_condition_valid)
            : (!alu_source_immediate || immediate_valid));
    assign register_write_o = reset_ni && instruction_valid_o &&
        decoder_register_write;
    assign alu_rhs = alu_source_immediate ? immediate : register_data_b;
    assign branch_target = program_counter_o + immediate;

    rv32i_register_file register_file (
        .clk_i(clk_i),
        .write_enable_i(register_write_o),
        .write_address_i(destination_register_o),
        .write_data_i(writeback_data_o),
        .read_address_a_i(source_register_a),
        .read_address_b_i(source_register_b),
        .read_data_a_o(register_data_a),
        .read_data_b_o(register_data_b)
    );

    rv32i_alu alu (
        .lhs_i(register_data_a),
        .rhs_i(alu_rhs),
        .operation_i(alu_operation),
        .result_o(writeback_data_o),
        .zero_o(alu_zero)
    );

    rv32i_branch_unit branch_unit (
        .funct3_i(instruction_i[14:12]),
        .lhs_i(register_data_a),
        .rhs_i(register_data_b),
        .valid_o(branch_condition_valid),
        .taken_o(branch_taken)
    );
endmodule
