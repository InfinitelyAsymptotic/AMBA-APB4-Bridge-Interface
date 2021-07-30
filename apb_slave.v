// APB SLAVE SRAM INTERFACE
// Pranjal Joshi

module apb_slave_sram_interface ( PCLK, PRESETn, PADDR, PPROT, PSEL, PENABLE, PWRITE, PWDATA, PSTRB, PREADY, PRDATA, PSLVERR, //APB Signals
                                  mem_rvalid, mem_rdata, mem_addr, mem_write, mem_strb, mem_wdata  //SRAM MEMORY Signals 
                                );
  //parameter declarations 
  parameter DATA_WIDTH		= 32;
  parameter ADDR_WIDTH		= 8;
  parameter STRB_WIDTH		= log2(DATA_WIDTH); 
  
  //APB Slave Signals declarations 
  input 					PCLK;
  input						PRESETn;
  input	 [ADDR_WIDTH-1:0]	PADDR; 
  input 					PPROT; //TBD
  input 					PSEL;
  input						PENABLE;
  input 					PWRITE;
  input  [DATA_WIDTH-1:0]	PWDATA;
  input  [STRB_WIDTH-1:0] 	PSTRB;
  
  output reg				  PREADY;
  output reg [DATA_WIDTH-1:0] PRDATA;
  output reg 				  PSLVERR;
  
  //SRAM MEMORY Signals declarations
  input 						mem_rvalid; 
  input		 [DATA_WIDTH-1:0]   mem_rdata;
  output reg [ADDR_WIDTH-1:0]	mem_addr;
  output reg					mem_write;
  output reg [STRB_WIDTH-1:0]	mem_strb;
  output reg [DATA_WIDTH-1:0]	mem_wdata;
  
  // output reg [4:0] mem_overflow;
  // output reg [6:0] mem_write;
  //if(
  //APB SLAVE FSM declarations 
  reg [3:0] apb_slv_state;
  reg [3:0] apb_slv_nxtstate;
  
  parameter SETUP 			= 4'b0001;
  parameter WRITE_ACCESS 	= 4'b0010;
  parameter READ_ACCESS 	= 4'b0100;
  parameter SLV_ERR			= 4'b1000;
  
  always @(posedge PCLK)
  if(!PRESETn) begin
    apb_slv_state		<= SETUP;
    apb_slv_nxtstate 	<= SETUP;
  end else
    apb_slv_state	<= apb_slv_nxtstate;
                                                                                
  // SETUP -> ACCESS PHASE 
  always @(negedge PRESETn or posedge PCLK) begin
    if (PRESETn == 0) begin
      apb_slvstate	<= SETUP;
      PRDATA     	<= {DATA_WIDTH{1'b0}};
      PSLVERR  		<= 1'b0;
    end
    else begin
      case (apb_slvstate)
        SETUP : begin //at T2 clock for Slave side
          // Clear the PRDATA
          PRDATA <= {DATA_WIDTH{1'b0}};
          // Move to ACCESS when the PSEL is asserted
          if (PSEL && !PENABLE) begin
            if (PWRITE) begin
              apb_slvstate <= WRITE_ACCESS;
            end
            else begin 
              apb_slvstate <= READ_ACCESS;
            end
            PREADY <= 1'b1; //TBD for Wait states
          end
        end
        
        WRITE_ACCESS : begin //at T3 clock at Slave side 
          // write PWDATA to memory
          if (PSEL && PENABLE && PWRITE) begin
            mem_addr  <= PADDR;
            mem_write <= PWRITE;
            mem_strb  <= PSTRB;
            mem_wdata <= PWDATA;
          end
          // return to SETUP
          apb_slvstate <= SETUP;
          PREADY <= 1'b0; //TBD for Wait states
        end
        
        READ_ACCESS : begin
          // read PRDATA from memory
          if (PSEL && PENABLE && !PWRITE) begin
            mem_addr  <= PADDR;
            mem_write <= PWRITE;
            PRDATA <= mem_rdata;
        end
          // return to SETUP
          apb_slvstate <= SETUP;
          PREADY <= 1'b0; //TBD for Wait states
        end
      endcase
    end
  end 
    
  //log2uncation 
  function integer log2;
    input integer value; 
    	begin
          value = value-1;
          for (log2=0; value>0; log2=log2+1) begin
            value = value>>1;
          end //for
        end 
  endfunction
endmodule 