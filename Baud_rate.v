module Baud_rate (
    input        i_Clock,
    input        i_reset,
    input        i_enable,
    input  [7:0] brg_reg,
    output wire  tick
);

    reg [15:0] bit_counter;

    always @(posedge i_Clock or negedge i_reset) begin
       if (~i_reset)
            bit_counter <= 0;
	else if (tick)
		bit_counter <= 0;
        else if (i_enable == 1'b1) 
                bit_counter <= bit_counter + 1'b1;
        end
  assign tick = (bit_counter == (brg_reg + 1'b1)) ? 1'b1 : 1'b0;

endmodule
