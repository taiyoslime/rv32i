
module test;

    logic signed [7:0] a = -7;
    logic [7:0] b = 3;
    logic [7:0] c; 
    logic [7:0] d;

    initial begin
        #10 $display("%b %b", a, b);
        $display("%b", a / b );
        $display("%b", $signed(a) / $signed(b) );
        c = $signed(a);
        d = $signed(b);
        $display("%b", c / d );
    end
endmodule
