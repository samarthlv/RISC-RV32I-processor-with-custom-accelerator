`timescale 1ns/1ps

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch_eq,
    output reg        branch_ne,
    output reg  [2:0] imm_sel,
    output reg  [2:0] alu_ctrl
);

    localparam OPCODE_R_TYPE = 7'b0110011;
    localparam OPCODE_I_TYPE = 7'b0010011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_BRANCH = 7'b1100011;

    localparam FUNCT3_ADD_SUB = 3'b000;
    localparam FUNCT3_XOR     = 3'b100;
    localparam FUNCT3_OR      = 3'b110;
    localparam FUNCT3_AND     = 3'b111;
    localparam FUNCT3_LW_SW   = 3'b010;
    localparam FUNCT3_BEQ     = 3'b000;
    localparam FUNCT3_BNE     = 3'b001;

    localparam FUNCT7_ADD = 7'b0000000;
    localparam FUNCT7_SUB = 7'b0100000;

    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_XOR = 3'b100;

    always @(*) begin
        reg_write = 1'b0;
        alu_src   = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        branch_eq = 1'b0;
        branch_ne = 1'b0;
        imm_sel   = IMM_I;
        alu_ctrl  = ALU_ADD;

        case (opcode)
            OPCODE_R_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;

                case (funct3)
                    FUNCT3_ADD_SUB: begin
                        if (funct7 == FUNCT7_SUB) begin
                            alu_ctrl = ALU_SUB;
                        end else begin
                            alu_ctrl = ALU_ADD;
                        end
                    end
                    FUNCT3_AND: alu_ctrl = ALU_AND;
                    FUNCT3_OR : alu_ctrl = ALU_OR;
                    FUNCT3_XOR: alu_ctrl = ALU_XOR;
                    default   : alu_ctrl = ALU_ADD;
                endcase
            end

            OPCODE_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = IMM_I;

                case (funct3)
                    FUNCT3_ADD_SUB: alu_ctrl = ALU_ADD;
                    FUNCT3_AND    : alu_ctrl = ALU_AND;
                    FUNCT3_OR     : alu_ctrl = ALU_OR;
                    default       : alu_ctrl = ALU_ADD;
                endcase
            end

            OPCODE_LOAD: begin
                if (funct3 == FUNCT3_LW_SW) begin
                    reg_write = 1'b1;
                    alu_src    = 1'b1;
                    mem_read   = 1'b1;
                    mem_to_reg = 1'b1;
                    imm_sel    = IMM_I;
                    alu_ctrl   = ALU_ADD;
                end
            end

            OPCODE_STORE: begin
                if (funct3 == FUNCT3_LW_SW) begin
                    alu_src   = 1'b1;
                    mem_write = 1'b1;
                    imm_sel   = IMM_S;
                    alu_ctrl  = ALU_ADD;
                end
            end

            OPCODE_BRANCH: begin
                alu_src  = 1'b0;
                imm_sel  = IMM_B;
                alu_ctrl = ALU_SUB;

                if (funct3 == FUNCT3_BEQ) begin
                    branch_eq = 1'b1;
                end else if (funct3 == FUNCT3_BNE) begin
                    branch_ne = 1'b1;
                end
            end

            default: begin
                reg_write = 1'b0;
                alu_src   = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                branch_eq = 1'b0;
                branch_ne = 1'b0;
                imm_sel   = IMM_I;
                alu_ctrl  = ALU_ADD;
            end
        endcase
    end

endmodule
