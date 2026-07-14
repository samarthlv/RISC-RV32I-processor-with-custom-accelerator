`timescale 1ns/1ps

module systolic_4x4_unit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
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
    output reg         busy,
    output reg         done,
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

    reg [3:0] cycle_count;
    reg       pe_clear;
    reg       pe_enable;

    reg [15:0] left_in0;
    reg [15:0] left_in1;
    reg [15:0] left_in2;
    reg [15:0] left_in3;
    reg [15:0] top_in0;
    reg [15:0] top_in1;
    reg [15:0] top_in2;
    reg [15:0] top_in3;

    wire [15:0] a_wire_00;
    wire [15:0] a_wire_01;
    wire [15:0] a_wire_02;
    wire [15:0] a_wire_10;
    wire [15:0] a_wire_11;
    wire [15:0] a_wire_12;
    wire [15:0] a_wire_20;
    wire [15:0] a_wire_21;
    wire [15:0] a_wire_22;
    wire [15:0] a_wire_30;
    wire [15:0] a_wire_31;
    wire [15:0] a_wire_32;

    wire [15:0] b_wire_00;
    wire [15:0] b_wire_01;
    wire [15:0] b_wire_02;
    wire [15:0] b_wire_03;
    wire [15:0] b_wire_10;
    wire [15:0] b_wire_11;
    wire [15:0] b_wire_12;
    wire [15:0] b_wire_13;
    wire [15:0] b_wire_20;
    wire [15:0] b_wire_21;
    wire [15:0] b_wire_22;
    wire [15:0] b_wire_23;

    always @(*) begin
        pe_clear  = 1'b0;
        pe_enable = 1'b0;

        if (start && !busy) begin
            pe_clear = 1'b1;
        end else if (busy) begin
            pe_enable = 1'b1;
        end
    end

    always @(*) begin
        left_in0 = 16'h0000;
        left_in1 = 16'h0000;
        left_in2 = 16'h0000;
        left_in3 = 16'h0000;
        top_in0  = 16'h0000;
        top_in1  = 16'h0000;
        top_in2  = 16'h0000;
        top_in3  = 16'h0000;

        case (cycle_count)
            4'd0: begin
                left_in0 = a00;
                top_in0  = b00;
            end
            4'd1: begin
                left_in0 = a01;
                left_in1 = a10;
                top_in0  = b10;
                top_in1  = b01;
            end
            4'd2: begin
                left_in0 = a02;
                left_in1 = a11;
                left_in2 = a20;
                top_in0  = b20;
                top_in1  = b11;
                top_in2  = b02;
            end
            4'd3: begin
                left_in0 = a03;
                left_in1 = a12;
                left_in2 = a21;
                left_in3 = a30;
                top_in0  = b30;
                top_in1  = b21;
                top_in2  = b12;
                top_in3  = b03;
            end
            4'd4: begin
                left_in1 = a13;
                left_in2 = a22;
                left_in3 = a31;
                top_in1  = b31;
                top_in2  = b22;
                top_in3  = b13;
            end
            4'd5: begin
                left_in2 = a23;
                left_in3 = a32;
                top_in2  = b32;
                top_in3  = b23;
            end
            4'd6: begin
                left_in3 = a33;
                top_in3  = b33;
            end
            default: begin
                left_in0 = 16'h0000;
                left_in1 = 16'h0000;
                left_in2 = 16'h0000;
                left_in3 = 16'h0000;
                top_in0  = 16'h0000;
                top_in1  = 16'h0000;
                top_in2  = 16'h0000;
                top_in3  = 16'h0000;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count <= 4'd0;
            busy        <= 1'b0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                cycle_count <= 4'd0;
                busy        <= 1'b1;
            end else if (busy) begin
                if (cycle_count == 4'd9) begin
                    cycle_count <= 4'd0;
                    busy        <= 1'b0;
                    done        <= 1'b1;
                end else begin
                    cycle_count <= cycle_count + 4'd1;
                end
            end
        end
    end

    systolic_pe pe00 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(left_in0),  .b_in(top_in0),  .a_out(a_wire_00), .b_out(b_wire_00), .acc_out(c00));
    systolic_pe pe01 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_00),  .b_in(top_in1),  .a_out(a_wire_01), .b_out(b_wire_01), .acc_out(c01));
    systolic_pe pe02 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_01),  .b_in(top_in2),  .a_out(a_wire_02), .b_out(b_wire_02), .acc_out(c02));
    systolic_pe pe03 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_02),  .b_in(top_in3),  .a_out(),          .b_out(b_wire_03), .acc_out(c03));

    systolic_pe pe10 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(left_in1),  .b_in(b_wire_00), .a_out(a_wire_10), .b_out(b_wire_10), .acc_out(c10));
    systolic_pe pe11 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_10),  .b_in(b_wire_01), .a_out(a_wire_11), .b_out(b_wire_11), .acc_out(c11));
    systolic_pe pe12 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_11),  .b_in(b_wire_02), .a_out(a_wire_12), .b_out(b_wire_12), .acc_out(c12));
    systolic_pe pe13 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_12),  .b_in(b_wire_03), .a_out(),          .b_out(b_wire_13), .acc_out(c13));

    systolic_pe pe20 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(left_in2),  .b_in(b_wire_10), .a_out(a_wire_20), .b_out(b_wire_20), .acc_out(c20));
    systolic_pe pe21 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_20),  .b_in(b_wire_11), .a_out(a_wire_21), .b_out(b_wire_21), .acc_out(c21));
    systolic_pe pe22 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_21),  .b_in(b_wire_12), .a_out(a_wire_22), .b_out(b_wire_22), .acc_out(c22));
    systolic_pe pe23 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_22),  .b_in(b_wire_13), .a_out(),          .b_out(b_wire_23), .acc_out(c23));

    systolic_pe pe30 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(left_in3),  .b_in(b_wire_20), .a_out(a_wire_30), .b_out(),          .acc_out(c30));
    systolic_pe pe31 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_30),  .b_in(b_wire_21), .a_out(a_wire_31), .b_out(),          .acc_out(c31));
    systolic_pe pe32 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_31),  .b_in(b_wire_22), .a_out(a_wire_32), .b_out(),          .acc_out(c32));
    systolic_pe pe33 (.clk(clk), .rst_n(rst_n), .clear(pe_clear), .enable(pe_enable), .a_in(a_wire_32),  .b_in(b_wire_23), .a_out(),          .b_out(),          .acc_out(c33));

endmodule
