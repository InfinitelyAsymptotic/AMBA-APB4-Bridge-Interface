// SRAM Model 
// Pranjal Joshi

module SRAM (clk,rstn,addr,read,write,byte_strb,wdata,rdata,rvalid);
  
  //parameter declarations 
  parameter DATA_WIDTH		= 32;
  parameter ADDR_WIDTH		= 8; 
  parameter STRB_WIDTH		= log2(DATA_WIDTH); 
  
  //Signals declarations 
  input							clk;
  input							rstn;
  input	 	 [ADDR_WIDTH-1:0]	addr;
  input							read;
  input 						write;
  input	 	 [STRB_WIDTH-1:0]	byte_strb;
  input	 	 [DATA_WIDTH-1:0]	wdata;
  output reg [DATA_WIDTH-1:0]   rdata;
  output reg 					rvalid;
  
  reg [DATA_WIDTH-1:0] mem_array [2**ADDR_WIDTH-1:0];
  integer i;
  
  always @(posedge clk or negedge rstn) begin
    if(rstn == 0) begin// Async reset
      for(i=0; i<2**ADDR_WIDTH; i=i+1'b1) 
        mem_array[i] <= {DATA_WIDTH{1'b0}};
        rvalid <= 1'b0;
    end else begin 
      if(write) begin // Mem write Operation 
        rvalid <=1'b0; 
        for(i=0; i<STRB_WIDTH; i=i+1'b1)
          if(byte_strb[i])
            mem_array[addr][8*i +: 8] <= wdata[8*i +: 8];   //indexed part-select i.e array[x+:y] = array [x+y-1 : x]  and array[x-:y] = array[x: x-y+1]
      end else if(read) begin //Mem Read Operation 
        rdata <= mem_array[addr] ;
        rvalid <= 1'b1; 
      end else rvalid <=1'b0;
    end //if !rst
  end //always
    
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
endmodule : SRAM  