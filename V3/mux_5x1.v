module mux_5x1 (
    input wire [ 7 : 0 ] i0,    // Input 0
    input wire [ 7 : 0 ] i1,    // Input 1
    input wire [ 7 : 0 ] i2,    // Input 2
    input wire [ 7 : 0 ] i3,    // Input 3
    input wire [ 7 : 0 ] i4,    // Input 3
    input wire s0,    // Select signal 0 (LSB)
    input wire s1,    // Select signal 1 (MSB)
    input wire s2, 
    output reg [ 7 : 0 ] out    // Output
);

    always @(*) begin
        // Concatenating s1 and s0 to form a 2-bit selection bus
        case ({s2, s1, s0})
            3'b000: out = i0; // Selects i0 when s1=0, s0=0
            3'b001: out = i1; // Selects i1 when s1=0, s0=1
            3'b010: out = i2; // Selects i2 when s1=1, s0=0
            3'b011: out = i3; // Selects i3 when s1=1, s0=1
            3'b100: out = i4; // Selects i4 
            default: out = 3'b000;
        endcase
    end

endmodule