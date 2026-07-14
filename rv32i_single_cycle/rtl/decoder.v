`timescale 1ns/1ps

module decoder (
    input  wire [31:0] instr,
    output wire [6:0]  opcode,
    output wire [4:0]  rd_addr,
    output wire [2:0]  funct3,
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [6:0]  funct7
);

    // RV32I base instruction field positions.
    assign opcode   = instr[6:0];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign funct7   = instr[31:25];

endmodule
