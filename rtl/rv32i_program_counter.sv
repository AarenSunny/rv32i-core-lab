module rv32i_program_counter (
    input  logic        clk_i,
    input  logic        reset_ni,
    input  logic        stall_i,
    input  logic        redirect_i,
    input  logic [31:0] redirect_address_i,
    output logic [31:0] program_counter_o
);
    timeunit 1ns;
    timeprecision 1ps;

    // Priority: reset, control-flow redirect, stall, sequential instruction.
    always_ff @(posedge clk_i or negedge reset_ni) begin
        if (!reset_ni) begin
            program_counter_o <= 32'b0;
        end else if (redirect_i) begin
            program_counter_o <= redirect_address_i;
        end else if (!stall_i) begin
            program_counter_o <= program_counter_o + 32'd4;
        end
    end
endmodule

