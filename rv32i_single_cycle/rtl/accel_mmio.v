`timescale 1ns/1ps

module accel_mmio (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    localparam ACCEL_BASE_ADDR = 32'h0000_0100;

    localparam REG_CONTROL      = 8'h00;
    localparam REG_STATUS       = 8'h04;
    localparam REG_SCALAR       = 8'h08;
    localparam REG_MAC_DATA_A   = 8'h0C;
    localparam REG_MAC_DATA_B   = 8'h10;
    localparam REG_VEC_A0       = 8'h14;
    localparam REG_VEC_A1       = 8'h18;
    localparam REG_VEC_A2       = 8'h1C;
    localparam REG_VEC_A3       = 8'h20;
    localparam REG_VEC_B0       = 8'h24;
    localparam REG_VEC_B1       = 8'h28;
    localparam REG_VEC_B2       = 8'h2C;
    localparam REG_VEC_B3       = 8'h30;

    localparam REG_A00          = 8'h40;
    localparam REG_A01          = 8'h44;
    localparam REG_A02          = 8'h48;
    localparam REG_A03          = 8'h4C;
    localparam REG_A10          = 8'h50;
    localparam REG_A11          = 8'h54;
    localparam REG_A12          = 8'h58;
    localparam REG_A13          = 8'h5C;
    localparam REG_A20          = 8'h60;
    localparam REG_A21          = 8'h64;
    localparam REG_A22          = 8'h68;
    localparam REG_A23          = 8'h6C;
    localparam REG_A30          = 8'h70;
    localparam REG_A31          = 8'h74;
    localparam REG_A32          = 8'h78;
    localparam REG_A33          = 8'h7C;

    localparam REG_B00          = 8'h80;
    localparam REG_B01          = 8'h84;
    localparam REG_B02          = 8'h88;
    localparam REG_B03          = 8'h8C;
    localparam REG_B10          = 8'h90;
    localparam REG_B11          = 8'h94;
    localparam REG_B12          = 8'h98;
    localparam REG_B13          = 8'h9C;
    localparam REG_B20          = 8'hA0;
    localparam REG_B21          = 8'hA4;
    localparam REG_B22          = 8'hA8;
    localparam REG_B23          = 8'hAC;
    localparam REG_B30          = 8'hB0;
    localparam REG_B31          = 8'hB4;
    localparam REG_B32          = 8'hB8;
    localparam REG_B33          = 8'hBC;

    localparam REG_C00          = 8'hC0;
    localparam REG_C01          = 8'hC4;
    localparam REG_C02          = 8'hC8;
    localparam REG_C03          = 8'hCC;
    localparam REG_C10          = 8'hD0;
    localparam REG_C11          = 8'hD4;
    localparam REG_C12          = 8'hD8;
    localparam REG_C13          = 8'hDC;
    localparam REG_C20          = 8'hE0;
    localparam REG_C21          = 8'hE4;
    localparam REG_C22          = 8'hE8;
    localparam REG_C23          = 8'hEC;
    localparam REG_C30          = 8'hF0;
    localparam REG_C31          = 8'hF4;
    localparam REG_C32          = 8'hF8;
    localparam REG_C33          = 8'hFC;

    reg [1:0]  accel_mode;
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
    reg [15:0] a00;
    reg [15:0] a01;
    reg [15:0] a02;
    reg [15:0] a03;
    reg [15:0] a10;
    reg [15:0] a11;
    reg [15:0] a12;
    reg [15:0] a13;
    reg [15:0] a20;
    reg [15:0] a21;
    reg [15:0] a22;
    reg [15:0] a23;
    reg [15:0] a30;
    reg [15:0] a31;
    reg [15:0] a32;
    reg [15:0] a33;
    reg [15:0] b00;
    reg [15:0] b01;
    reg [15:0] b02;
    reg [15:0] b03;
    reg [15:0] b10;
    reg [15:0] b11;
    reg [15:0] b12;
    reg [15:0] b13;
    reg [15:0] b20;
    reg [15:0] b21;
    reg [15:0] b22;
    reg [15:0] b23;
    reg [15:0] b30;
    reg [15:0] b31;
    reg [15:0] b32;
    reg [15:0] b33;

    wire [31:0] accel_offset;
    wire        accel_start;
    wire        accel_clear;

    wire        accel_busy;
    wire        accel_done;
    wire [31:0] scalar_result;
    wire [31:0] c00;
    wire [31:0] c01;
    wire [31:0] c02;
    wire [31:0] c03;
    wire [31:0] c10;
    wire [31:0] c11;
    wire [31:0] c12;
    wire [31:0] c13;
    wire [31:0] c20;
    wire [31:0] c21;
    wire [31:0] c22;
    wire [31:0] c23;
    wire [31:0] c30;
    wire [31:0] c31;
    wire [31:0] c32;
    wire [31:0] c33;

    assign accel_offset = addr - ACCEL_BASE_ADDR;

    assign accel_start = mem_write && (accel_offset == REG_CONTROL) && write_data[8];
    assign accel_clear = mem_write && (accel_offset == REG_CONTROL) && write_data[9];

    hardware_accelerator u_hardware_accelerator (
        .clk(clk),
        .rst_n(rst_n),
        .start(accel_start),
        .clear(accel_clear),
        .mode(accel_mode),
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
        .busy(accel_busy),
        .done(accel_done),
        .scalar_result(scalar_result),
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accel_mode <= 2'b00;
            mac_data_a <= 16'h0000;
            mac_data_b <= 16'h0000;
            vec_a0 <= 16'h0000; vec_a1 <= 16'h0000; vec_a2 <= 16'h0000; vec_a3 <= 16'h0000;
            vec_b0 <= 16'h0000; vec_b1 <= 16'h0000; vec_b2 <= 16'h0000; vec_b3 <= 16'h0000;
            a00 <= 16'h0000; a01 <= 16'h0000; a02 <= 16'h0000; a03 <= 16'h0000;
            a10 <= 16'h0000; a11 <= 16'h0000; a12 <= 16'h0000; a13 <= 16'h0000;
            a20 <= 16'h0000; a21 <= 16'h0000; a22 <= 16'h0000; a23 <= 16'h0000;
            a30 <= 16'h0000; a31 <= 16'h0000; a32 <= 16'h0000; a33 <= 16'h0000;
            b00 <= 16'h0000; b01 <= 16'h0000; b02 <= 16'h0000; b03 <= 16'h0000;
            b10 <= 16'h0000; b11 <= 16'h0000; b12 <= 16'h0000; b13 <= 16'h0000;
            b20 <= 16'h0000; b21 <= 16'h0000; b22 <= 16'h0000; b23 <= 16'h0000;
            b30 <= 16'h0000; b31 <= 16'h0000; b32 <= 16'h0000; b33 <= 16'h0000;
        end else if (mem_write) begin
            case (accel_offset)
                REG_CONTROL:    accel_mode <= write_data[1:0];
                REG_MAC_DATA_A: mac_data_a <= write_data[15:0];
                REG_MAC_DATA_B: mac_data_b <= write_data[15:0];
                REG_VEC_A0:     vec_a0 <= write_data[15:0];
                REG_VEC_A1:     vec_a1 <= write_data[15:0];
                REG_VEC_A2:     vec_a2 <= write_data[15:0];
                REG_VEC_A3:     vec_a3 <= write_data[15:0];
                REG_VEC_B0:     vec_b0 <= write_data[15:0];
                REG_VEC_B1:     vec_b1 <= write_data[15:0];
                REG_VEC_B2:     vec_b2 <= write_data[15:0];
                REG_VEC_B3:     vec_b3 <= write_data[15:0];
                REG_A00:        a00 <= write_data[15:0];
                REG_A01:        a01 <= write_data[15:0];
                REG_A02:        a02 <= write_data[15:0];
                REG_A03:        a03 <= write_data[15:0];
                REG_A10:        a10 <= write_data[15:0];
                REG_A11:        a11 <= write_data[15:0];
                REG_A12:        a12 <= write_data[15:0];
                REG_A13:        a13 <= write_data[15:0];
                REG_A20:        a20 <= write_data[15:0];
                REG_A21:        a21 <= write_data[15:0];
                REG_A22:        a22 <= write_data[15:0];
                REG_A23:        a23 <= write_data[15:0];
                REG_A30:        a30 <= write_data[15:0];
                REG_A31:        a31 <= write_data[15:0];
                REG_A32:        a32 <= write_data[15:0];
                REG_A33:        a33 <= write_data[15:0];
                REG_B00:        b00 <= write_data[15:0];
                REG_B01:        b01 <= write_data[15:0];
                REG_B02:        b02 <= write_data[15:0];
                REG_B03:        b03 <= write_data[15:0];
                REG_B10:        b10 <= write_data[15:0];
                REG_B11:        b11 <= write_data[15:0];
                REG_B12:        b12 <= write_data[15:0];
                REG_B13:        b13 <= write_data[15:0];
                REG_B20:        b20 <= write_data[15:0];
                REG_B21:        b21 <= write_data[15:0];
                REG_B22:        b22 <= write_data[15:0];
                REG_B23:        b23 <= write_data[15:0];
                REG_B30:        b30 <= write_data[15:0];
                REG_B31:        b31 <= write_data[15:0];
                REG_B32:        b32 <= write_data[15:0];
                REG_B33:        b33 <= write_data[15:0];
                default: begin end
            endcase
        end
    end

    always @(*) begin
        read_data = 32'h0000_0000;

        if (mem_read) begin
            case (accel_offset)
                REG_CONTROL:    read_data = {30'h0000_0000, accel_mode};
                REG_STATUS:     read_data = {30'h0000_0000, accel_busy, accel_done};
                REG_SCALAR:     read_data = scalar_result;
                REG_MAC_DATA_A: read_data = {16'h0000, mac_data_a};
                REG_MAC_DATA_B: read_data = {16'h0000, mac_data_b};
                REG_VEC_A0:     read_data = {16'h0000, vec_a0};
                REG_VEC_A1:     read_data = {16'h0000, vec_a1};
                REG_VEC_A2:     read_data = {16'h0000, vec_a2};
                REG_VEC_A3:     read_data = {16'h0000, vec_a3};
                REG_VEC_B0:     read_data = {16'h0000, vec_b0};
                REG_VEC_B1:     read_data = {16'h0000, vec_b1};
                REG_VEC_B2:     read_data = {16'h0000, vec_b2};
                REG_VEC_B3:     read_data = {16'h0000, vec_b3};
                REG_A00:        read_data = {16'h0000, a00};
                REG_A01:        read_data = {16'h0000, a01};
                REG_A02:        read_data = {16'h0000, a02};
                REG_A03:        read_data = {16'h0000, a03};
                REG_A10:        read_data = {16'h0000, a10};
                REG_A11:        read_data = {16'h0000, a11};
                REG_A12:        read_data = {16'h0000, a12};
                REG_A13:        read_data = {16'h0000, a13};
                REG_A20:        read_data = {16'h0000, a20};
                REG_A21:        read_data = {16'h0000, a21};
                REG_A22:        read_data = {16'h0000, a22};
                REG_A23:        read_data = {16'h0000, a23};
                REG_A30:        read_data = {16'h0000, a30};
                REG_A31:        read_data = {16'h0000, a31};
                REG_A32:        read_data = {16'h0000, a32};
                REG_A33:        read_data = {16'h0000, a33};
                REG_B00:        read_data = {16'h0000, b00};
                REG_B01:        read_data = {16'h0000, b01};
                REG_B02:        read_data = {16'h0000, b02};
                REG_B03:        read_data = {16'h0000, b03};
                REG_B10:        read_data = {16'h0000, b10};
                REG_B11:        read_data = {16'h0000, b11};
                REG_B12:        read_data = {16'h0000, b12};
                REG_B13:        read_data = {16'h0000, b13};
                REG_B20:        read_data = {16'h0000, b20};
                REG_B21:        read_data = {16'h0000, b21};
                REG_B22:        read_data = {16'h0000, b22};
                REG_B23:        read_data = {16'h0000, b23};
                REG_B30:        read_data = {16'h0000, b30};
                REG_B31:        read_data = {16'h0000, b31};
                REG_B32:        read_data = {16'h0000, b32};
                REG_B33:        read_data = {16'h0000, b33};
                REG_C00:        read_data = c00;
                REG_C01:        read_data = c01;
                REG_C02:        read_data = c02;
                REG_C03:        read_data = c03;
                REG_C10:        read_data = c10;
                REG_C11:        read_data = c11;
                REG_C12:        read_data = c12;
                REG_C13:        read_data = c13;
                REG_C20:        read_data = c20;
                REG_C21:        read_data = c21;
                REG_C22:        read_data = c22;
                REG_C23:        read_data = c23;
                REG_C30:        read_data = c30;
                REG_C31:        read_data = c31;
                REG_C32:        read_data = c32;
                REG_C33:        read_data = c33;
                default:        read_data = 32'h0000_0000;
            endcase
        end
    end

endmodule
