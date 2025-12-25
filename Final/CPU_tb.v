`timescale 1ns/1ps

module CPU_tb ();

    reg CLK_tb;
    reg RST_tb;
    reg INTR_in_tb;
    reg [ 7 : 0 ] INPUT_tb;
    wire [ 7 : 0 ] OUTPUT_tb;

    // Design Instantiation
    CPU DUT (
        .CLK(CLK_tb),
        .RST(RST_tb),
        .INTR_in(INTR_in_tb),
        .INPUT(INPUT_tb),
        .OUTPUT(OUTPUT_tb)
    );

    parameter CLK_PERIOD = 20;
    always #(CLK_PERIOD/2) CLK_tb = ~CLK_tb;

    initial begin
        // Initialize Inputs
		 initialize() ;
		// Load Program Memory
        // Ensure "program.mem" is in the simulation directory
        // Ensure Instruction_memory.v has: reg [7:0] MEM [0:255];
       
		 @(negedge CLK_tb);
		 reset() ;
		@(negedge CLK_tb);
      INPUT_tb = 8'b00000110; // Example input value = 6
     @(negedge CLK_tb);
		 $readmemb("program.txt", DUT.I_memory.MEM);
		 @(negedge CLK_tb);
 


	@(negedge CLK_tb);
	INTR_in_tb = 1'b1;   // raise interrupt

	@(negedge CLK_tb);
	INTR_in_tb = 1'b0;   // clear interrupt

		
       repeat(100)@(negedge CLK_tb);
        $stop;
    end

task initialize ;
  begin
	CLK_tb    = 1'b0  ;
	RST_tb    = 1'b1  ;    
	INTR_in_tb   = 1'b0  ;
	INPUT_tb = 1'b0  ;
  end
endtask

task reset ;
 begin
  #(CLK_PERIOD)
  RST_tb  = 'b0;           // rst is activated
  #(CLK_PERIOD)
  RST_tb  = 'b1;
  #(CLK_PERIOD) ;
 end
endtask

endmodule
