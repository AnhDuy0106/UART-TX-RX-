module power_manager(
    input i_Clock,
    input i_reset,
    input TX_Active,
    output reg enter_sleep
);
    reg [32:0] idle_counter;

    always @(posedge i_Clock or negedge i_reset) begin
        if (~i_reset) begin
            idle_counter <= 0;
            enter_sleep <= 0;
        end else begin
            if (TX_Active) begin
                idle_counter <= 0;
                enter_sleep <= 0;
            end else begin
                if (idle_counter < 32'd1000000) begin
                    idle_counter <= idle_counter + 1;
                end else begin
                    enter_sleep <= 1;
                end
            end
        end
    end
endmodule
