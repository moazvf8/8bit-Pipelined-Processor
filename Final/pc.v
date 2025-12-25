module pc ( 
    input clk,
	input rst ,
	input enable , 
    input [7:0] pc_in,
    output reg [7:0] pc_out
);
	always @(posedge clk or negedge rst ) 
		begin
			if(~rst)
				pc_out <='d0 ;
            else if (enable)
				pc_out <= pc_in;
        end
endmodule
