`timescale 1ns/1ps

module tb_rv32i_accel_systolic;

    reg clk;
    reg rst_n;
    integer error_count;

    rv32i_top #(
        .MEM_FILE("mem/program_accel_systolic.hex")
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

        $dumpfile("tb_rv32i_accel_systolic.vcd");
        $dumpvars(0, tb_rv32i_accel_systolic);

        #12;
        rst_n = 1'b1;

        repeat (90) @(posedge clk);
        #1;

        check_reg(5'd13, 32'h0000_0008, "CPU should read systolic c00 into x13");
        check_reg(5'd14, 32'h0000_0008, "CPU should read systolic c33 into x14");
        check_reg(5'd15, 32'h0000_0008, "CPU should read back stored c00 into x15");
        check_reg(5'd16, 32'h0000_0008, "CPU should read back stored c33 into x16");
        check_mem(0,     32'h0000_0008, "CPU should store systolic c00 into data memory");
        check_mem(1,     32'h0000_0008, "CPU should store systolic c33 into data memory");

        check_matrix(32'd8,  32'd8,  32'd15, 32'd12,
                     32'd5,  32'd7,  32'd8,  32'd5,
                     32'd8,  32'd9,  32'd7,  32'd5,
                     32'd5,  32'd6,  32'd11, 32'd8);

        if (error_count == 0) begin
            $display("TEST PASSED: RV32I to accelerator systolic integration succeeded.");
        end else begin
            $display("TEST FAILED: %0d systolic integration checks failed.", error_count);
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

    task check_matrix;
        input [31:0] exp_c00; input [31:0] exp_c01; input [31:0] exp_c02; input [31:0] exp_c03;
        input [31:0] exp_c10; input [31:0] exp_c11; input [31:0] exp_c12; input [31:0] exp_c13;
        input [31:0] exp_c20; input [31:0] exp_c21; input [31:0] exp_c22; input [31:0] exp_c23;
        input [31:0] exp_c30; input [31:0] exp_c31; input [31:0] exp_c32; input [31:0] exp_c33;
        begin
            check_value("Systolic c00", exp_c00, dut.u_accel_mmio.u_hardware_accelerator.c00);
            check_value("Systolic c01", exp_c01, dut.u_accel_mmio.u_hardware_accelerator.c01);
            check_value("Systolic c02", exp_c02, dut.u_accel_mmio.u_hardware_accelerator.c02);
            check_value("Systolic c03", exp_c03, dut.u_accel_mmio.u_hardware_accelerator.c03);
            check_value("Systolic c10", exp_c10, dut.u_accel_mmio.u_hardware_accelerator.c10);
            check_value("Systolic c11", exp_c11, dut.u_accel_mmio.u_hardware_accelerator.c11);
            check_value("Systolic c12", exp_c12, dut.u_accel_mmio.u_hardware_accelerator.c12);
            check_value("Systolic c13", exp_c13, dut.u_accel_mmio.u_hardware_accelerator.c13);
            check_value("Systolic c20", exp_c20, dut.u_accel_mmio.u_hardware_accelerator.c20);
            check_value("Systolic c21", exp_c21, dut.u_accel_mmio.u_hardware_accelerator.c21);
            check_value("Systolic c22", exp_c22, dut.u_accel_mmio.u_hardware_accelerator.c22);
            check_value("Systolic c23", exp_c23, dut.u_accel_mmio.u_hardware_accelerator.c23);
            check_value("Systolic c30", exp_c30, dut.u_accel_mmio.u_hardware_accelerator.c30);
            check_value("Systolic c31", exp_c31, dut.u_accel_mmio.u_hardware_accelerator.c31);
            check_value("Systolic c32", exp_c32, dut.u_accel_mmio.u_hardware_accelerator.c32);
            check_value("Systolic c33", exp_c33, dut.u_accel_mmio.u_hardware_accelerator.c33);
        end
    endtask

    task check_value;
        input [255:0] test_name;
        input [31:0] expected_value;
        input [31:0] actual_value;
        begin
            if (actual_value !== expected_value) begin
                error_count = error_count + 1;
                $display("FAIL: %0s expected=%h actual=%h", test_name, expected_value, actual_value);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

endmodule
