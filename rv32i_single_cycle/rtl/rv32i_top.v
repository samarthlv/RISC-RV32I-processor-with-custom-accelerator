`timescale 1ns/1ps

module rv32i_top #(
    parameter MEM_FILE = "mem/program.hex"
) (
    input wire clk,
    input wire rst_n
);

    wire [31:0] pc_current;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_next;
    wire [31:0] branch_target;

    wire [31:0] instr;

    wire [6:0]  opcode;
    wire [4:0]  rd_addr;
    wire [2:0]  funct3;
    wire [4:0]  rs1_addr;
    wire [4:0]  rs2_addr;
    wire [6:0]  funct7;

    wire        reg_write;
    wire        alu_src;
    wire        mem_read;
    wire        mem_write;
    wire        mem_to_reg;
    wire        branch_eq;
    wire        branch_ne;
    wire [2:0]  imm_sel;
    wire [2:0]  alu_ctrl;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm_out;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [31:0] data_mem_read_data;
    wire [31:0] accel_read_data;
    wire [31:0] mem_read_data;
    wire [31:0] writeback_data;
    wire        branch_taken;
    wire        accel_sel;

    assign accel_sel = (alu_result >= 32'h0000_0100) && (alu_result < 32'h0000_0200);

    assign pc_plus_4     = pc_current + 32'd4;
    assign branch_target = pc_current + imm_out;
    assign branch_taken  = (branch_eq && alu_zero) || (branch_ne && !alu_zero);
    assign pc_next       = branch_taken ? branch_target : pc_plus_4;

    assign alu_operand_b = alu_src ? imm_out : rs2_data;
    assign mem_read_data = accel_sel ? accel_read_data : data_mem_read_data;
    assign writeback_data = mem_to_reg ? mem_read_data : alu_result;

    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    instr_mem #(
        .MEM_FILE(MEM_FILE)
    ) u_instr_mem (
        .addr(pc_current),
        .instr(instr)
    );

    decoder u_decoder (
        .instr(instr),
        .opcode(opcode),
        .rd_addr(rd_addr),
        .funct3(funct3),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .funct7(funct7)
    );

    control_unit u_control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .imm_sel(imm_sel),
        .alu_ctrl(alu_ctrl)
    );

    regfile u_regfile (
        .clk(clk),
        .rst_n(rst_n),
        .we(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(writeback_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    imm_gen u_imm_gen (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );

    alu u_alu (
        .operand_a(rs1_data),
        .operand_b(alu_operand_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    data_mem u_data_mem (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read && !accel_sel),
        .mem_write(mem_write && !accel_sel),
        .addr(alu_result),
        .write_data(rs2_data),
        .read_data(data_mem_read_data)
    );

    accel_mmio u_accel_mmio (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read && accel_sel),
        .mem_write(mem_write && accel_sel),
        .addr(alu_result),
        .write_data(rs2_data),
        .read_data(accel_read_data)
    );

endmodule
