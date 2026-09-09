`timescale 1ns/1ps

module rv32i_register_file_tb;
    logic clk = 1'b0;
    logic write_enable = 1'b0;
    logic [4:0] write_address = 5'd0;
    logic [31:0] write_data = 32'd0;
    logic [4:0] read_address_a = 5'd0;
    logic [4:0] read_address_b = 5'd0;
    logic [31:0] read_data_a;
    logic [31:0] read_data_b;
    integer checks_run = 0;

    always #5 clk = ~clk;

    rv32i_register_file dut (
        .clk_i(clk),
        .write_enable_i(write_enable),
        .write_address_i(write_address),
        .write_data_i(write_data),
        .read_address_a_i(read_address_a),
        .read_address_b_i(read_address_b),
        .read_data_a_o(read_data_a),
        .read_data_b_o(read_data_b)
    );

    task automatic write_register(
        input logic [4:0] address,
        input logic [31:0] value
    );
        begin
            @(negedge clk);
            write_enable = 1'b1;
            write_address = address;
            write_data = value;
            @(posedge clk);
            #1;
            write_enable = 1'b0;
        end
    endtask

    task automatic check_port_a(
        input logic [4:0] address,
        input logic [31:0] expected,
        input string test_name
    );
        begin
            read_address_a = address;
            #1;
            if (read_data_a !== expected) begin
                $fatal(1, "%s: expected %08h, got %08h", test_name, expected, read_data_a);
            end
            checks_run = checks_run + 1;
        end
    endtask

    initial begin
        check_port_a(5'd0, 32'd0, "x0 starts at zero");

        write_register(5'd5, 32'h12345678);
        check_port_a(5'd5, 32'h12345678, "write and asynchronous read");

        write_register(5'd9, 32'hdeadbeef);
        read_address_a = 5'd5;
        read_address_b = 5'd9;
        #1;
        if (read_data_a !== 32'h12345678 || read_data_b !== 32'hdeadbeef) begin
            $fatal(1, "dual read ports returned incorrect values");
        end
        checks_run = checks_run + 1;

        write_register(5'd5, 32'hcafef00d);
        check_port_a(5'd5, 32'hcafef00d, "overwrite register");

        write_register(5'd0, 32'hffffffff);
        check_port_a(5'd0, 32'd0, "writes to x0 are ignored");

        write_register(5'd7, 32'h01020304);
        @(negedge clk);
        write_enable = 1'b0;
        write_address = 5'd7;
        write_data = 32'hffffffff;
        @(posedge clk);
        #1;
        check_port_a(5'd7, 32'h01020304, "disabled write is ignored");

        write_register(5'd31, 32'h80000001);
        check_port_a(5'd31, 32'h80000001, "highest register address");

        $display("PASS: %0d register-file checks", checks_run);
        $finish;
    end
endmodule

