module Register_file( 
    input clk,
    input rst,

    input [1:0] RA,       // read address A
    input [1:0] RB,       // read address B
    input [1:0] ADDER,       // write address

    input [7:0] RDATA,
    input wr_en,

    output [7:0] RD1,
    output [7:0] RD2,
    output [7:0] SP
    
    );

    reg [7:0] R [0:3];

    // RESET + WRITE
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            R[0] <= 8'd0;
            R[1] <= 8'd0;
            R[2] <= 8'd0;
            R[3] <= 8'd255;    // Stack pointer initialization
        end else if (wr_en) begin
            R[ADDER] <= RDATA;
        end
    end

    // COMBINATIONAL READ
    assign RD1 = R[RA];
    assign RD2 = R[RB];
    assign SP = R[3];

endmodule
