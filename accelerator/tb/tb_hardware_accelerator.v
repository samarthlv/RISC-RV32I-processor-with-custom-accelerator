`timescale 1ns/1ps

module tb_hardware_accelerator;

    reg clk;
    reg rst_n;
    reg start;
    reg clear;
    reg [1:0] mode;

    reg [15:0] mac_data_a;
    reg [15:0] mac_data_b;

    reg [15:0] vec_a0;
    reg [15:0] vec_a1;
    reg [15:0] vec_a2;
    reg [15:0] vec_a3;
    reg [15:0] vec_b0;
    reg [15:0] vec_b1;
    reg [15:0] vec_b2;
    reg [15:0] vec_b3;

    reg [15:0] a00; reg [15:0] a01; reg [15:0] a02; reg [15:0] a03;
    reg [15:0] a10; reg [15:0] a11; reg [15:0] a12; reg [15:0] a13;
    reg [15:0] a20; reg [15:0] a21; reg [15:0] a22; reg [15:0] a23;
    reg [15:0] a30; reg [15:0] a31; reg [15:0] a32; reg [15:0] a33;

    reg [15:0] b00; reg [15:0] b01; reg [15:0] b02; reg [15:0] b03;
    reg [15:0] b10; reg [15:0] b11; reg [15:0] b12; reg [15:0] b13;
    reg [15:0] b20; reg [15:0] b21; reg [15:0] b22; reg [15:0] b23;
    reg [15:0] b30; reg [15:0] b31; reg [15:0] b32; reg [15:0] b33;

    wire busy;
    wire done;
    wire [31:0] scalar_result;
    wire [31:0] c00; wire [31:0] c01; wire [31:0] c02; wire [31:0] c03;
    wire [31:0] c10; wire [31:0] c11; wire [31:0] c12; wire [31:0] c13;
    wire [31:0] c20; wire [31:0] c21; wire [31:0] c22; wire [31:0] c23;
    wire [31:0] c30; wire [31:0] c31; wire [31:0] c32; wire [31:0] c33;

    integer error_count;

    hardware_accelerator dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .clear(clear),
        .mode(mode),
        .mac_data_a(mac_data_a),
        .mac_data_b(mac_data_b),
        .vec_a0(vec_a0), .vec_a1(vec_a1), .vec_a2(vec_a2), .vec_a3(vec_a3),
        .vec_b0(vec_b0), .vec_b1(vec_b1), .vec_b2(vec_b2), .vec_b3(vec_b3),
        .a00(a00), .a01(a01), .a02(a02), .a03(a03),
        .a10(a10), .a11(a11), .a12(a12), .a13(a13),
        .a20(a20), .a21(a21), .a22(a22), .a23(a23),
        .a30(a30), .a31(a31), .a32(a32), .a33(a33),
        .b00(b00), .b01(b01), .b02(b02), .b03(b03),
        .b10(b10), .b11(b11), .b12(b12), .b13(b13),
        .b20(b20), .b21(b21), .b22(b22), .b23(b23),
        .b30(b30), .b31(b31), .b32(b32), .b33(b33),
        .busy(busy),
        .done(done),
        .scalar_result(scalar_result),
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        clear = 1'b0;
        mode  = 2'b00;
        mac_data_a = 16'd0;
        mac_data_b = 16'd0;
        vec_a0 = 16'd0; vec_a1 = 16'd0; vec_a2 = 16'd0; vec_a3 = 16'd0;
        vec_b0 = 16'd0; vec_b1 = 16'd0; vec_b2 = 16'd0; vec_b3 = 16'd0;
        clear_matrices;
        error_count = 0;

        $dumpfile("tb_hardware_accelerator.vcd");
        $dumpvars(0, tb_hardware_accelerator);

        #12;
        rst_n = 1'b1;

        run_mac_test;
        run_dot_test;
        run_systolic_test;

        if (error_count == 0) begin
            $display("TEST PASSED: hardware accelerator modes verified.");
        end else begin
            $display("TEST FAILED: %0d accelerator checks failed.", error_count);
        end

        $finish;
    end

    task pulse_start;
        begin
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
        end
    endtask

    task clear_matrices;
        begin
            a00 = 0; a01 = 0; a02 = 0; a03 = 0;
            a10 = 0; a11 = 0; a12 = 0; a13 = 0;
            a20 = 0; a21 = 0; a22 = 0; a23 = 0;
            a30 = 0; a31 = 0; a32 = 0; a33 = 0;
            b00 = 0; b01 = 0; b02 = 0; b03 = 0;
            b10 = 0; b11 = 0; b12 = 0; b13 = 0;
            b20 = 0; b21 = 0; b22 = 0; b23 = 0;
            b30 = 0; b31 = 0; b32 = 0; b33 = 0;
        end
    endtask

    task run_mac_test;
        begin
            $display("Running MAC mode test...");
            mode = 2'b00;

            @(negedge clk);
            clear = 1'b1;
            @(negedge clk);
            clear = 1'b0;

            mac_data_a = 16'd3;
            mac_data_b = 16'd4;
            pulse_start;

            mac_data_a = 16'd2;
            mac_data_b = 16'd5;
            pulse_start;

            @(posedge clk);
            check_value("MAC scalar_result", 32'd22, scalar_result);
        end
    endtask

    task run_dot_test;
        begin
            $display("Running dot-product mode test...");
            mode = 2'b01;
            vec_a0 = 16'd1; vec_a1 = 16'd2; vec_a2 = 16'd3; vec_a3 = 16'd4;
            vec_b0 = 16'd5; vec_b1 = 16'd6; vec_b2 = 16'd7; vec_b3 = 16'd8;

            pulse_start;
            wait (done == 1'b1);
            #1;

            check_value("Dot scalar_result", 32'd70, scalar_result);
        end
    endtask

    task run_systolic_test;
        begin
            $display("Running systolic mode test...");
            mode = 2'b10;

            a00 = 16'd1; a01 = 16'd2; a02 = 16'd3; a03 = 16'd4;
            a10 = 16'd2; a11 = 16'd1; a12 = 16'd1; a13 = 16'd2;
            a20 = 16'd3; a21 = 16'd2; a22 = 16'd1; a23 = 16'd1;
            a30 = 16'd1; a31 = 16'd1; a32 = 16'd2; a33 = 16'd3;

            b00 = 16'd1; b01 = 16'd2; b02 = 16'd1; b03 = 16'd0;
            b10 = 16'd2; b11 = 16'd1; b12 = 16'd0; b13 = 16'd1;
            b20 = 16'd1; b21 = 16'd0; b22 = 16'd2; b23 = 16'd2;
            b30 = 16'd0; b31 = 16'd1; b32 = 16'd2; b33 = 16'd1;

            pulse_start;
            wait (done == 1'b1);
            #1;

            check_value("Systolic c00", 32'd8,  c00);
            check_value("Systolic c01", 32'd8,  c01);
            check_value("Systolic c02", 32'd15, c02);
            check_value("Systolic c03", 32'd12, c03);
            check_value("Systolic c10", 32'd5,  c10);
            check_value("Systolic c11", 32'd7,  c11);
            check_value("Systolic c12", 32'd8,  c12);
            check_value("Systolic c13", 32'd5,  c13);
            check_value("Systolic c20", 32'd8,  c20);
            check_value("Systolic c21", 32'd9,  c21);
            check_value("Systolic c22", 32'd7,  c22);
            check_value("Systolic c23", 32'd5,  c23);
            check_value("Systolic c30", 32'd5,  c30);
            check_value("Systolic c31", 32'd6,  c31);
            check_value("Systolic c32", 32'd11, c32);
            check_value("Systolic c33", 32'd8,  c33);
        end
    endtask

    task check_value;
        input [255:0] test_name;
        input [31:0] expected_value;
        input [31:0] actual_value;
        begin
            if (actual_value !== expected_value) begin
                error_count = error_count + 1;
                $display("FAIL: %0s expected=%0d actual=%0d", test_name, expected_value, actual_value);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

endmodule
