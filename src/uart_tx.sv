module uart_tx (
    input clk, rst, send,
    input [7:0] data,
    output reg tx, tx_done
);

logic timer_done, timer_on;
logic [8:0] counter, counter_next;
logic [3:0] shift_reg, shift_reg_next;

parameter int BAUD_RATE = 115_200; //bit/sec
parameter int CLOCK_SPEED = 50_000_000;
parameter int BAUD_WIDTH = int'(CLOCK_SPEED / BAUD_RATE); // ~434

typedef struct packed {
    logic stop_bit;
    logic [7:0] payload;
    logic start_bit;
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
assign send_data = '{1'b1, ~(data), 1'b0};

always_ff @(posedge clk) begin : registers
    state <= next_state_reset;
    counter <= counter_next;
    shift_reg <= shift_reg_next;
end

always_comb begin : state_machine_cl
    unique case (state)
        IDLE: {next_state, counter_next, shift_reg_next, tx, tx_done} =
            {(send ? START : IDLE), '0, 4'd0, 1'b1, 1'b1};
        START: begin
            {tx, tx_done} = {send_data[shift_reg], 1'b0};
            if (counter < BAUD_WIDTH - 1) begin //does this need -1? check in tb
                counter_next = counter + 1'b1;
                next_state = START;
                shift_reg_next = shift_reg;
            end
            else begin
                counter_next = 1'b0;
                next_state = TX;
                shift_reg_next =  shift_reg + 1;
            end

        end
        TX: begin
            {tx, tx_done} = {send_data[shift_reg], 1'b0};
            if (counter < BAUD_WIDTH - 1) begin
                counter_next = counter + 1'b1;
                next_state = TX;
                shift_reg_next = shift_reg;
            end
            else begin
                counter_next = 1'b0;
                shift_reg_next = shift_reg + 1;
                if (shift_reg == 8)
                    next_state = STOP;
                else
                    next_state = TX;
            end
        end
        STOP: begin
            {tx, tx_done} = {send_data[shift_reg], 1'b0};
            if (counter < BAUD_WIDTH - 1) begin
                counter_next = counter + 1'b1;
                next_state = STOP;
                shift_reg_next = shift_reg;
            end
            else begin
                counter_next = 1'b0;
                next_state = IDLE;
                shift_reg_next = '0;
            end
        end
    endcase
end
endmodule
