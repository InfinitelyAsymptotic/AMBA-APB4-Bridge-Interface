// Code your testbench here
// or browse Examples

`timescale 1ns / 10ps

module tb_apb();

function integer clogb2;
  input [31:0] value;
  begin
      value = value - 1;
      for (clogb2=0; value>0; clogb2=clogb2+1) begin
          value = value >> 1;
      end
  end
endfunction

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 10;
//FIXME - If SLV_CNT is updated, then also update
//apb_master.v and apb_slave_wrapper.v
parameter SLV_CNT    = 3;
parameter SLV_RANGE  = 256;

//CLK and RESET generation
reg clk,reset;
initial begin
  clk = 0;
  reset = 1;
  #25;
  reset = 0;
end

always #5 clk = ~clk;

//USER interface
wire full,empty;
reg [5:0] cnt;
always @(posedge clk)
  if(reset)
    cnt <= {6{1'b0}};
  else if(!full)
    cnt <= cnt + 5'b1;

wire user_en;
assign user_en = cnt[0];//cnt[1]&cnt[0];

reg [DATA_WIDTH-1:0] data;
always @(posedge user_en)
  data = $urandom;

wire [DATA_WIDTH-1:0] dataout;
wire rd_en;
FIFO u_FIFO (
            .clk     (clk),
            .reset   (reset),
            .w_en    (user_en),
            .r_en    (rd_en),
            .datain  (data),
            .dataout (dataout),
            .full    (full),
            .empty   (empty)
            );

wire PENABLE;
wire PWRITE;
wire PREADY;
wire PSLVERROR;
wire [ADDR_WIDTH-1:0] PADDR;
wire [DATA_WIDTH-1:0] PWDATA;
wire [DATA_WIDTH-1:0] PRDATA;
wire [DATA_WIDTH/8-1:0] PSTRB;
wire [SLV_CNT-1:0] PSELx;

apb_master #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .SLV_ADDR_WIDTH (clogb2(SLV_RANGE)),
    .SLV_CNT    (SLV_CNT)
    ) U_APB_MASTER (
    .PCLK       (clk),
    .PRESETn    (~reset),
    .empty      (empty),
    .fdata      ({dataout[11:8],dataout,dataout[ADDR_WIDTH-1:0], dataout[31]? 2'b01:2'b10 }),
    .rd_en      (rd_en),
    .PREADY     (PREADY),
    .PRDATA     (PRDATA),
    .PADDR      (PADDR),
    .PWDATA     (PWDATA),
    .PENABLE    (PENABLE),
    .PWRITE     (PWRITE),
    .PSTRB      (PSTRB),
    .PSELx      (PSELx)
    );

apb_slave_wrapper#(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .SLV_ADDR_WIDTH (clogb2(SLV_RANGE)),
    .SLV_CNT    (SLV_CNT)
    ) U_APB_SLAVE_WRAPPER (
    .PCLK       (clk),
    .PRESETn    (~reset),
    .PADDR      (PADDR),
    .PSELx      (PSELx),
    .PENABLE    (PENABLE),
    .PWRITE     (PWRITE),
    .PWDATA     (PWDATA),
    .PSTRB      (PSTRB),
    .PREADY     (PREADY),
    .PRDATA     (PRDATA),
    .PSLVERROR  (PSLVERROR)
   );

endmodule
