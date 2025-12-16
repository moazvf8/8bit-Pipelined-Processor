module CCR
(
//Declaring inputs 
    input wire CLK,
    input wire RST,
    input wire [ 3 :0 ] IN,
    input wire F_Save,
    input wire F_Restore,

//Declaring output
output wire [ 3 : 0 ] OUT
);
reg [ 3 : 0 ] Current_Flags;
reg [ 3 : 0 ] Stacked_flags;

always@( posedge CLK or negedge RST )
    begin
        if( !RST )
            begin
                Current_Flags <= 4'b0;
                Stacked_flags <= 4'b0;
            end
        else if ( F_Save )
            begin
                Stacked_flags <= Current_Flags; //Saving the current flags
            end
            Current_Flags <= IN; //Storing the new coming flags
    end

assign OUT = F_Restore ? Stacked_flags : Current_Flags; //Outputting the desired flags 


endmodule 