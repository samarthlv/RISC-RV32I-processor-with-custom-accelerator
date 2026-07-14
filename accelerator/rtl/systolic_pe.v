`timescale 1ns/1ps

module systolic_pe (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clear,
    input  wire        enable,
    input  wire [15:0] a_in,
    input  wire [15:0] b_in,
    output reg  [15:0] a_out,
    output reg  [15:0] b_out,
    output wire [31:0] acc_out
);

    mac_unit u_mac_unit (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear),
        .enable(enable),
        .data_a(a_in),
        .data_b(b_in),
        .acc_out(acc_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 16'h0000;
            b_out <= 16'h0000;
        end else if (clear) begin
            a_out <= 16'h0000;
            b_out <= 16'h0000;
        end else if (enable) begin
            a_out <= a_in;
            b_out <= b_in;
        end
    end

endmodule
