// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217
 
module UART_TX 
  #(parameter CLKS_PER_BIT = 434)
  (
   input       i_enable, // KEY [0]
   input       i_Clock, 
   input       i_start, //KEY [1]
   input [7:0] i_data, //SW[7:0]
   output reg  o_TX_Active,
   output reg  o_TX,
   output reg  o_TX_Done
   );
 
  localparam IDLE         = 3'b000;
  localparam TX_START_BIT = 3'b001;
  localparam TX_DATA_BITS = 3'b010;
  localparam TX_STOP_BIT  = 3'b011;
  
  reg [2:0] currentstate;
  reg [7:0] bit_counter;
  reg [2:0] bit_index;
  reg [7:0] r_TX_Data;


  always @(posedge i_Clock or negedge i_enable)
  begin
    if (!i_enable )
    begin
      bit_counter <= 0;
      bit_index   <= 0;
      r_TX_Data   <= 0;
      currentstate <= IDLE;
    end
    else
    begin

      o_TX_Done <= 1'b0;

      case (currentstate)
      IDLE :
        begin
          o_TX   <= 1'b1;       
          bit_counter <= 0;
          bit_index   <= 0;
          
          if (i_start == 1'b1 )
          begin
            o_TX_Active    <= 1'b1;
            r_TX_Data      <= i_data;
            currentstate   <= TX_START_BIT;
          end
          else
            currentstate <= IDLE;
        end // case: IDLE
      
      
      TX_START_BIT :
        begin
          o_TX <= 1'b0;
        
          if (bit_counter < CLKS_PER_BIT-1)
          begin
            bit_counter 	 <= bit_counter + 1;
            currentstate     <= TX_START_BIT;
          end
          else
          begin
            bit_counter      <= 0;
            currentstate     <= TX_DATA_BITS;
          end
        end // case: TX_START_BIT
      
          
      TX_DATA_BITS :
        begin
          o_TX <= r_TX_Data[bit_index];
          
          if (bit_counter < CLKS_PER_BIT-1)
          begin
            bit_counter 	 <= bit_counter + 1;
            currentstate     <= TX_DATA_BITS;
          end
          else
          begin
            bit_counter <= 0;
            
           
            if (bit_index < 7)
            begin
              bit_index <= bit_index + 1;
              currentstate   <= TX_DATA_BITS;
            end
            else
            begin
              bit_index <= 0;
              currentstate   <= TX_STOP_BIT;
            end
          end 
        end // case: TX_DATA_BITS
      
      
  
      TX_STOP_BIT :
        begin
          o_TX <= 1'b1;
  
          if (bit_counter < CLKS_PER_BIT-1)
          begin
            bit_counter 	 <= bit_counter + 1;
            currentstate     <= TX_STOP_BIT;
          end
          else
          begin
            o_TX_Done       <= 1'b1;
            bit_counter 	<= 0;
            currentstate    <= IDLE;
            o_TX_Active     <= 1'b0;
          end 
        end // case: TX_STOP_BIT      
      
      default :
        currentstate <= IDLE;
      
    endcase
    end 
  end 

  
endmodule

