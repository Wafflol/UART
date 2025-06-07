module uart_tx_tb ();

logic clk, rst, send, err;
logic [7:0] data;
wire tx, tx_done;

parameter int IDLE  = 4'b0001;
parameter int START = 4'b0010;
parameter int TX    = 4'b0100;
parameter int STOP  = 4'b1000;

uart_tx #(.BAUD_RATE(25_000_000)) DUT(.*);

task static my_checker;
    input expected_state;
    input expected_tx;
begin
    if (DUT.state !== expected_state) begin
        $display("ERROR: state is %b, expected %b", DUT.state, expected_state);
        err = 1'b1;
    end
    if (tx !== expected_tx) begin
        $display("ERROR: tx is %b, expected %b", tx, expected_tx);
        err = 1'b1;
    end
end
endtask

initial begin
    forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end
end

initial begin
    send = 1'b0;
    rst = 1'b1;
    #10;
    my_checker(IDLE, 1'b1);
    send = 1'b1;
    rst = 1'b0;
    data = 8'b0100_1000; // DATA = H
    #10; // NOW IN START
    send = 1'b0;
    my_checker(START, 1'b0);
    #20; // NOW IN TX
    my_checker(TX, 1'b0);
    #20; // SEND LSB #2
    my_checker(TX, 1'b0);
    #20; // SEND LSB #3
    my_checker(TX, 1'b0);
    #20; // SEND LSB #4
    my_checker(TX, 1'b1);
    #20; // SEND LSB #5
    my_checker(TX, 1'b0);
    #20; // SEND LSB #6
    my_checker(TX, 1'b0);
    #20; // SEND LSB #7
    my_checker(TX, 1'b1);
    #20; // SEND LSB #8
    my_checker(TX, 1'b0);
    #20; // NOW IN STOP
    my_checker(STOP, 1'b1);
    #20; // NOW BACK IN IDLE
    my_checker(IDLE, 1'b1);
    // wait (tx_done == 1);
    $stop;
end

endmodule
