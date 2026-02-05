module pc ( 
    input clk,
	input enable , 
    input [7:0] pc_in,
    output reg [7:0] pc_out
);

	reg count = 0 ;
	always @(posedge clk ) 
		begin
            if (enable)
				pc_out <= pc_in;
        end
endmodule
