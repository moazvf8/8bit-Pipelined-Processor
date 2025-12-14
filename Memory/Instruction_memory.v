module Instruction_memory
(
//Declaring inputs
    input wire [ 7 : 0 ] A,
    input wire CLK,
    input wire RST, //Active-low Asynchronoyus reset

//Declaring outputs
    output wire [ 7 : 0 ] RD,
    output wire [ 7 : 0 ] M0,
    output wire [ 7 : 0 ] M1
);
//Memory
    reg [ 7 : 0 ] MEM [ 0: 255 ] ;
//Loop parameter 
    integer i;
 
always@( posedge CLK or negedge RST )
    begin
        if( !RST )
            begin
                for(  i = 0  ;  i <= 255  ;  i = i + 1 )
                MEM[ i ] <= 8'b0;  
            end
    end

//Read logic
assign RD = MEM [ A ];
assign M0 = MEM [ 0 ];
assign M1 = MEM [ 1 ];

endmodule
