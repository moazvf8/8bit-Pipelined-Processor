module CU (
    // INPUTS 
    input clk,
    input rst, /// Active-high reset
    // opcode from Fetch/Decode stage
    input wire [7:0] opcode,      // Current opcode being decoded
    //input wire [7:0] imm_data,         // Immediate value (2nd byte for L-format)
    // Condition Code Register
    input wire [3:0] flags,              // {V, C, N, Z}
    // External signals
    input wire INTR_in,                // External interrupt
    
    // OUTPUTS 
    
    // opcode Field Extraction
	output reg [1:0] old_rb, // For 2-byte instructions 
	output reg [1:0] MUX_RDATA_Sel,
	output reg [1:0] MUX_DMEM_WD_Sel,
	output reg [1:0] MUX_DMEM_A_Sel,
	output reg MUX_OUT_Sel,
	output reg [1:0] PC_Sel,
	output reg [1:0] ADDR_Sel,
	output reg branch_taken_E,
	output reg is_2byte_D,
	output reg F_Save,
	output reg F_Restore,
	output reg SP_Sel,
	output reg RD2_Sel,
	output reg OUT_PORT_sel,

	output reg wr_en_dmem, // Data memory write enable
	output reg rd_en,

	output reg wr_en_regf, // Register File write enable

	output reg is_ret,
	output reg SP_INC,

	output reg [5:0] alu_control

);

	//states
	localparam  IDLE = 2'b00, SECOND_BYTE = 2'b01, LOOP_STATE = 2'b10;

	reg [1:0] current_state, next_state;
	reg [7:0] storage;

	reg [3:0] instr_opcode ;
	reg [1:0] instr_ra  ;
	reg [1:0] instr_rb ;
	reg [1:0] instr_brx ;

	//state transition
	always @ (posedge clk or negedge rst)
		begin
			if(~rst)
			begin
				current_state <= IDLE ;
			end
			else
			begin
				current_state <= next_state ;
			end
		end

	//next state logic
	always @ (*)
		begin
			next_state = IDLE;
			instr_opcode = opcode[7:4];
			instr_ra = opcode[3:2];
			instr_rb = opcode[1:0];
			instr_brx = opcode[3:2];
			is_2byte_D = 1'b0;
			is_2byte_D = 1'b0;      
			wr_en_dmem = 1'b0;
			wr_en_regf = 1'b0;
			rd_en = 1'b0;
			branch_taken_E = 1'b0;
			is_ret = 1'b0;
			F_Save = 1'b0;
			F_Restore = 1'b0;
			SP_INC = 1'b0;
			OUT_PORT_sel=1'b0;
			PC_Sel = 2'b00; // Default to PC + 1
			SP_Sel = 1'b0; // Default SP selection
			case (current_state)
				IDLE   :  begin
								if (~rst)
									begin
										old_rb = 2'b00;
										MUX_RDATA_Sel =  2'b00; 
										MUX_DMEM_WD_Sel =  2'b00; 
										MUX_DMEM_A_Sel =  2'b00; 
										MUX_OUT_Sel = 0; 
										PC_Sel = 2'b01; // choose M[0] 
										ADDR_Sel = 2'b00;
										wr_en_dmem = 0; 
										rd_en  = 0;
										wr_en_regf  = 0; 
										is_ret  = 0; 
										alu_control = 6'b000000; // (ALU = 0)
										branch_taken_E = 0;
										F_Save = 0;
										F_Restore = 0;
										SP_Sel = 0;
										storage = 8'b00000000;
										RD2_Sel = 0;
										OUT_PORT_sel=1'b0;
										SP_INC = 0;
									end

								else if (INTR_in)
									begin
										old_rb = 2'b00;
										MUX_RDATA_Sel =  2'b00; // SP--
										MUX_DMEM_WD_Sel =  2'b11; // PC
										MUX_DMEM_A_Sel =  2'b01;  // SP
										PC_Sel = 2'b10; // M[1]
										ADDR_Sel = 2'b10; // SP
										wr_en_dmem = 1; 
										rd_en  = 0;
										wr_en_regf  = 1; 
										is_ret  = 0; 
										alu_control = 6'b100000; // ALU = 32
										branch_taken_E = 0;
										F_Save = 1;
										SP_Sel = 0; // decrement SP 
									end

								else if (instr_opcode == 'd12)
									begin
									storage = opcode;
									next_state = SECOND_BYTE; 
									is_2byte_D = 1'b0 ; //sent to hazard unit to stall

									// all sel must be set to zero here
										wr_en_dmem = 0; 
										rd_en  = 0;
										wr_en_regf  = 0; 
										is_ret  = 0; 
										alu_control = 6'b000000; 
										branch_taken_E = 0;
										F_Save = 0;
										F_Restore = 0;
										SP_INC = 0;
									end
								else 
									begin
											case (instr_opcode)

												// NOP (Opcode 0)
												4'b0000: begin
													alu_control = 6'b000000; // 0
						                            PC_Sel = 2'b00; // PC + 1
						                        end
												
												// MOV (Opcode 1) - R[ra] ← R[rb]
												4'b0001: begin
													alu_control = 6'b000001; // 1
						                            // write register file with RD2 value (R[rb])
						                            ADDR_Sel = 2'b00; // write to ra
													MUX_OUT_Sel = 1'b1;       // //////////////////////////
						                            MUX_RDATA_Sel = 2'b10; // select RD2 (R[rb]) to write it in R[ra] ////////////////////////
						                            wr_en_regf = 1'b1;
						                            PC_Sel = 2'b00; // PC + 1
						                        end
												
												// ADD (Opcode 2) - R[ra] ← R[ra] + R[rb]
												4'b0010: begin
						                            alu_control = 6'b000010;    // 2
						                            MUX_OUT_Sel = 1'b1;         // choose ALU output
						                            ADDR_Sel = 2'b00;           // write to ra
						                            MUX_RDATA_Sel = 2'b10;  	// ALU -> regfile
						                            wr_en_regf = 1'b1;
						                            PC_Sel = 2'b00;	            // PC + 1
						                        end
												
												// SUB (Opcode 3) - R[ra] ← R[ra] - R[rb]
												4'b0011: begin
						                            alu_control = 6'b000011; // 3
						                            MUX_OUT_Sel = 1'b1;		 // choose ALU output
						                            ADDR_Sel = 2'b00;        // write to ra
						                            MUX_RDATA_Sel = 2'b10;   // ALU -> regfile
						                            wr_en_regf = 1'b1;
						                            PC_Sel = 2'b00;          // PC + 1
						                        end

												
												// AND (Opcode 4) - R[ra] ← R[ra] AND R[rb]
												4'b0100: begin
						                            alu_control = 6'b000100; // 4
						                            MUX_OUT_Sel = 1'b1;      // choose ALU output
						                            ADDR_Sel = 2'b00;		 // write to ra
						                            MUX_RDATA_Sel = 2'b10;   // ALU -> regfile
						                            wr_en_regf = 1'b1;
						                            PC_Sel = 2'b00;          // PC + 1
						                        end
												
												// OR (Opcode 5) - R[ra] ← R[ra] OR R[rb]
												4'b0101: begin
						                            alu_control = 6'b000101; // 5
						                            MUX_OUT_Sel = 1'b1;      // choose ALU output
						                            ADDR_Sel = 2'b00;		 // write to ra
						                            MUX_RDATA_Sel = 2'b10;   // ALU -> regfile
						                            wr_en_regf = 1'b1;
						                            PC_Sel = 2'b00;          // PC + 1
						                        end
												
												// RLC/RRC/SETC/CLRC (Opcode 6)
												4'b0110: begin
						                            case (instr_ra)
						                                2'b00: begin // RLC
						                                    alu_control = 6'b000110; // 6
						                                    MUX_OUT_Sel = 1'b1;      // choose ALU output
						                                    ADDR_Sel = 2'b01;        // result written back to rb
						                                    MUX_RDATA_Sel = 2'b10;   // ALU -> regfile
						                                    wr_en_regf = 1'b1;
						                                end
						                                2'b01: begin // RRC
						                                    alu_control = 6'b000111;  // 7
						                                    MUX_OUT_Sel = 1'b1;       // choose ALU output
						                                    ADDR_Sel = 2'b01;         // result written back to rb
						                                    MUX_RDATA_Sel = 2'b10;    // ALU -> regfile
						                                    wr_en_regf = 1'b1;
						                                end
						                                2'b10: begin // SETC
						                                    // set Carry
						                                    alu_control = 6'b001000;  // 8
						                                end
						                                2'b11: begin // CLRC
						                                    // clear Carry
						                                    alu_control = 6'b001001;   // 9   
						                                end
						                            endcase
						                            PC_Sel = 2'b00;    // PC + 1
						                        end

												// PUSH/POP/OUT/IN (Opcode 7)
												4'b0111: begin
						                            case (instr_ra)
						                                2'b00: begin // PUSH: X[SP--] <- R[rb]
						                                	alu_control = 6'b001010; // 10
						                                    MUX_DMEM_WD_Sel = 2'b01; // data = R[rb] (read RD2)
						                                    MUX_DMEM_A_Sel = 2'b01;  // address = SP (post-decrement)
						                                    wr_en_dmem = 1'b1;
															MUX_RDATA_Sel=2'b00;  
						                                    PC_Sel = 2'b00;
															wr_en_regf = 1'b1;	
						                                    ADDR_Sel = 2'b10; // write to SP
															SP_Sel = 1'b0; // decrement SP
						                                end
						                                2'b01: begin // POP: R[rb] <- X[++SP]
						                                	alu_control = 6'b001011; // 11
						                                	SP_Sel = 1'b1; // increment SP
						                                    MUX_DMEM_A_Sel = 2'b10; // address = ++SP (pre-increment)
						                                    MUX_OUT_Sel = 1'b0; // select data from memory
						                                    rd_en = 1'b1;
						                                    wr_en_regf = 1'b1;
						                                    ADDR_Sel = 2'b01; // write to rb
						                                    PC_Sel = 2'b00;
															MUX_RDATA_Sel=2'b10; // data from memory to register file 
															SP_INC = 1'b1;
						                                end
						                                2'b10: begin // OUT: OUT.PORT <- R[rb] 
						                                    alu_control = 6'b001100; // 12 
														    PC_Sel = 2'b00;      // PC + 1
														    OUT_PORT_sel=1'b1;
						                                end
						                                2'b11: begin // IN: R[rb] <- IN.PORT 
						                                	alu_control = 6'b001101; // 13
						                                    wr_en_regf = 1'b1;
						                                    MUX_RDATA_Sel=2'b01;  //data from input port
						                                    ADDR_Sel = 2'b01;     // write to rb
						                                    PC_Sel = 2'b00;
						                                end
						                            endcase
						                        end

												
												// NOT/NEG/INC/DEC (Opcode 8)
												4'b1000: begin
													case (instr_ra)
														2'b00: begin  // NOT (ALU = 14)
															alu_control = 6'b001110;
															wr_en_regf = 1'b1;
															ADDR_Sel = 2'b01; // choose rb
															MUX_OUT_Sel = 1; // choose alu output
															MUX_RDATA_Sel = 2'b10; // choose RDATA for register file write
															wr_en_dmem = 0; 
															rd_en  = 0;
															RD2_Sel = 0;
															PC_Sel = 2'b00; // PC + 1
														end

														2'b01: begin  // NEG (ALU = 15)
															alu_control = 6'b001111;
															wr_en_regf = 1'b1;
															ADDR_Sel = 2'b01; // choose rb
															MUX_OUT_Sel = 1; // choose alu output
															MUX_RDATA_Sel = 2'b10; // choose RDATA for register file write
															wr_en_dmem = 0; 
															rd_en  = 0;	
															is_ret  = 0;
															RD2_Sel = 0; 
															PC_Sel = 2'b00; // PC + 1							
														end
														2'b10: begin  // INC (ALU = 16)
															alu_control = 6'b010000;
															wr_en_regf = 1'b1;
															ADDR_Sel = 2'b01; // choose rb
															MUX_OUT_Sel = 1; // choose alu output
															MUX_RDATA_Sel = 2'b10; // choose RDATA for register file write
															wr_en_dmem = 0; 
															rd_en  = 0;		
															is_ret  = 0; 
															RD2_Sel = 0;		
															PC_Sel = 2'b00; // PC + 1
														end
														2'b11: begin  // DEC (ALU = 17)
															alu_control = 6'b010001;
															wr_en_regf = 1'b1;
															ADDR_Sel = 2'b01; // choose rb
															MUX_OUT_Sel = 1; // choose alu output
															MUX_RDATA_Sel = 2'b10; // choose RDATA for register file write
															wr_en_dmem = 0; 
															rd_en  = 0;		
															is_ret  = 0; 	
															RD2_Sel = 0;		
															PC_Sel = 2'b00; // PC + 1			
														end
													endcase
											
												end
												
												// Conditional Branches (Opcode 9) : JZ, JN, JC, JV
												4'b1001: begin
						                            branch_taken_E = 1'b0;
						                            case (instr_brx)
						                                2'b00: begin // JZ
						                                	alu_control = 6'b010010; // 18
						                                    if (flags[0] == 1'b1) begin   // Z=1
						                                        alu_control = 6'b010111; // PASS RD2
						                                        MUX_OUT_Sel = 1'b1; // ALU output
						                                        PC_Sel = 2'b11; // jump to output
						                                        is_ret  = 1'b0; 
						                                        branch_taken_E = 1'b1;
						                                    end else PC_Sel = 2'b00;
						                                end
						                                2'b01: begin // JN
						                                	alu_control = 6'b010011; // 19
						                                    if (flags[1] == 1'b1) begin    // N = 1
						                                        alu_control = 6'b010111; // PASS RD2
						                                        MUX_OUT_Sel = 1'b1; // ALU output
						                                        PC_Sel = 2'b11; // jump to output
						                                        is_ret  = 1'b0; 
						                                        branch_taken_E = 1'b1;
						                                    end else PC_Sel = 2'b00;
						                                end
						                                2'b10: begin // JC
						                                	alu_control = 6'b010100; // 20
						                                    if (flags[2] == 1'b1) begin    // C = 1
						                                        alu_control = 6'b010111; // PASS RD2
						                                        MUX_OUT_Sel = 1'b1; // ALU output
						                                        PC_Sel = 2'b11; // jump to output
						                                        is_ret  = 1'b0; 
						                                        branch_taken_E = 1'b1;
						                                    end else PC_Sel = 2'b00;
						                                end
						                                2'b11: begin // JV
						                                	alu_control = 6'b010101; // 21
						                                    if (flags[3] == 1'b1) begin    // V = 1
						                                        alu_control = 6'b010111; // PASS RD2
						                                        MUX_OUT_Sel = 1'b1; // ALU output
						                                        PC_Sel = 2'b11; // jump to output
						                                        is_ret  = 1'b0; 
						                                        branch_taken_E = 1'b1;
						                                    end else PC_Sel = 2'b00;
						                                end
						                            endcase
						                        end

												
												// LOOP (Opcode 10) :R[ra] <- R[ra] - 1; if result !=0 PC <- R[rb] else PC+1
												4'b1010: begin
						                            alu_control = 6'b010110; // 22
													next_state = LOOP_STATE;
													if (flags[0] != 1'b0) begin
	                      								PC_Sel = 2'b11; // branch to R[rb]
			               			     				branch_taken_E = 1'b1;
				                					end else begin
					                					PC_Sel = 2'b00;
				                					end
						                        end

												// JMP/CALL/RET/RTI (Opcode 11)
												4'b1011: begin
													case (instr_brx)
														2'b00: begin  // JMP - PC ← R[rb]
															alu_control = 6'b010111; // (ALU = 23) PASS RD2
															MUX_OUT_Sel = 1; // choose alu output
															PC_Sel = 2'b11; // jump to output
															is_ret  = 0; 
															branch_taken_E = 1; // make branch taken
															wr_en_dmem = 0; 
															rd_en  = 0;
															wr_en_regf  = 0; 
															F_Save = 0;
															F_Restore = 0;
															RD2_Sel = 0;
														end
														2'b01: begin  // CALL - X[SP--] ← PC+1; PC ← R[rb]
															alu_control = 6'b011000; // (ALU = 24) PASS RD2
															MUX_OUT_Sel = 1;  // choose alu output
															PC_Sel = 2'b11; // jump to output
															is_ret  = 0; 
															branch_taken_E = 1; // make branch taken
															MUX_RDATA_Sel =  2'b00; 
															MUX_DMEM_A_Sel =  2'b01;  // SP
															MUX_DMEM_WD_Sel =  2'b10; // PC+1
															ADDR_Sel = 2'b10; // SP
															wr_en_dmem = 1; 
															rd_en  = 0;
															wr_en_regf  = 1;
															SP_Sel = 0; // decrement SP 
															F_Save = 0;
															F_Restore = 0;
															RD2_Sel = 0;
														end
														2'b10: begin  // RET - PC ← X[++SP]
															MUX_DMEM_A_Sel =  2'b01; // SP
															MUX_OUT_Sel = 0; // select data from data memory
															PC_Sel = 2'b11; // jump to ++SP
															wr_en_dmem = 0; 
															rd_en  = 1; 
															wr_en_regf  = 0; 
															is_ret  = 1; // indicate return
															alu_control = 6'b011001; // (ALU = 25)
															branch_taken_E = 0;
															F_Save = 0;
															F_Restore = 0;
															//SP_Sel = 1; // increment SP
															SP_INC = 1'b1;
															RD2_Sel = 0; 
														end
														2'b11: begin  // RTI - PC ← X[++SP]; Flags restored
															MUX_DMEM_A_Sel =  2'b01; // SP
															MUX_OUT_Sel = 0; // select data from data memory
															PC_Sel = 2'b11; // jump to output
															wr_en_dmem = 0; 
															rd_en  = 1; 
															wr_en_regf  = 0; 
															is_ret  = 1; // indicate return
															alu_control = 6'b011010; // (ALU = 26)
															branch_taken_E = 0;
															F_Save = 0;
															F_Restore = 1; // restore flags
															//SP_Sel = 1; // increment SP 
															RD2_Sel = 0;
															SP_INC = 1'b1;
														end
													endcase
												end
												
												// LDI (Opcode 13) - R[rb] ← M[R[ra]]; PC ← PC + 1
												4'b1101: begin
													
													MUX_RDATA_Sel =  2'b10; // Select data from memory 
													MUX_DMEM_A_Sel =  2'b00; // Select address R[ra] from ALU
													MUX_OUT_Sel = 0;  // Select Data from Data Memory
													PC_Sel = 2'b00; // PC + 1
													ADDR_Sel = 2'b01; // choose rb to write in register file
													wr_en_dmem = 0; 
													rd_en  = 1;
													wr_en_regf  = 1; 
													is_ret  = 0; 
													alu_control = 6'b011110; // (ALU = 30)
													branch_taken_E = 0;
													RD2_Sel = 0;
												end
												
												// STI (Opcode 14) - M[R[ra]] ← R[rb]; PC ← PC + 1
												4'b1110: begin

													MUX_DMEM_WD_Sel =  2'b01; // Select data from register file
													MUX_DMEM_A_Sel =  2'b00; // Select address R[ra] from ALU
													PC_Sel = 2'b00; // PC + 1
													wr_en_dmem = 1; 
													rd_en  = 0;
													wr_en_regf  = 0; 
													is_ret  = 0; 
													alu_control = 6'b011111; // (ALU = 31)
													branch_taken_E = 0;
													RD2_Sel = 0;
												end

												default: begin
													// Unknown opcode - default to NOP behavior
													PC_Sel = 2'b00;
													wr_en_dmem = 0; 
													rd_en  = 0;
													wr_en_regf  = 0; 
													is_ret  = 0; 
													alu_control = 6'b000000; // (ALU = 0)
													RD2_Sel = 0;
												end
												
											endcase
									end
				end	
				SECOND_BYTE  :  begin
								// we now have opcode in storage 
								instr_opcode = storage[7:4];
								instr_ra = storage[3:2];
								instr_rb = storage[1:0];
								next_state = IDLE;
								old_rb = storage[1:0];

								PC_Sel = 2'b00; // PC + 1

								if (instr_ra == 2'b00) begin  // LDM - R[rb] ← imm

									MUX_RDATA_Sel =  2'b11; // Select immediate data
									MUX_OUT_Sel = 1; // Select Data from ALU
									ADDR_Sel = 2'b11; // choose old rb to write in register file
									wr_en_dmem = 0; 
									rd_en  = 0;
									wr_en_regf  = 1; 
									is_ret  = 0; 
									alu_control = 6'b011011; // (ALU = 27)
									branch_taken_E = 0;
									F_Save = 0;
									F_Restore = 0;
									RD2_Sel = 0;
									
								end else if (instr_ra == 2'b01) begin  // LDD - R[rb] ← M[ea]
									
									MUX_RDATA_Sel =  2'b10; // Select data from memory 
									MUX_DMEM_A_Sel =  2'b11; // choose ea from instruction memory
									MUX_OUT_Sel = 0; // Select Data from Data Memory
									ADDR_Sel = 2'b11; // choose old rb to write in register file
									wr_en_dmem = 0; 
									rd_en  = 1;
									wr_en_regf  = 1; 
									is_ret  = 0; 
									alu_control = 6'b011100; // (ALU = 28)
									branch_taken_E = 0;
									F_Save = 0;
									F_Restore = 0;
									RD2_Sel = 0;

								end else if (instr_ra == 2'b10) begin  // STD - M[ea] ← R[rb]

									MUX_DMEM_WD_Sel =  2'b01; // choose rb to write in data memory
									MUX_DMEM_A_Sel =  2'b11; // choose ea from instruction memory
									wr_en_dmem = 1; 
									rd_en  = 0;
									wr_en_regf  = 0; 
									is_ret  = 0; 
									alu_control = 6'b011101; // (ALU = 29)
									branch_taken_E = 0;
									F_Save = 0;
									F_Restore = 0;
									RD2_Sel = 1; // choose old_rb to read from register file

								end
				end
				
				LOOP_STATE : begin
						         // branch decision 
			                    MUX_RDATA_Sel=2'b10;
	                            MUX_OUT_Sel=1'b1;
				                wr_en_regf = 1'b1; // write back decremented RA	
								ADDR_Sel = 2'b00; // write back to RA	
								next_state = IDLE; 
				end

				default : begin
							next_state = IDLE;
				end  

			endcase 

		end

endmodule
