module adder (
    input wire [7:0] a,      // 8-bit Input A
    input wire [7:0] b,      // 8-bit Input B
    output wire [7:0] sum   // 8-bit Sum
);

    assign sum = a + b;

endmodule
