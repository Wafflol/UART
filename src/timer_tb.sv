module timer_tb();
    reg clk, rst;
    wire done;

timer #(3) DUT(.*);

initial begin
    forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end
end

initial begin
    rst = 1'b1; #6;
    rst = 1'b0; #35;
    if (DUT.done !== 1'b1)
    $display("ERROR: TIMER ISNT DONE");
end
endmodule
