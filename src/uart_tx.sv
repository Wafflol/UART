module uart_tx
    #(parameter int BAUD_RATE = 115_200,
        parameter int CLOCK_SPEED = 50_000_000)(
    input logic clk, rst, send,
    input [7:0] data,
    output logic tx, tx_done
);

    parameter BAUD_WIDTH = CLOCK_SPEED / BAUD_RATE; // 434

    parameter IDLE  = 7'b00001_11,
              START = 7'b00010_00,
              TX_0  = 7'b00100_00,
              TX_1  = 7'b01000_10,
              STOP  = 7'b10000_10;

    logic [7:0] data_register;
    logic [8:0] clk_counter;
    logic [2:0] data_index;
    logic [6:0] state;

    assign tx_done = state[0];
    assign tx      = state[1];

    always_ff @(posedge clk, posedge rst) begin : regSRFlipFlop
        if (rst)
            data_register <= '0;
        else if (send & (state === IDLE))
            data_register <= data; //TODO: add tb testcase for flip flop
    end

    always_ff @(posedge clk, posedge rst) begin : stateMachine
        if (rst) begin
            state <= IDLE;
            clk_counter <= '0;
            data_index <= '0;
        end
        else begin
            unique case (state)
                IDLE: state <= send ? START : IDLE;
                START: begin
                    if (clk_counter < BAUD_WIDTH - 1) begin
                        clk_counter <= clk_counter + 1'b1;
                    end
                    else begin
                        clk_counter <= '0;
                        state <= data[0] ? TX_1 : TX_0;
                        data_index <= data_index + 1;
                    end
                end
                TX_0, TX_1: begin
                    if (clk_counter < BAUD_WIDTH - 1) begin
                        clk_counter <= clk_counter + 1'b1;
                    end
                    else begin
                        clk_counter <= '0;
                        state <= data_register[data_index] ? TX_1  : TX_0;
                        data_index <= data_index + 1;
                    end
                end
                STOP: begin
                    if (clk_counter < BAUD_WIDTH - 1)
                        clk_counter <= clk_counter + 1'b1;
                    else begin
                        clk_counter <= '0;
                        state <= IDLE;
                        data_index <= '0;
                    end
                end
            endcase
        end
    end

endmodule
