`timescale 1ns/1ns
`include "UART_RX.v"
`include "UART_TX.v"
`include "power_manager.v"
`include "Baud_rate.v"
module UART_TB ();
  parameter c_CLOCK_PERIOD_NS = 20;
  parameter c_TICK_PER_BIT    = 16;
  reg r_reset  = 0;
  reg r_enable = 1;
  reg br_enable = 1;
  reg r_Clock  = 0;
  reg r_TX_DV  = 0;
  wire w_TX_Active, w_UART_Line;
  wire w_TX_Serial;
  reg [7:0] r_TX_Data = 0;
  wire [7:0] w_RX_Data;
  wire tick;
  wire [7:0] ascii_msb;
  wire [7:0] ascii_lsb;

  UART_RX #(.TICK_PER_BIT(c_TICK_PER_BIT)) UART_RX_Inst
    (.i_Clock(r_Clock),
     .i_RX(w_UART_Line),
     .i_reset(r_reset),
     .sample_tick(tick),
     .o_RX_DV(w_RX_DV),
     .o_RX_Data(w_RX_Data)
     );
  
  UART_TX #(.TICK_PER_BIT(c_TICK_PER_BIT)) UART_TX_Inst
    (.i_Clock(r_Clock),
     .i_start(r_TX_DV),
     .i_data(r_TX_Data),
     .i_reset(r_reset),
     .i_enable(r_enable),
     .sample_tick(tick),	
     .o_TX_Active(w_TX_Active),
     .o_TX(w_TX_Serial),
     .o_TX_Done()
     );
  
  power_manager pw(
     .i_Clock(r_Clock),
     .i_reset(r_reset),
     .TX_Active(w_TX_Active),
     .enter_sleep()
     );
  Baud_rate baud_rate (
    .i_Clock(r_Clock),
    .i_reset(r_reset),
    .i_enable(br_enable),
    .brg_reg(8'h1A),  // Example register value for 115200 baud
    .tick(tick)
  );
 

  assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;
    
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
  
  // Main Testing:
  initial
    begin
     //reset
      @(posedge r_Clock);
      r_reset = 1'b0;
      @(posedge r_Clock);
      r_reset  = 1'b1;
      r_enable = 1'b0;

     //nap baudrate
      @(posedge r_Clock);
      br_enable = 1'b0;

     //nap data
      @(posedge r_Clock);
      @(posedge r_Clock);
      r_TX_DV   <= 1'b1;
      r_TX_Data <= 8'h3F;
      @(posedge r_Clock);
      r_TX_DV   <= 1'b0;

      @(posedge w_RX_DV);
      if (w_RX_Data == 8'h3F)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
      $finish();
    end
  
  initial 
  begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule
