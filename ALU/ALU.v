module ALU (
input wire 				         		reset ,
input wire signed [7:0]  	a ,
input wire signed [7:0]  	b ,
input wire         [3:0] 	alu_fun , 
output reg signed [7:0]  	alu_out ,
output reg 					         	zero ,
output reg 				         		neg ,
output reg 						         cout ,
output reg 						         overflow 
);

always@(*)
	begin
		if(~reset)
			begin
				alu_out  	= 'd0 ;
				zero     	= 'd0 ;
				neg    	 	= 'd0 ;
				cout      	= 'd0 ;
				overflow 	= 'd0 ;
			end
		else
			begin
				case (alu_fun)
				
				'b0000 : // ADD Instruction
					begin
						{ cout , alu_out } 	= a + b ;
						zero   					        = ~|alu_out  ;
						neg  					          	= alu_out[7] ;
						overflow            	= (a[7] != b[7]) && (alu_out[7] != a[7]) ;
					end
					
				'b0001 : // SUB Instruction
					begin
						{ cout , alu_out } 	= a - b ;
						zero   				        	= ~|alu_out  ;
						neg  						        = alu_out[7] ;
						overflow           	= (a[7] != b[7]) && (alu_out[7] != a[7]) ;
					end
				
				'b0010 : // AND Instruction
					begin
						alu_out 			 	= a & b ;
						zero   					 = ~|alu_out  ;
						neg  						 = alu_out[7] ;
					end
				
				'b0011 : // OR Instruction
					begin
						alu_out 				= a | b ;
						zero   					= ~|alu_out  ;
						neg  						= alu_out[7] ;
					end
				
				'b0100 :   // NOT , NEG , INC , DEC
					begin
						case (a)
								'd0 : // NOT Instruction (1's Complement)
									begin
										alu_out 				= ~b ;
										zero   					= ~|alu_out  ;
										neg  						= alu_out[7] ;
									end
									
								'd1 : // NEG Instruction (2's Complement)
									begin
										alu_out 				= ~b + 1 ;
										zero   					= ~|alu_out  ;
										neg  						= alu_out[7] ;
									end
									
								'd2 :  // INC Instruction (Increment)
									begin
										alu_out 				= b + 1 ;
										zero   					= ~|alu_out  ;
										neg  						= alu_out[7] ;
									end
									
								
								'd3 :// DEC Instruction (Decrement)
									begin
										alu_out 				= b - 1 ;
										zero   					= ~|alu_out  ;
										neg  						= alu_out[7] ;
									end
								endcase 	
							end
							
				'b0101 :
					begin
						case(a)
							'd0 : // RLC (Rotate Left through Carry)
								begin
									alu_out  				  	= {b[6:0] , cout } ;  ///////// hwa el cout da mn el flags wala heb2a input 
									cout       					= alu_out[7] ;
								end
							
							'd1 : // RRC (Rotate Right through Carry)
								begin
									alu_out  				  	= {b[6:0] , cout } ;  ///////// hwa el cout da mn el flags wala heb2a input 
									cout       					= alu_out[7] ;
								end
								
							'd2 :// SETC (Set Carry)
								begin
									alu_out  					  = b ;  ///////// hwa el cout da mn el flags wala heb2a input 
									cout       					= 'd1 ;
								end
								
							'd3 : // CLRC (Clear Carry)
								begin
									alu_out  				  	= b ;  ///////// hwa el cout da mn el flags wala heb2a input 
									cout       					= 'd0  ;
								end	
								
				 default:
					begin
						 	alu_out   = 'd0 ;
							zero      = 'd0 ;
							neg       = 'd0 ;
							cout      = 'd0 ;
							overflow  ='d0 ;
					end
								
						endcase
					end
				
				
				 default:
					begin
						 	alu_out  = 'd0 ;
							zero     = 'd0 ;
							neg      = 'd0 ;
							cout     = 'd0 ;
							overflow ='d0 ;
					end
				
				endcase
			end
	end
	endmodule
