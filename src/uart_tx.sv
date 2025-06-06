module uart_tx (
    input clk, rst, send,
    input [7:0] data,
    output reg tx, tx_done
);

parameter int BAUD_RATE = 115_200; //bit/sec
parameter int CLOCK_SPEED = 50_000_000;
parameter int BAUD_WIDTH = int'(CLOCK_SPEED / BAUD_RATE); // ~434

typedef struct packed {
    logic start_bit;
    logic [0:7] data_lsb;
    logic stop_bit;
} packet_t;

packet_t send_data;

enum {IDLE_BIT  = 0,
      START_BIT = 1,
      TX_BIT    = 2,
      STOP_BIT  = 3} state_bit;

enum logic [3:0] {IDLE  = 4'b0001<<IDLE_BIT,
                  START = 4'b0001<<START_BIT,
                  TX    = 4'b0001<<TX_BIT,
                  STOP  = 4'b0001<<STOP_BIT
                  } state, next_state, next_state_reset;

assign next_state_reset = rst ? IDLE : next_state;

always_ff @(posedge clk) begin : blockName

end
endmodule
