module mux_2x1_2bits (
    input wire [ 1 : 0 ] i0,    // Input 0
    input wire [ 1 : 0 ] i1,    // Input 1
    input wire s,     // Select signal
    output wire [ 1 : 0 ] out    // Output
);

    // If s = 0, out = i0
    // If s = 1, out = i1 

    assign out = s ? i1 : i0;

endmodule