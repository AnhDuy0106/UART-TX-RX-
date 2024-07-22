module write_interface(
    input         i_Clock,
    input         i_reset,
    input         brg_we,
    input         data_we,
    input  [7:0]  i_data,
    output reg [7:0] brg_reg,
    output reg [7:0] data_out
);
    wire        data_en;
    wire        brg_en;
    reg         brg_we_sync;
    reg         data_we_sync;

    always @(posedge i_Clock or negedge i_reset) begin
        if(~i_reset) begin
            brg_we_sync <= 1'b0;
            data_we_sync <= 1'b0;
        end else begin
            brg_we_sync <= brg_we;
            data_we_sync <= data_we;
        end
    end

    assign brg_en  = brg_we_sync & (~brg_we);
    assign data_en = data_we_sync & (~data_we);

    always @(posedge i_Clock or negedge i_reset) begin
        if(~i_reset) 
            brg_reg <= 8'd0;
        else if (brg_en) 
            brg_reg <= i_data;
    end

    always @(posedge i_Clock or negedge i_reset) begin
        if(~i_reset) 
            data_out <= 8'd0;
        else if (data_en) 
            data_out <= i_data;
    end
endmodule
