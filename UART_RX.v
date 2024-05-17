// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217
 
module UART_RX
  #(parameter CLKS_PER_BIT = 434)
  (
   input        i_Clock,
   input        i_RX,
   output       o_RX_DV,
   output [7:0] o_RX_Data
   );
   
  parameter IDLE         = 3'b000;
  parameter RX_START_BIT = 3'b001;
  parameter RX_DATA_BITS = 3'b010;
  parameter RX_STOP_BIT  = 3'b011;
  parameter DONE      	 = 3'b100;
   
  reg [7:0] bit_count     = 0;
  reg [2:0] bit_index     = 0; 
  reg [7:0] r_RX_Data     = 0;
  reg       r_RX_DV       = 0;
  reg [2:0] currentstate  = 0;
    
  assign o_RX_DV   = r_RX_DV;
  assign o_RX_Data = r_RX_Data;
  

  always @(posedge i_Clock)
  begin
      
    case (currentstate)
      IDLE :
        begin
          r_RX_DV       <= 1'b0;
          bit_count 	<= 0;
          bit_index   	<= 0;
          
          if (i_RX == 1'b0)          // Start bit detected
            currentstate <= RX_START_BIT;
          else
            currentstate <= IDLE;
        end
      
    
      RX_START_BIT :
        begin
          if (bit_count == (CLKS_PER_BIT-1)/2)
          begin
            if (i_RX == 1'b0)
            begin
              bit_count <= 0;  
              currentstate     <= RX_DATA_BITS;
            end
            else
              currentstate <= IDLE;
          end
          else
          begin
            bit_count 		 <= bit_count + 1;
            currentstate     <= RX_START_BIT;
          end
        end // case: RX_START_BIT
      
      
   
      RX_DATA_BITS :
        begin
          if (bit_count < CLKS_PER_BIT-1)
          begin
            bit_count <= bit_count + 1;
            currentstate     <= RX_DATA_BITS;
          end
          else
          begin
            bit_count            <= 0;
            r_RX_Data[bit_index] <= i_RX;
            
            if (bit_index < 7)
            begin
              bit_index 	 <= bit_index + 1;
              currentstate   <= RX_DATA_BITS;
            end
            else
            begin
              bit_index <= 0;
              currentstate   <= RX_STOP_BIT;
            end
          end
        end // case: RX_DATA_BITS
      
      
  
      RX_STOP_BIT :
        begin
          
          if (bit_count < CLKS_PER_BIT-1)
          begin
            bit_count   	 <= bit_count + 1;
     	    currentstate     <= RX_STOP_BIT;
          end
          else
          begin
       	    r_RX_DV         <= 1'b1;
            bit_count 		<= 0;
            currentstate    <= DONE;
          end
        end // case: RX_STOP_BIT
      
      
      // Stay here 1 clock
      DONE :
        begin
          currentstate  <= IDLE;
          r_RX_DV   	<= 1'b0;
        end
      
      
      default :
        currentstate <= IDLE;
      
    endcase
  end    

  
endmodule // UART_RX

