`timescale 1ns/1ps

module rv32i_program_counter_tb;
    logic clk = 1'b0;
    logic reset_n = 1'b1;
    logic stall = 1'b0;
    logic redirect = 1'b0;
    logic [31:0] redirect_address = 32'b0;
    logic [31:0] program_counter;
    integer checks_run = 0;

    always #5 clk = ~clk;

    rv32i_program_counter dut (
        .clk_i(clk),
        .reset_ni(reset_n),
        .stall_i(stall),
        .redirect_i(redirect),
        .redirect_address_i(redirect_address),
        .program_counter_o(program_counter)
    );

    task automatic check_pc(
        input logic [31:0] expected,
        input string test_name
    );
        begin
            if (program_counter !== expected) begin
                $fatal(1, "%s: expected %08h, got %08h", test_name, expected, program_counter);
            end
            checks_run = checks_run + 1;
        end
    endtask

    task automatic clock_once;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        #1;
        reset_n = 1'b0;
        #1;
        check_pc(32'd0, "asynchronous reset");

        @(negedge clk);
        reset_n = 1'b1;
        clock_once();
        check_pc(32'd4, "first sequential step");
        clock_once();
        check_pc(32'd8, "second sequential step");

        stall = 1'b1;
        clock_once();
        check_pc(32'd8, "stall holds address");

        redirect = 1'b1;
        redirect_address = 32'h00000100;
        clock_once();
        check_pc(32'h00000100, "redirect overrides stall");

        stall = 1'b0;
        redirect = 1'b0;
        clock_once();
        check_pc(32'h00000104, "sequential step after redirect");

        redirect = 1'b1;
        redirect_address = 32'hfffffffc;
        clock_once();
        check_pc(32'hfffffffc, "redirect to top of address space");
        redirect = 1'b0;
        clock_once();
        check_pc(32'h00000000, "32-bit sequential wraparound");

        #1;
        reset_n = 1'b0;
        #1;
        check_pc(32'd0, "reset after execution");

        $display("PASS: %0d program-counter checks", checks_run);
        $finish;
    end
endmodule

