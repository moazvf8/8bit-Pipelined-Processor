module Register_en
(
//Declaring inputs
 input wire CLK,
 input wire RST,
 input wire [ 7 : 0 ] in,
 input wire en,
//Delcaring outputs
output reg [ 7 : 0 ] out
);
always@( posedge CLK or negedge RST )
    begin
        if( !RST )
            begin
                out <= 0;
            end
        else if ( en )
            begin
                out <= in;
            end

    end

endmodule