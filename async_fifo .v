module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wire wr_clk,
    input wire rd_clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr_bin, rd_ptr_bin;
    reg [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

    always @(posedge wr_clk or negedge rst_n) begin
        if(!rst_n)
            wr_ptr_bin <= 0;
        else if(wr_en && !full)
            wr_ptr_bin <= wr_ptr_bin + 1;
    end

    always @(*) wr_ptr_gray = wr_ptr_bin ^ (wr_ptr_bin >> 1);

    always @(posedge rd_clk or negedge rst_n) begin
        if(!rst_n)
            rd_ptr_bin <= 0;
        else if(rd_en && !empty)
            rd_ptr_bin <= rd_ptr_bin + 1;
    end

    always @(*) rd_ptr_gray = rd_ptr_bin ^ (rd_ptr_bin >> 1);

    always @(posedge wr_clk or negedge rst_n) begin
        if(!rst_n) {rd_ptr_gray_sync2, rd_ptr_gray_sync1} <= 0;
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    always @(posedge rd_clk or negedge rst_n) begin
        if(!rst_n) {wr_ptr_gray_sync2, wr_ptr_gray_sync1} <= 0;
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    always @(posedge wr_clk) begin
        if(wr_en && !full)
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
    end

    always @(posedge rd_clk) begin
        if(rd_en && !empty)
            dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
    end

    assign full  = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});
    assign empty = (wr_ptr_gray_sync2 == rd_ptr_gray);

endmodule
