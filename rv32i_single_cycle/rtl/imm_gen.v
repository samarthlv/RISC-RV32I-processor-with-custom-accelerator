`timescale 1ns/1ps

module imm_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm_out
);

    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    always @(*) begin
        case (imm_sel)
            // I-type: imm[11:0] = instr[31:20]
            IMM_I: imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-type: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            IMM_S: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: imm[12|10:5|4:1|11|0] with bit 0 = 0
            IMM_B: imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            // U-type: imm[31:12] = instr[31:12], lower 12 bits are zero
            IMM_U: imm_out = {instr[31:12], 12'b0000_0000_0000};

            // J-type: imm[20|10:1|11|19:12|0] with bit 0 = 0
            IMM_J: imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            default: imm_out = 32'h0000_0000;
        endcase
    end

endmodule
