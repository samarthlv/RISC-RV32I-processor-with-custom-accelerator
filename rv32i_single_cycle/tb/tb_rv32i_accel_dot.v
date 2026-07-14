`timescale 1ns/1ps

module tb_rv32i_accel_dot;

    reg clk;
    reg rst_n;
    integer error_count;

    rv32i_top #(
        .MEM_FILE("mem/program_accel_dot.hex")
    ) dut (
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

        $dumpfile("tb_rv32i_accel_dot.vcd");
        $dumpvars(0, tb_rv32i_accel_dot);

        #12;
        rst_n = 1'b1;

        repeat (40) @(posedge clk);
        #1;

        check_reg(5'd10, 32'h0000_0046, "CPU should read dot-product result into x10");
        check_reg(5'd11, 32'h0000_0046, "CPU should read back stored dot-product result into x11");
        check_mem(0,     32'h0000_0046, "CPU should store dot-product result into data memory");
        check_accel_scalar(32'h0000_0046, "Accelerator scalar result should hold dot-product value");

        if (error_count == 0) begin
            $display("TEST PASSED: RV32I to accelerator dot-product integration succeeded.");
        end else begin
            $display("TEST FAILED: %0d dot integration checks failed.", error_count);
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

    task check_accel_scalar;
        input [31:0] expected_value;
        input [383:0] test_name;
        reg [31:0] actual_value;
        begin
            actual_value = dut.u_accel_mmio.u_hardware_accelerator.scalar_result;
            if (actual_value !== expected_value) begin
                error_count = error_count + 1;
                $display("FAIL: %0s | accel expected=%h actual=%h",
                         test_name, expected_value, actual_value);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

endmodule
