module Data_memory
(
//Declaring inputs
    input wire Write_EN,
    input wire Read_EN,
    input wire [ 7 : 0 ] WD,
    input wire [ 7 : 0 ] A,
    input wire CLK,
    input wire RST, //Active-low Asynchronoyus reset

//Declaring outputs
    output reg [ 7 : 0 ] RD
);
//Memory
    reg [ 7 : 0 ] MEM [ 0: 255 ] ;
//Loop parameter 
    integer i;

//Write logic 
always@( negedge CLK or negedge RST )
    begin
        if( !RST )
            begin
                for(  i = 0  ;  i <= 255  ;  i = i + 1 )
                MEM[ i ] <= 8'b0; 
                RD <= 8'b0;
            end
        else 
            begin
        
                if ( Write_EN )
                    begin
                        MEM[ A ] <= WD;             
                    end

                if ( Read_EN )
                    begin
                        RD <= MEM[ A ];
                    end
            end

    end

endmodule
