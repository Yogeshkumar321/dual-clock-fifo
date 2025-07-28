`timescale 1ns/1ps

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg wr_clk, rd_clk, rst_n;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    async_fifo #(DATA_WIDTH, ADDR_WIDTH) uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    initial begin
        wr_clk = 0; forever #5 wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 0; forever #8 rd_clk = ~rd_clk;
    end

    initial begin
        rst_n = 0; wr_en = 0; rd_en = 0; din = 0;
        #20 rst_n = 1;

        repeat(8) begin
            @(posedge wr_clk);
            wr_en = 1; din = $random;
        end
        wr_en = 0;

        repeat(8) begin
            @(posedge rd_clk);
            rd_en = 1;
        end
        rd_en = 0;

        #100 $finish;
    end

endmodule
