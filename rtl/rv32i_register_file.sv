module rv32i_register_file (
    input  logic        clk_i,
    input  logic        write_enable_i,
    input  logic [4:0]  write_address_i,
    input  logic [31:0] write_data_i,
    input  logic [4:0]  read_address_a_i,
    input  logic [4:0]  read_address_b_i,
    output logic [31:0] read_data_a_o,
    output logic [31:0] read_data_b_o
);
    timeunit 1ns;
    timeprecision 1ps;

    // x0 is omitted from storage because the ISA requires it to remain zero.
    logic [31:0] registers [1:31];

    always_ff @(posedge clk_i) begin
        if (write_enable_i && write_address_i != 5'd0) begin
            registers[write_address_i] <= write_data_i;
        end
    end

    assign read_data_a_o = read_address_a_i == 5'd0
        ? 32'b0
        : registers[read_address_a_i];
    assign read_data_b_o = read_address_b_i == 5'd0
        ? 32'b0
        : registers[read_address_b_i];
endmodule
