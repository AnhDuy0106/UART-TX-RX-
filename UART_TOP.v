module UART_TOP(
    input  [7:0]  in_data, // Truyền dữ liệu
    input         data_we, // KEY[1] lưu giá trị data
    input         brg_we,  // KEY[0] lưu giá trị baud rate -> 11010(26) tương đương với 115200bps
    input         data_en, // SW[9] cho phép truyền data
    input         brg_en,  // SW[8] cho phép truyền baud
    input         i_reset, // KEY[3] reset 	
    input         CLOCK_50,// FPGA clock 50MHZ
    input         i_start,	// SW[9] mức cao thì state START hoạt động
    input         UART_RX,
    output        UART_TX,
    output [6:0] HEX0, HEX1,
    output [7:0] out_led,
    output [7:0] led
);
    // TX signal
    wire       tx_active;
    wire       tx_done;
    wire [7:0] tx_data;
    wire       tx_fifo_empty;
    wire       tx_fifo_full;
	 wire [7:0] data_reg;  // Thay đổi dữ liệu
    // RX signal
    wire       rx_dv;
    wire [7:0] rx_data;
    wire       rx_fifo_empty;
    wire       rx_fifo_full;
    // Baud signal
    wire       tick; 
    wire [7:0] brg_reg;
    // Power signal
    wire       enter_sleep;

    // Instantiate TX FIFO
    fifo #(.DATA_WIDTH(8), .DEPTH(16)) tx_fifo (
        .i_Clock(CLOCK_50),
        .i_reset(i_reset),
        .wr_en(data_we & ~tx_fifo_full),
        .rd_en(tx_done),
        .data_in(data_reg),
        .data_out(tx_data),
        .full(tx_fifo_full),
        .empty(tx_fifo_empty)
    );

    // Instantiate RX FIFO
    fifo #(.DATA_WIDTH(8), .DEPTH(16)) rx_fifo (
        .i_Clock(CLOCK_50),
        .i_reset(i_reset),
        .wr_en(rx_dv & ~rx_fifo_full),
        .rd_en(data_en & ~rx_fifo_empty),
        .data_in(rx_data),
        .data_out(out_data),
        .full(rx_fifo_full),
        .empty(rx_fifo_empty)
    );

    // Instantiate UART_TX module
    UART_TX #(.TICK_PER_BIT(16)) uart_tx_inst (
        .i_Clock(CLOCK_50),
		  .i_reset(i_reset),
		  .i_enable(data_en),
		  .data_we(data_we),
        .i_start(i_start),
        .i_data(tx_data),
        .sample_tick(tick),
        .o_TX_Active(tx_active),
        .o_TX(UART_TX),
        .o_TX_Done(tx_done)
    );
	 
    // Instantiate UART_RX module
    UART_RX #(.TICK_PER_BIT(16)) uart_rx_inst (
        .i_Clock(CLOCK_50),
		  .i_reset(i_reset),
        .i_RX(UART_RX),
		  .sample_tick(tick),
        .o_RX_DV(rx_dv),
        .o_RX_Data(rx_data)
    );
	
    // Power manager
    power_manager pw(
        .i_Clock(CLOCK_50),
        .i_reset(i_reset),
        .TX_Active(tx_active),
        .enter_sleep(enter_sleep)
    );
	 
    // Baud rate generator
    Baud_rate baud_rate (
        .i_Clock(CLOCK_50),
        .i_reset(i_reset),
        .i_enable(brg_en),
        .brg_reg(brg_reg),
        .tick(tick)
    );

    // Write interface
    write_interface write_intf (
        .i_Clock(CLOCK_50),
        .i_reset(i_reset),
        .brg_we(brg_we),
        .data_we(data_we),
        .i_data(in_data),
        .brg_reg(brg_reg),
        .data_out(data_reg)  // Dữ liệu đầu ra của write_interface đi vào FIFO
    );

    // Instantiate HEX_display module
    HEX_display hex_display (
        .rx_data(rx_data),
        .HEX0(HEX0),
        .HEX1(HEX1)
    );

   assign out_led = in_data;
   assign led = enter_sleep ? 8'b11111111 : 8'b00000000;
endmodule
