`timescale 1ns/1ps

module mac_unit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clear,
    input  wire        enable,
    input  wire [15:0] data_a,
    input  wire [15:0] data_b,
    output reg  [31:0] acc_out
);

    wire [31:0] mult_result;

    assign mult_result = data_a * data_b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out <= 32'h0000_0000;
        end else if (clear) begin
            acc_out <= 32'h0000_0000;
        end else if (enable) begin
            acc_out <= acc_out + mult_result;
        end
    end

endmodule
