`timescale 1ns/1ps

module data_mem #(
    parameter MEM_DEPTH = 256
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] mem_array [0:MEM_DEPTH-1];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                mem_array[i] <= 32'h0000_0000;
            end
        end else if (mem_write) begin
            mem_array[addr[31:2]] <= write_data;
        end
    end

    // Only word-aligned 32-bit loads are supported in Phase 1.
    assign read_data = mem_read ? mem_array[addr[31:2]] : 32'h0000_0000;

endmodule
