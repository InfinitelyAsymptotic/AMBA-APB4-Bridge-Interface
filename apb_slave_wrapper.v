module apb_slave_wrapper#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8,
  parameter SLV_ADDR_WIDTH = 8,
  parameter SLV_CNT    = 1
  )
  (
  input                    PCLK,
  input                    PRESETn,

  input [ADDR_WIDTH-1:0]   PADDR,
  input [SLV_CNT-1:0]      PSELx,
  input [DATA_WIDTH-1:0]   PWDATA,
  input [DATA_WIDTH/8-1:0] PSTRB,
  input                    PENABLE,
  input                    PWRITE,
  output                   PREADY,
  output [DATA_WIDTH-1:0]  PRDATA,
  output                   PSLVERROR
  );

  wire [SLV_CNT-1:0]            READY;
  wire [SLV_CNT-1:0]            SLVERROR;
  wire [SLV_CNT*DATA_WIDTH-1:0] RDATA;
  genvar i;
  generate
    for(i=0;i<SLV_CNT;i=i+1'b1) begin : SLAVE_TOP
      apb_slave_top#(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (SLV_ADDR_WIDTH)
        ) U_APB_SLAVE_TOP (
        .PCLK       (PCLK),
        .PRESETn    (PRESETn),
        .PADDR      ({SLV_ADDR_WIDTH{PSELx[i]}} & PADDR[SLV_ADDR_WIDTH-1:0]),
        .PSEL       (PSELx[i]),
        .PENABLE    (PSELx[i] & PENABLE),
        .PWRITE     (PSELx[i] & PWRITE),
        .PWDATA     ({DATA_WIDTH{PSELx[i]}} & PWDATA),
        .PSTRB      ({DATA_WIDTH/8{PSELx[i]}} & PSTRB),
        .PREADY     (READY[i]),
        .PRDATA     (RDATA[i*DATA_WIDTH +: DATA_WIDTH]),
        .SLVERROR   (SLVERROR[i])
        );
    end
  endgenerate

  reg DEC_ERROR;
  wire DEC_ERROR_i;

  assign PREADY    = |READY    | DEC_ERROR;
  assign PSLVERROR = |SLVERROR | DEC_ERROR;

  always @(posedge PCLK)
    if(!PRESETn | DEC_ERROR)
      DEC_ERROR <= 1'b0;
    else
      DEC_ERROR <= DEC_ERROR_i;

  //MAX 4 SLAVES supported
  //DECODE ERROR generation for out-of range
  generate
    if(SLV_CNT == 1) begin
      assign PRDATA = READY[0]? RDATA[0*DATA_WIDTH +: DATA_WIDTH] : {DATA_WIDTH{1'b0}};
      assign DEC_ERROR_i = PADDR>{SLV_ADDR_WIDTH{1'b1}};
    end else if(SLV_CNT == 2) begin
      assign PRDATA = READY[0]? RDATA[0*DATA_WIDTH +: DATA_WIDTH] :
                      READY[1]? RDATA[1*DATA_WIDTH +: DATA_WIDTH] : {DATA_WIDTH{1'b0}};
      assign DEC_ERROR_i = PADDR>{SLV_ADDR_WIDTH+1{1'b1}};
    end else if(SLV_CNT == 3) begin
      assign PRDATA = READY[0]? RDATA[0*DATA_WIDTH +: DATA_WIDTH] :
                      READY[1]? RDATA[1*DATA_WIDTH +: DATA_WIDTH] :
                      READY[2]? RDATA[2*DATA_WIDTH +: DATA_WIDTH] : {DATA_WIDTH{1'b0}};
      assign DEC_ERROR_i = PADDR>{SLV_ADDR_WIDTH+2{1'b1}};
    end else if(SLV_CNT == 4) begin
      assign PRDATA = READY[0]? RDATA[0*DATA_WIDTH +: DATA_WIDTH] :
                      READY[1]? RDATA[1*DATA_WIDTH +: DATA_WIDTH] :
                      READY[2]? RDATA[2*DATA_WIDTH +: DATA_WIDTH] :
                      READY[3]? RDATA[3*DATA_WIDTH +: DATA_WIDTH] : {DATA_WIDTH{1'b0}};
      assign DEC_ERROR_i = PADDR>{SLV_ADDR_WIDTH+3{1'b1}};
    end
  endgenerate

endmodule
