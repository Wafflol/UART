module timer #(parameter int WAIT_TIME = 434) (
    input clk, rst,
    output reg timer_done, timer_on
);

parameter int WIDTH = $clog2(WAIT_TIME);
reg [WIDTH-1 : 0] counter;

always_ff @(posedge clk) begin
    if (rst) begin
        counter <= '0;
        done <= 1'b0;
        timer_on <= 1'b1;
        timer_done <= 1'b0;
    end
    else if (counter < WAIT_TIME - 1)
        counter <= counter + 1'b1;
    else begin
        counter <= '0;
        done <= 1'b1;
        timer_on <= 1'b0;
        timer_done <= 1'b1;
    end
end
endmodule
