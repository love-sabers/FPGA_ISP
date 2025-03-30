module uart_test(
	input                        clk,
	input                        rst,
	input                        uart_rx,
	output                       uart_tx,
    output reg[7:0]              tx_data
);

parameter                        CLK_FRE  = 50;//Mhz
parameter                        UART_FRE = 115200;//Mhz
localparam                       IDLE =  0;
localparam                       SEND =  1;   //send 
localparam                       WAIT =  2;   //wait 1 second and send uart received data
//reg[7:0]                         tx_data;
reg[7:0]                         tx_str;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
wire[7:0]                        rx_data;
wire                             rx_data_valid;
wire                             rx_data_ready;
reg[31:0]                        wait_cnt;
reg[3:0]                         state;

wire rst_n = !rst;

// Always ready to receive data
assign rx_data_ready = 1'b1;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        wait_cnt <= 32'd0;
        tx_data <= 8'd0;
        state <= IDLE;
        tx_data_valid <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                state <= WAIT;  // Start in WAIT state to listen for incoming data
            end
            
            WAIT: begin
                wait_cnt <= wait_cnt + 32'd1;
                
                if (rx_data_valid == 1'b1) begin
                    tx_data <= rx_data;  // When data is received, store it in tx_data
                    tx_data_valid <= 1'b1; // Mark data as valid for transmission
                    state <= SEND;  // Move to SEND state to transmit the received data
                end
                else if (wait_cnt >= CLK_FRE * 1000_000) begin
                    // If no data received within 1 second, stay in WAIT state
                    state <= WAIT;
                end
            end
            
            SEND: begin
                if (tx_data_valid && tx_data_ready) begin
                    // Send the data when ready
                    tx_data_valid <= 1'b0;  // Reset data valid after transmission
                    state <= WAIT;  // Go back to WAIT to receive new data
                end
            end

            default: begin
                state <= IDLE;  // Default state
            end
        endcase
    end
end

// UART Receiver instantiation
uart_rx#(
    .CLK_FRE(CLK_FRE),
    .BAUD_RATE(UART_FRE)
) uart_rx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .rx_data(rx_data),
    .rx_data_valid(rx_data_valid),
    .rx_data_ready(rx_data_ready),
    .rx_pin(uart_rx)
);

// UART Transmitter instantiation
uart_tx#(
    .CLK_FRE(CLK_FRE),
    .BAUD_RATE(UART_FRE)
) uart_tx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .tx_data_valid(tx_data_valid),
    .tx_data_ready(tx_data_ready),
    .tx_pin(uart_tx)
);

endmodule