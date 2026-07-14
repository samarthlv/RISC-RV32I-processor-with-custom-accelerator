`timescale 1ns/1ps

module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc_current
);

    // Program counter updates on the rising clock edge and resets to 0.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_current <= 32'h0000_0000;
        end else begin
            pc_current <= pc_next;
        end
    end

endmodule
