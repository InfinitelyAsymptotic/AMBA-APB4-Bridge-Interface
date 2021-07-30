
module apb_slave_top#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8
  )
  (
  input                     PCLK,
  input                     PRESETn,

  input  [ADDR_WIDTH-1:0]   PADDR,
  input                     PSEL,
  input                     PENABLE,
  input                     PWRITE,
  input  [DATA_WIDTH-1:0]   PWDATA,
  input  [DATA_WIDTH/8-1:0] PSTRB,
  output                    PREADY,
  output [DATA_WIDTH-1:0]   PRDATA,
  output                    SLVERROR
  );

  wire wr, rd;
  wire wdone, rvalid;
  wire [ADDR_WIDTH-1:0]   addr;
  wire [DATA_WIDTH-1:0]   wdata;
  wire [DATA_WIDTH/8-1:0] byte_en;
  wire [DATA_WIDTH-1:0]   rdata;

  apb_slave#(
      .DATA_WIDTH (DATA_WIDTH),
      .ADDR_WIDTH (ADDR_WIDTH)
      ) U_APB_SLAVE (
      .PCLK       (PCLK),
      .PRESETn    (PRESETn),
      .PADDR      (PADDR),
      .PSEL       (PSEL),
      .PENABLE    (PENABLE),
      .PWRITE     (PWRITE),
      .PWDATA     (PWDATA),
      .PSTRB      (PSTRB),
      .PREADY     (PREADY),
      .PRDATA     (PRDATA),
      .SLVERROR   (SLVERROR),
      .wr         (wr),
      .rd         (rd),
      .addr       (addr),
      .wdata      (wdata),
      .byte_en    (byte_en),
      .wdone      (wdone),
      .rvalid     (rvalid),
      .rdata      (rdata)
      );

  SRAM#(
      .DATA_WIDTH (DATA_WIDTH),
      .ADDR_WIDTH (ADDR_WIDTH)
      ) U_SRAM (
      .clk        (PCLK),
      .rstn       (PRESETn),
      .wr         (wr),
      .rd         (rd),
      .addr       (addr),
      .wdata      (wdata),
      .byte_en    (byte_en),
      .wdone      (wdone),
      .rvalid     (rvalid),
      .rdata      (rdata)
      );

endmodule