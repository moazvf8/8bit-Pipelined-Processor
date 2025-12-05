module Memory
#( parameter Width = 'd8 , parameter Depth = 'd256 )
(
//Declaring inputs
    input wire Write_EN,
    input wire Read_EN,
    input wire [ Width - 1 : 0 ] Write_D,
    input wire [ Width - 1 : 0 ] Address,
    input wire CLK,
    input wire RST, //Active-low Asynchronoyus reset

//Declaring outputs
    output wire [ Width - 1 : 0 ] Read_D
);
//Memory
    reg [ Width - 1 : 0 ] MEM [ 0: Depth - 1 ] ;
//Loop parameter 
    integer i;

//Write logic 
always@( posedge CLK or negedge RST )
    begin
        if( !RST )
            begin
                for(  i = 0  ;  i <= Depth - 1  ;  i = i + 1 )
                MEM[ i ] <= { Width { 1'b0  } };  
            end
        else if ( Write_EN )
            begin
                 MEM[ Address ] <= Write_D;             
            end
    end

//Read logic
assign Read_D = Read_EN ? MEM[ Address ] : { Width { 1'b0 } } ;
endmodule
