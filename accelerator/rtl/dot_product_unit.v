`timescale 1ns/1ps

module dot_product_unit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] vec_a0,
    input  wire [15:0] vec_a1,
    input  wire [15:0] vec_a2,
    input  wire [15:0] vec_a3,
    input  wire [15:0] vec_b0,
    input  wire [15:0] vec_b1,
    input  wire [15:0] vec_b2,
    input  wire [15:0] vec_b3,
    output reg         busy,
    output reg         done,
    output reg  [31:0] result
);

    reg [1:0] index;
    reg [15:0] current_a;
    reg [15:0] current_b;
    reg         mac_clear;
    reg         mac_enable;
    wire [31:0] mac_acc_out;
    wire [31:0] current_product;

    mac_unit u_mac_unit (
        .clk(clk),
        .rst_n(rst_n),
        .clear(mac_clear),
        .enable(mac_enable),
        .data_a(current_a),
        .data_b(current_b),
        .acc_out(mac_acc_out)
    );

    assign current_product = current_a * current_b;

    always @(*) begin
        case (index)
            2'd0: begin
                current_a = vec_a0;
                current_b = vec_b0;
            end
            2'd1: begin
                current_a = vec_a1;
                current_b = vec_b1;
            end
            2'd2: begin
                current_a = vec_a2;
                current_b = vec_b2;
            end
            default: begin
                current_a = vec_a3;
                current_b = vec_b3;
            end
        endcase
    end

    always @(*) begin
        mac_clear  = 1'b0;
        mac_enable = 1'b0;

        if (start && !busy) begin
            mac_clear = 1'b1;
        end else if (busy) begin
            mac_enable = 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            index  <= 2'd0;
            result <= 32'h0000_0000;
            busy   <= 1'b0;
            done   <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                index  <= 2'd0;
                result <= 32'h0000_0000;
                busy   <= 1'b1;
            end else if (busy) begin
                if (index == 2'd3) begin
                    result <= mac_acc_out + current_product;
                    index  <= 2'd0;
                    busy   <= 1'b0;
                    done   <= 1'b1;
                end else begin
                    index <= index + 2'd1;
                end
            end
        end
    end

endmodule
