module apb_master#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8,
  parameter SLV_ADDR_WIDTH = 8,
  parameter SLV_CNT    = 1
  )
  (
  input                         PCLK,
  input                         PRESETn,
  // From FIFO
  input                         empty,
  input [2+ADDR_WIDTH+DATA_WIDTH+DATA_WIDTH/8-1:0] fdata,
  output reg                    rd_en,
  // To APB SLAVE
  input                         PREADY,
  input [DATA_WIDTH-1:0]        PRDATA,
  output reg [ADDR_WIDTH-1:0]   PADDR,
  output reg [DATA_WIDTH-1:0]   PWDATA,
  output reg                    PENABLE,
  output reg                    PWRITE,
  output reg [DATA_WIDTH/8-1:0] PSTRB,
  output reg [SLV_CNT-1:0]      PSELx
  );

parameter TMP = SLV_ADDR_WIDTH;

parameter F_IDLE = 2'b00;
parameter F_WAIT = 2'b01;
parameter IDLE   = 2'b10;
parameter ENABLE = 2'b11;

wire [ADDR_WIDTH-1:0]   addr;
wire [DATA_WIDTH-1:0]   data;
wire [DATA_WIDTH/8-1:0] byte_en;
wire rd,wr;
reg fvalid;

assign {byte_en,data,addr,rd,wr} = fvalid? fdata : {2+ADDR_WIDTH+DATA_WIDTH+DATA_WIDTH/8{1'b0}};

reg [1:0] fifo_state;
reg [1:0] fifo_nxt_state;
reg [1:0] state;
reg [1:0] nxt_state;

always @(posedge PCLK)
  if(!PRESETn) begin
    fifo_state      <= F_IDLE;
    fifo_nxt_state  <= F_IDLE;
    state           <= IDLE;
    nxt_state       <= IDLE;
    fvalid          <= 1'b0;
  end else begin
    fifo_state      <= fifo_nxt_state;
    state           <= nxt_state;
    fvalid          <= rd_en;
  end

//FIFO FSM
always @(*)  begin
  case(fifo_state)
  F_IDLE: begin
            if(!empty) begin
              rd_en = 1'b1;
              fifo_nxt_state = F_WAIT;
            end else begin
              fifo_nxt_state = F_IDLE;
              rd_en = 1'b0;
            end
          end
  F_WAIT: begin
            rd_en = 1'b0;
            if(PREADY)
              fifo_nxt_state = F_IDLE;
          end
  default : fifo_nxt_state = F_IDLE;
  endcase
end

// APB MASTER FSM
always @(*) begin
  case(state)
    IDLE: begin
            if(!PRESETn) begin
              PSELx    = {SLV_CNT{1'b0}};
              PADDR    = {ADDR_WIDTH{1'b0}};
              PENABLE  = 1'b0;
              PWDATA   = {DATA_WIDTH{1'b0}};
              PWRITE   = 1'b0;
              PSTRB    = {DATA_WIDTH/8{1'b0}};
            end else if(wr|rd) begin
              PSELx    = {SLV_CNT{1'b0}};
              //PSELx    = addr[9]? 3'b100: addr[8]? 3'b010 : 3'b001; //FIXME
              PSELx    = {addr[9],!addr[9]&addr[8],!addr[9]&!addr[8]}; //FIXME
              PADDR    = addr;
              PENABLE  = 1'b0;
              if(wr) begin
                PWDATA   = data;
                PWRITE   = 1'b1;
                PSTRB    = byte_en;
              end
              nxt_state= ENABLE;
            end else begin
              PSELx    = {SLV_CNT{1'b0}};
              PADDR    = {ADDR_WIDTH{1'b0}};
              PENABLE  = 1'b0;
              PWDATA   = {DATA_WIDTH{1'b0}};
              PWRITE   = 1'b0;
              PSTRB    = {DATA_WIDTH/8{1'b0}};
            end
          end

    ENABLE: begin
             PENABLE  = 1'b1;
             if(PREADY) begin
               nxt_state= IDLE;
             end else begin
               nxt_state= ENABLE;
             end
           end

    default : nxt_state = IDLE;
  endcase
end


endmodule
