module pc_reg ( 
    input clk,
	input rst,
	input enable , // it is complement
    input [7:0] pc_in,
    output reg [7:0] pc_out
);
    always @(posedge clk or negedge rst) begin
        if(~rst)
            pc_out <= 0;
        else 
		begin
            if(~enable)
				pc_out <= pc_in;
        end
    end
endmodule
