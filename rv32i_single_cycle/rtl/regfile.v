`timescale 1ns/1ps

module regfile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,                  // write enable
    input  wire [4:0]  rs1_addr,           // read address 1
    input  wire [4:0]  rs2_addr,           // read address 2
    input  wire [4:0]  rd_addr,            // write address
    input  wire [31:0] rd_data,            // write data input
    output wire [31:0] rs1_data,           // read data 1
    output wire [31:0] rs2_data            // read data 2
);

    reg [31:0] registers [0:31];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end else if (we && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 : registers[rs2_addr];

endmodule
