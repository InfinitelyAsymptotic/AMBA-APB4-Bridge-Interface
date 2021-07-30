module FIFO #(
 parameter DATA_WIDTH = 32,//should be data+addr+cmd+byte_en
 parameter DEPTH      = 32
)
(
 input      clk,
 input      reset,
 input  [DATA_WIDTH-1:0] datain,
 input      r_en,
 input      w_en,
 output reg [DATA_WIDTH-1:0] dataout,
 output     empty,
 output     full
);

function integer clogb2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clogb2=0; value>0; clogb2=clogb2+1) begin
            value = value >> 1;
        end
    end
endfunction

parameter WIDTH = clogb2(DEPTH);
reg [DATA_WIDTH-1:0] memory[0:DEPTH-1];
wire [WIDTH-1:0] wr_p, rd_p;
reg  [WIDTH  :0] wr_n, rd_n;
// reading data out from the FIFO
integer i;
always @(posedge clk)
  if(reset)
    dataout <= {DATA_WIDTH{1'b0}};
  else if(r_en && !empty )
    dataout <= memory[rd_p];

//writing data in the FIFO
always @(posedge clk)
  if(reset)
    for(i=0; i<DEPTH; i=i+1)
      memory[i] <= {DATA_WIDTH{1'b0}};
  else if(w_en && !full)
    memory[wr_p] <= datain;

//pointer increment system
always @(posedge clk) begin
  if(reset) begin
    wr_n <= 0;
    rd_n <= 0;
  end else begin
    if(!full && w_en)
      wr_n <= wr_n+1;
    if(!empty && r_en)
      rd_n <= rd_n+1;
  end
end

assign wr_p = wr_n[WIDTH-1:0];
assign rd_p = rd_n[WIDTH-1:0];

assign full  = (wr_p == rd_p) && (wr_n[WIDTH] != rd_n[WIDTH]);
assign empty = (wr_p == rd_p) && (wr_n[WIDTH] == rd_n[WIDTH]);

endmodule