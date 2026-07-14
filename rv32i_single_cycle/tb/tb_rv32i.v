`timescale 1ns/1ps

module tb_rv32i;

    reg clk;
    reg rst_n;
    integer error_count;

    rv32i_top dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        error_count = 0;

        $dumpfile("tb_rv32i.vcd");
        $dumpvars(0, tb_rv32i);

        #12;
        rst_n = 1'b1;

        repeat (20) @(posedge clk);
        #1;

        check_reg(5'd0,  32'h0000_0000, "x0 must stay zero");
        check_reg(5'd1,  32'h0000_0005, "ADDI result in x1");
        check_reg(5'd2,  32'h0000_000A, "ADDI result in x2");
        check_reg(5'd3,  32'h0000_000F, "ADD result in x3");
        check_reg(5'd4,  32'h0000_0005, "SUB result in x4");
        check_reg(5'd5,  32'h0000_0006, "ANDI result in x5");
        check_reg(5'd6,  32'h0000_0007, "ORI result in x6");
        check_reg(5'd7,  32'h0000_0002, "XOR result in x7");
        check_reg(5'd8,  32'h0000_000F, "LW result in x8");
        check_reg(5'd9,  32'h0000_0000, "BEQ should skip x9 write");
        check_reg(5'd10, 32'h0000_0000, "BNE should skip x10 write");
        check_reg(5'd11, 32'h0000_0005, "OR result in x11");
        check_reg(5'd12, 32'h0000_000F, "AND result in x12");
        check_mem(0,     32'h0000_000F, "SW should store x3 into memory[0]");

        if (error_count == 0) begin
            $display("TEST PASSED: all RV32I Phase 1 checks succeeded.");
        end else begin
            $display("TEST FAILED: %0d checks failed.", error_count);
        end

        $finish;
    end

    task check_reg;
        input [4:0] reg_addr;
        input [31:0] expected_value;
        input [383:0] test_name;
        reg [31:0] actual_value;
        begin
            actual_value = dut.u_regfile.registers[reg_addr];
            if (actual_value !== expected_value) begin
                error_count = error_count + 1;
                $display("FAIL: %0s | reg[%0d] expected=%h actual=%h",
                         test_name, reg_addr, expected_value, actual_value);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    task check_mem;
        input integer mem_index;
        input [31:0] expected_value;
        input [383:0] test_name;
        reg [31:0] actual_value;
        begin
            actual_value = dut.u_data_mem.mem_array[mem_index];
            if (actual_value !== expected_value) begin
                error_count = error_count + 1;
                $display("FAIL: %0s | mem[%0d] expected=%h actual=%h",
                         test_name, mem_index, expected_value, actual_value);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

endmodule
