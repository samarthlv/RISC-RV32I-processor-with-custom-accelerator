`timescale 1ns/1ps

module hardware_accelerator (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        clear,
    input  wire [1:0]  mode,

    input  wire [15:0] mac_data_a,
    input  wire [15:0] mac_data_b,

    input  wire [15:0] vec_a0,
    input  wire [15:0] vec_a1,
    input  wire [15:0] vec_a2,
    input  wire [15:0] vec_a3,
    input  wire [15:0] vec_b0,
    input  wire [15:0] vec_b1,
    input  wire [15:0] vec_b2,
    input  wire [15:0] vec_b3,

    input  wire [15:0] a00,
    input  wire [15:0] a01,
    input  wire [15:0] a02,
    input  wire [15:0] a03,
    input  wire [15:0] a10,
    input  wire [15:0] a11,
    input  wire [15:0] a12,
    input  wire [15:0] a13,
    input  wire [15:0] a20,
    input  wire [15:0] a21,
    input  wire [15:0] a22,
    input  wire [15:0] a23,
    input  wire [15:0] a30,
    input  wire [15:0] a31,
    input  wire [15:0] a32,
    input  wire [15:0] a33,
    input  wire [15:0] b00,
    input  wire [15:0] b01,
    input  wire [15:0] b02,
    input  wire [15:0] b03,
    input  wire [15:0] b10,
    input  wire [15:0] b11,
    input  wire [15:0] b12,
    input  wire [15:0] b13,
    input  wire [15:0] b20,
    input  wire [15:0] b21,
    input  wire [15:0] b22,
    input  wire [15:0] b23,
    input  wire [15:0] b30,
    input  wire [15:0] b31,
    input  wire [15:0] b32,
    input  wire [15:0] b33,

    output wire        busy,
    output wire        done,
    output wire [31:0] scalar_result,
    output wire [31:0] c00,
    output wire [31:0] c01,
    output wire [31:0] c02,
    output wire [31:0] c03,
    output wire [31:0] c10,
    output wire [31:0] c11,
    output wire [31:0] c12,
    output wire [31:0] c13,
    output wire [31:0] c20,
    output wire [31:0] c21,
    output wire [31:0] c22,
    output wire [31:0] c23,
    output wire [31:0] c30,
    output wire [31:0] c31,
    output wire [31:0] c32,
    output wire [31:0] c33
);

    localparam MODE_MAC      = 2'b00;
    localparam MODE_DOT      = 2'b01;
    localparam MODE_SYSTOLIC = 2'b10;

    wire [31:0] mac_acc_out;
    wire [31:0] dot_result;
    wire        dot_busy;
    wire        dot_done;
    wire        systolic_busy;
    wire        systolic_done;

    wire mac_clear_en;
    wire mac_enable_en;

    assign mac_clear_en  = (mode == MODE_MAC) ? clear : 1'b0;
    assign mac_enable_en = (mode == MODE_MAC) ? start : 1'b0;

    mac_unit u_mac_unit (
        .clk(clk),
        .rst_n(rst_n),
        .clear(mac_clear_en),
        .enable(mac_enable_en),
        .data_a(mac_data_a),
        .data_b(mac_data_b),
        .acc_out(mac_acc_out)
    );

    dot_product_unit u_dot_product_unit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start && (mode == MODE_DOT)),
        .vec_a0(vec_a0),
        .vec_a1(vec_a1),
        .vec_a2(vec_a2),
        .vec_a3(vec_a3),
        .vec_b0(vec_b0),
        .vec_b1(vec_b1),
        .vec_b2(vec_b2),
        .vec_b3(vec_b3),
        .busy(dot_busy),
        .done(dot_done),
        .result(dot_result)
    );

    systolic_4x4_unit u_systolic_4x4_unit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start && (mode == MODE_SYSTOLIC)),
        .a00(a00), .a01(a01), .a02(a02), .a03(a03),
        .a10(a10), .a11(a11), .a12(a12), .a13(a13),
        .a20(a20), .a21(a21), .a22(a22), .a23(a23),
        .a30(a30), .a31(a31), .a32(a32), .a33(a33),
        .b00(b00), .b01(b01), .b02(b02), .b03(b03),
        .b10(b10), .b11(b11), .b12(b12), .b13(b13),
        .b20(b20), .b21(b21), .b22(b22), .b23(b23),
        .b30(b30), .b31(b31), .b32(b32), .b33(b33),
        .busy(systolic_busy),
        .done(systolic_done),
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );

    assign scalar_result = (mode == MODE_MAC) ? mac_acc_out :
                           (mode == MODE_DOT) ? dot_result :
                           32'h0000_0000;

    assign busy = (mode == MODE_DOT) ? dot_busy :
                  (mode == MODE_SYSTOLIC) ? systolic_busy :
                  1'b0;

    // MAC mode is treated as a single-cycle accumulate command.
    assign done = (mode == MODE_MAC) ? start :
                  (mode == MODE_DOT) ? dot_done :
                  (mode == MODE_SYSTOLIC) ? systolic_done :
                  1'b0;

endmodule
