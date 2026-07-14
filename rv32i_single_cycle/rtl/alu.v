`timescale 1ns/1ps

module alu (
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_XOR = 3'b100;

    always @(*) begin
        case (alu_ctrl)
            ALU_ADD: result = operand_a + operand_b;
            ALU_SUB: result = operand_a - operand_b;
            ALU_AND: result = operand_a & operand_b;
            ALU_OR : result = operand_a | operand_b;
            ALU_XOR: result = operand_a ^ operand_b;
            default: result = 32'h0000_0000;
        endcase
    end

    // Zero flag is useful for BEQ/BNE comparisons in the next stage.
    assign zero = (result == 32'h0000_0000);

endmodule
