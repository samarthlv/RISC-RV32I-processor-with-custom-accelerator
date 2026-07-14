`timescale 1ns/1ps

module instr_mem #(
    parameter MEM_DEPTH = 256,
    parameter MEM_FILE  = "mem/program.hex"
) (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem_array [0:MEM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem_array[i] = 32'h0000_0013;
        end
        $readmemh(MEM_FILE, mem_array);
    end

    // RV32I instructions are 32-bit aligned, so addr[31:2] selects the word.
    assign instr = mem_array[addr[31:2]];

endmodule
