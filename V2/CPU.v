`include "adder.v"
`include "ALU.v"
`include "CCR.v"
`include "CU.v"
`include "Data_memory.v"
`include "EX_MEM_Reg.v"
`include "Hazard_unit.v"
`include "ID_EX_Reg.v"
`include "IF_ID_Reg.v"
`include "Instruction_memory.v"
`include "MEM_WB_Reg.v"
`include "Register_en.v"
`include "mux_2x1.v"
`include "mux_2x1_2bits.v" 
`include "mux_4x1.v"
`include "mux_4x1_2bits.v"
`include "pc.v"
`include "Register_file.v"

module CPU 
(
//Declaring inputs
    input wire CLK,
    input wire RST,
    input wire [ 7 : 0 ] INPUT,
    input wire INTR_in,
//Declaring outputs 
    output wire [ 7 : 0 ] OUTPUT
);
//////////////////////////////////////////////////////////////////////////////////////
                                   // Internal wires //
/////////////////////////////////////////////////////////////////////////////////////

wire [ 7 : 0 ] PC_P_one_internal; // output of PC+1
wire [ 7 : 0 ] M0_internal ; // M0
wire [ 7 : 0 ] M1_internal; // M1
wire [ 7 : 0 ] MUX_OUT_OUTPUT_internal; //JUMP
wire [ 1 : 0 ] PC_Sel_internal; //Selection lines of the MUX_PC
wire [ 7 : 0 ] pc_in_internal; //PC input 

wire stall_F_internal; //PC enable 
wire [ 7 : 0 ] pc_out_internal; //Program counter output

wire [ 7 : 0 ] RD_IM_internal; //Read data output (From the instruction memory)

wire [ 7 : 0 ] pc_out_internal_FD_Stage_output; //output of the Program counter from the fetch decode-stage register
wire [ 7 : 0 ] PC_P_one_internal_FD_Stage_output; // output of PC+1 from the fetch decode-stage register
wire stall_D_internal; //Stall fetch decode-stage register control signal
wire flush_D_internal; //flush fetch decode-stage register control signal
wire [ 7 : 0 ] RD_IM_internal_FD_Stage_output;

wire [ 3 : 0 ] CCR_OUT_internal; //CCR output 
wire [ 1 : 0 ] old_rb_internal; //Old rb
wire [ 1 : 0 ] MUX_RDATA_Sel_internal; //MUX_RDATA selection line
wire [ 1 : 0 ] MUX_DMEM_WD_Sel_internal; //MUX_DMEM_WD selection line
wire [ 1 : 0 ] MUX_DMEM_A_Sel_internal; //MUX_DMEM_A selection line 
wire MUX_OUT_Sel_internal; //MUX out selection line
wire [ 1 : 0 ] ADDR_Sel_internal; //Regf Addr MUX selection line
wire branch_taken_E_internal; //Hazard unit signals
wire is_2byte_D_internal; //Hazard unit signal
wire F_Save_internal; //CCR unit signal
wire F_Restore_internal; //CCR unit signal
wire SP_Sel_internal; //Hazard unit signal
wire RD2_Sel_internal; //MUX_RD2 selection line 
wire OUT_PORT_sel_internal; //output port mux ENABLE
wire wr_en_dmem_internal; //Data memory write enable
wire rd_en_internal; //Data memory read enable 
wire wr_en_regf_internal; //Register file write enable
wire is_ret_internal; //Control unit signal 
wire [ 5 : 0 ] alu_control_internal; //ALU control signal
wire [ 1 : 0 ] ADDER_internal_Regf_Addr_MUX; //Register file address 

wire [ 7 : 0 ] SP_INC_DEC_internal; //Stack pointer after being incremeneted/decremented
wire [ 7 : 0 ] RD_IM_internal_MWB_Stage_output; //Red data of the instruction memory outputted from the memory write back-stage register
wire [ 7 : 0 ] RDATA_internal; //Read data of the register file
wire [ 1 : 0 ] MUX_RDATA_Sel_internal_MWB_Stage_output; //MUX_RDATA selection line outputted from the memory write back-stage register

wire [ 7 : 0 ] MUX_SP_OUTPUT_internal; //output of the stack pointer mux  

wire [ 7 : 0 ] SP_internal; //Stack pointer before begin incremented/decremented

wire [ 1 : 0 ] ADDER_internal_MWB_Stage_output; // Register file output outputted from the memory write back-stage register
wire wr_en_regf_internal_WMB_Stage_output; //Write enable of the rgister file outputted from the memory write back-stage register 
wire [ 7 : 0 ] RD1_internal; //Register file output 1
wire [ 7 : 0 ] RD2_internal; //Register file output 2

wire flush_E_internal; //flushing the execute stage 

wire [ 5 : 0 ] alu_control_internal_DEX_Stage_output; //alu control
wire wr_en_regf_internal_DEX_Stage_output;
wire wr_en_dmem_internal_DEX_Stage_output;
wire rd_en_internal_DEX_Stage_output;
wire RD2_Sel_internal_DEX_Stage_output;
wire [ 7 : 0 ] INPUT_DEX_Stage_output;
wire MUX_OUT_Sel_internal_DEX_Stage_output;
wire [ 1 : 0 ] MUX_DMEM_A_Sel_internal_DEX_Stage_output;
wire [ 1 : 0 ] MUX_DMEM_WD_Sel_internal_DEX_Stage_output;
wire [ 1 : 0 ] MUX_RDATA_Sel_internal_DEX_Stage_output;
wire F_Save_internal_DEX_Stage_output;
wire F_Restore_internal_DEX_Stage_output;
wire branch_taken_E_internal_DEX_Stage_output;
wire OUT_PORT_sel_internal_DEX_Stage_output;
wire [ 7 : 0 ] RD1_internal_DEX_Stage_output;
wire [ 7 : 0 ] RD2_internal_DEX_Stage_output;
wire [ 7 : 0 ] IMM_internal_DEX_Stage_output;
wire [ 7 : 0 ] pc_out_internal_DEX_Stage_output;
wire [ 7 : 0 ] PC_P_one_internal_DEX_Stage_output;
wire [ 1 : 0 ] RA_internal_DEX_Stage_output;
wire [ 1 : 0 ] RB_internal_DEX_Stage_output;
wire [ 1 : 0 ] ADDER_internal_Regf_Addr_MUX_DEX_Stage_output;
wire [ 1 : 0 ] old_rb_internal_DEX_Stage_output;
wire [ 7 : 0 ] INSTR_internal_DEX_Stage_output;
wire [ 7 : 0 ] SP_internal_DEX_Stage_output;
wire [ 7 : 0 ] SP_INC_DEC_internal_DEX_Stage_output;

wire [ 1 : 0 ] MUX_RB2_output;

wire [ 7 : 0 ] ALU_OUT_internal;

wire [ 7 : 0 ] MUX1_ALU_output;
wire [ 7 : 0 ] MUX2_ALU_output;
wire [ 3 : 0 ] Flag_internal; 

wire [ 7 : 0 ] MUX_DMEM_A_out;
wire [ 7 : 0 ] MUX_DMEM_WD_out;
wire wr_en_from_mem_to_wb ;
wire wr_en_regf_internal_EXM_Stage_output;
wire rd_en_internal_EXM_Stage_output;
wire OUT_PORT_sel_internal_EXM_Stage_output;
wire is_ret_internal_EXM_Stage_output;
wire branch_taken_E_internal_EXM_Stage_output;
wire MUX_OUT_Sel_internal_EXM_Stage_output;
wire [ 1 : 0 ] MUX_RDATA_Sel_internal_EXM_Stage_output;
wire [ 7 : 0 ] ALU_OUT_internal_EXM_Stage_output;
wire [ 7 : 0 ] RD2_internal_EXM_Stage_output;
wire [ 7 : 0 ] INPUT_EXM_Stage_output;
wire [ 1 : 0 ] RA_internal_EXM_Stage_output;
wire [ 1 : 0 ] RB_internal_EXM_Stage_output;
wire [ 7 : 0 ] INSTR_internal_EXM_Stage_output;
wire [ 7 : 0 ] MUX_DMEM_A_out_EXM_Stage_output;
wire [ 7 : 0 ] MUX_DMEM_WD_out_EXM_Stage_output;
wire [ 1 : 0 ] ADDER_internal_Regf_Addr_MUX_EXM_Stage_output;

wire [ 7 : 0 ] RD_DM_internal;

wire MUX_OUT_Sel_internal_MWB_Stage_output;
wire OUT_PORT_sel_internal_MWB_Stage_output;
wire rd_en_internal_MWB_Stage_output;
wire [ 1 : 0 ] ADDER_internal_Regf_Addr_MUX_MWB_Stage_output;
wire [ 7 : 0 ] RD_DM_internal_MWB_Stage_output;
wire [ 7 : 0 ] ALU_OUT_internal_MWB_Stage_output;
wire [ 7 : 0 ] INSTR_internal_MWB_Stage_output;
wire [ 7 : 0 ] RD2_internal_MWB_Stage_output;
wire [ 7 : 0 ] INPUT_MWB_Stage_output;

wire [ 1 : 0 ] forward_a_E_internal;
wire [ 1 : 0 ] forward_b_E_internal;


/////////////////////////////////////////////////////////////////////////////////////
                                // Modules instantiation //
////////////////////////////////////////////////////////////////////////////////////

//Mux PC
mux_4x1 MUX_PC 
(
.i0( PC_P_one_internal ),    
.i1( M0_internal ),   
.i2( M1_internal ),   
.i3( RD2_internal ),    
.s0( PC_Sel_internal[0] ),
.s1( PC_Sel_internal[1] ),
.out( pc_in_internal )
);

//PC
pc PC
(
.clk( CLK ),
.enable( stall_F_internal ), 
.pc_in( pc_in_internal ),
.pc_out( pc_out_internal )
);

//PC_adder
adder PC_adder
(
.a( pc_out_internal ),
.b( 8'b00000001 ),     
.sum( PC_P_one_internal ) 
);

//Instruction memory
Instruction_memory I_memory
(
.A( pc_out_internal ),
.CLK( CLK ),
.RST( RST ),
.RD( RD_IM_internal ),
.M0( M0_internal ),
.M1( M1_internal )
);

// Fetch-Decode register
IF_ID_Reg Fetch_Decode_Register
(
.clk( CLK ),
.reset( RST ),
.stall_D( stall_D_internal ),   
.flush_D( flush_D_internal ),  
.instr_in( RD_IM_internal ),     
.pc_reg_in( pc_out_internal ),     
.pc_plus_1_in( PC_P_one_internal ), 
.instr_out( RD_IM_internal_FD_Stage_output ),
.pc_reg_out( pc_out_internal_FD_Stage_output ),
.pc_plus_1_out( PC_P_one_internal_FD_Stage_output )
);


//Control unit 
CU Control_unit 
(
.clk( CLK ),
.rst( RST ), 
.opcode( RD_IM_internal_FD_Stage_output ),      
.flags( CCR_OUT_internal ),             
.INTR_in( INTR_in ), 
.old_rb( old_rb_internal ),
.MUX_RDATA_Sel( MUX_RDATA_Sel_internal ),
.MUX_DMEM_WD_Sel( MUX_DMEM_WD_Sel_internal ),
.MUX_DMEM_A_Sel( MUX_DMEM_A_Sel_internal ),
.MUX_OUT_Sel( MUX_OUT_Sel_internal ),
.PC_Sel( PC_Sel_internal ),
.ADDR_Sel( ADDR_Sel_internal ),
.branch_taken_E( branch_taken_E_internal ),
.is_2byte_D( is_2byte_D_internal ),
.F_Save( F_Save_internal ),
.F_Restore( F_Restore_internal ),
.SP_Sel( SP_Sel_internal ),
.RD2_Sel(RD2_Sel_internal),
.OUT_PORT_sel( OUT_PORT_sel_internal ),
.wr_en_dmem( wr_en_dmem_internal ),
.rd_en( rd_en_internal ),
.wr_en_regf( wr_en_regf_internal ),
.is_ret( is_ret_internal ),
.alu_control( alu_control_internal ),
.SP_INC(SP_INC_FD_Stage_output)
);

//Regf Addr MUX
mux_4x1_2bits Regf_Addr_MUX
(
.i0( RD_IM_internal_FD_Stage_output [ 3 : 2 ] ),    
.i1( RD_IM_internal_FD_Stage_output [ 1 : 0 ] ),   
.i2( 2'd3 ),   
.i3( old_rb_internal ),    
.s0( ADDR_Sel_internal[ 0 ] ),
.s1( ADDR_Sel_internal[ 1 ] ),
.out( ADDER_internal_Regf_Addr_MUX )
);

//MUX RDATA
mux_4x1 MUX_RDATA
(
.i0( SP_INC_DEC_internal ),    
.i1( INPUT ),   
.i2( MUX_OUT_OUTPUT_internal ),   
.i3( INSTR_internal_MWB_Stage_output ),    
.s0( MUX_RDATA_Sel_internal_MWB_Stage_output [ 0 ] ),
.s1( MUX_RDATA_Sel_internal_MWB_Stage_output[ 1 ] ),
.out( RDATA_internal )
);

//MUX_SP
 mux_2x1 MUX_SP
 (
.i0( 8'hff ),    
.i1( 8'h01 ),   
.s( SP_Sel_internal ),    
.out( MUX_SP_OUTPUT_internal )    
);

//SP_adder_subtractor
adder SP_ADD_SUB 
(
.a( SP_internal ),
.b( MUX_SP_OUTPUT_internal ),     
.sum( SP_INC_DEC_internal ) 
);

//Register file 
Register_file Reg_file 
(
.clk( CLK ),
.rst( RST ),
.RA( RD_IM_internal_FD_Stage_output [ 3 : 2 ] ),      
.RB( MUX_RB2_output),      
.ADDER( ADDER_internal_Regf_Addr_MUX_MWB_Stage_output ),      
.RDATA( RDATA_internal ),
.wr_en( wr_en_regf_internal_EXM_Stage_output ),
.SP_INC( SP_INC_DEX_Stage_output ),
.RD1( RD1_internal ),
.RD2( RD2_internal ),
.SP( SP_internal )
);

//Decode-Execute register 
ID_EX_Reg Decode_Execute_Register 
(
.clk( CLK ),
.reset( RST ),
.flush_E( flush_E_internal ),          
.alu_control( alu_control_internal ), 
.wr_en_regf( wr_en_regf_internal ),     
.wr_en_dmem( wr_en_dmem_internal ),     
.rd_en( rd_en_internal ),          
//.rd2_sel( RD2_Sel_internal ),        
.mux_out_sel( MUX_OUT_Sel_internal ),    
.mux_dmem_a_sel( MUX_DMEM_A_Sel_internal ), 
.mux_dmem_wd_sel( MUX_DMEM_WD_Sel_internal ),
.mux_rdata_sel( MUX_RDATA_Sel_internal ),  
.f_save( F_Save_internal ),         
.f_restore( F_Restore_internal ),      
.is_ret( is_ret_internal ),         
.branch_taken_E( branch_taken_E_internal ),  
.out_port_sel( OUT_PORT_sel_internal ), 
.INC_SP( SP_INC_FD_Stage_output ),
.RD1( RD1_internal ), 
.RD2( RD2_internal ), 
.imm( RD_IM_internal_FD_Stage_output ),       
.pc_reg( pc_out_internal_FD_Stage_output ),    
.pc_plus_1( PC_P_one_internal_FD_Stage_output ), 
.RA( RD_IM_internal_FD_Stage_output [ 3 : 2 ] ),        
.RB( RD_IM_internal_FD_Stage_output [ 1 : 0 ] ),        
.ADDER( ADDER_internal_Regf_Addr_MUX ),        
.old_rb( old_rb_internal ),
.instr_in( RD_IM_internal_FD_Stage_output ),  
.sp( SP_internal ),       
.sp_plus_1_or_2( SP_INC_DEC_internal ),
.IN_PORT( INPUT ),
.alu_control_E( alu_control_internal_DEX_Stage_output ),
.wr_en_regf_E( wr_en_regf_internal_DEX_Stage_output ),
.wr_en_dmem_E( wr_en_dmem_internal_DEX_Stage_output ), 
.rd_en_E( rd_en_internal_DEX_Stage_output ),
//.rd2_sel_E( RD2_Sel_internal_DEX_Stage_output ),
.mux_out_sel_E( MUX_OUT_Sel_internal_DEX_Stage_output ),
.mux_dmem_a_sel_E( MUX_DMEM_A_Sel_internal_DEX_Stage_output ),
.mux_dmem_wd_sel_E( MUX_DMEM_WD_Sel_internal_DEX_Stage_output ),
.mux_rdata_sel_E( MUX_RDATA_Sel_internal_DEX_Stage_output ),
.f_save_E( F_Save_internal_DEX_Stage_output ),
.f_restore_E( F_Restore_internal_DEX_Stage_output ), 
.is_ret_E( is_ret_internal_DEX_Stage_output ),
.branch_taken_E_out( branch_taken_E_internal_DEX_Stage_output ), 
.out_port_sel_E( OUT_PORT_sel_internal_DEX_Stage_output ),
.RD1_E( RD1_internal_DEX_Stage_output ), 
.RD2_E( RD2_internal_DEX_Stage_output ), 
.imm_E( IMM_internal_DEX_Stage_output ),
.pc_reg_E( pc_out_internal_DEX_Stage_output ),
.pc_plus_1_E( PC_P_one_internal_DEX_Stage_output ),
.RA_E( RA_internal_DEX_Stage_output ), 
.RB_E( RB_internal_DEX_Stage_output ), 
.ADDER_E( ADDER_internal_Regf_Addr_MUX_DEX_Stage_output ),
.old_rb_E( old_rb_internal_DEX_Stage_output ),
.instr_out( INSTR_internal_DEX_Stage_output ),
.sp_E( SP_internal_DEX_Stage_output ), 
.sp_plus_1_or_2_E( SP_INC_DEC_internal_DEX_Stage_output ),
.IN_PORT_E( INPUT_DEX_Stage_output ),
.INC_SP_E( SP_INC_DEX_Stage_output )
);

//MUX_RD2
mux_2x1_2bits MUX_RD2
(
.i0( RD_IM_internal_FD_Stage_output [ 1 : 0 ]  ),    
.i1( old_rb_internal ),   
.s( RD2_Sel_internal ),    
.out( MUX_RB2_output )    
);


//MUX1_ALU
mux_4x1 MUX1_ALU 
(
.i0( RD1_internal_DEX_Stage_output ), 
.i1( MUX_OUT_OUTPUT_internal ),   
.i2( ALU_OUT_internal_EXM_Stage_output ),   
.i3( 8'b0 ),    
.s0( forward_a_E_internal [ 0 ] ),
.s1( forward_a_E_internal [ 1 ] ),
.out( MUX1_ALU_output )
);

//MUX2_ALU
mux_4x1 MUX2_ALU
(
.i0( RD2_internal_DEX_Stage_output ),    
.i1(  MUX_OUT_OUTPUT_internal  ),   
.i2( ALU_OUT_internal_EXM_Stage_output  ),   
.i3( 8'b0 ),    
.s0( forward_b_E_internal [ 0 ] ),
.s1( forward_b_E_internal [ 1 ] ),
.out( MUX2_ALU_output )
);

//ALU
ALU ALU1
(
.reset( RST ),
.a( MUX1_ALU_output ),
.b( MUX2_ALU_output ),
.alu_fun( alu_control_internal_DEX_Stage_output ), 
.flags_in(CCR_OUT_internal),
.alu_out( ALU_OUT_internal ),
.flags( Flag_internal )
);

//CCR
CCR CCR1
(
.CLK( CLK ),
.RST( RST ),
.IN( Flag_internal ),
.F_Save( F_Save_internal_DEX_Stage_output ),
.F_Restore( F_Restore_internal_DEX_Stage_output ),
.OUT( CCR_OUT_internal )
);

//MUX_DMEM_A
mux_4x1 MUX_DMEM_A
(
.i0( ALU_OUT_internal ),    
.i1( SP_internal_DEX_Stage_output ),   
.i2( SP_INC_DEC_internal_DEX_Stage_output ),   
.i3( IMM_internal_DEX_Stage_output ),    
.s0( MUX_DMEM_A_Sel_internal_DEX_Stage_output [ 0 ] ),
.s1( MUX_DMEM_A_Sel_internal_DEX_Stage_output [ 1 ] ),
.out( MUX_DMEM_A_out )
);


//MUX_DMEM_WD
mux_4x1 MUX_DMEM_WD
(
.i0( IMM_internal_DEX_Stage_output ),    
.i1( RD2_internal_DEX_Stage_output ),   
.i2( PC_P_one_internal_DEX_Stage_output ),   
.i3( pc_out_internal_DEX_Stage_output ),    
.s0( MUX_DMEM_WD_Sel_internal_DEX_Stage_output[ 0 ] ),
.s1( MUX_DMEM_WD_Sel_internal_DEX_Stage_output[ 1 ] ),
.out( MUX_DMEM_WD_out )
);

//Execute memory register
EX_MEM_Reg EXecute_Memory_Register
 (
.clk( CLK ), 
.reset( RST ),
.wr_en_regf( wr_en_regf_internal_DEX_Stage_output ),     
.wr_en_dmem( wr_en_dmem_internal_DEX_Stage_output ),     
.rd_en( rd_en_internal_DEX_Stage_output ),          
.out_port_sel( OUT_PORT_sel_internal_DEX_Stage_output ),   
.is_ret( is_ret_internal_DEX_Stage_output ),         
.branch_taken_E( branch_taken_E_internal_DEX_Stage_output ), 
.mux_out_sel( MUX_OUT_Sel_internal_DEX_Stage_output ),   
.mux_rdata_sel( MUX_RDATA_Sel_internal_DEX_Stage_output ),  
.alu_out( ALU_OUT_internal ),    
.RD2( RD2_internal_DEX_Stage_output ),      
.ADDER( ADDER_internal_Regf_Addr_MUX_DEX_Stage_output ),      
.IN_PORT( INPUT_DEX_Stage_output ),    
.RA( RA_internal_DEX_Stage_output ),         
.RB( RB_internal_DEX_Stage_output ),         
.instr_in( INSTR_internal_DEX_Stage_output ),   
.MUX_DMEM_1(MUX_DMEM_A_out ),
.MUX_DMEM_2(MUX_DMEM_WD_out ), 
.wr_en_regf_M( wr_en_from_mem_to_wb ), 
.wr_en_dmem_M( wr_en_dmem_internal_EXM_Stage_output ) , 
.rd_en_M( rd_en_internal_EXM_Stage_output ),
.out_port_sel_M( OUT_PORT_sel_internal_EXM_Stage_output ), 
.is_ret_M( is_ret_internal_EXM_Stage_output ), 
.branch_taken_M( branch_taken_E_internal_EXM_Stage_output ),
.mux_out_sel_M( MUX_OUT_Sel_internal_EXM_Stage_output ), 
.mux_rdata_sel_M( MUX_RDATA_Sel_internal_EXM_Stage_output ),
.alu_out_M( ALU_OUT_internal_EXM_Stage_output ),
.RD2_M( RD2_internal_EXM_Stage_output ),
.rd_M( ADDER_internal_Regf_Addr_MUX_EXM_Stage_output ),       
.IN_PORT_M( INPUT_EXM_Stage_output ),
.RA_M( RA_internal_EXM_Stage_output ), 
.RB_M( RB_internal_EXM_Stage_output ),
.instr_M( INSTR_internal_EXM_Stage_output ),
.mem_addr_M( MUX_DMEM_A_out_EXM_Stage_output ), 
.mem_wd_M( MUX_DMEM_WD_out_EXM_Stage_output )    
);

//Data memory
Data_memory DM
(
.Write_EN( wr_en_dmem_internal_EXM_Stage_output ),
.Read_EN( rd_en_internal_EXM_Stage_output ),
.WD( MUX_DMEM_WD_out_EXM_Stage_output ),
.A( MUX_DMEM_A_out_EXM_Stage_output ),
.CLK( CLK ),
.RST( RST ),
.RD( RD_DM_internal )
);

//Memory write back register
 MEM_WB_Reg Memory_WriteBack_Register
 (
.clk( CLK ), 
.reset( RST ),
.wr_en_regf_M( wr_en_from_mem_to_wb ),    
.mux_out_sel_M( MUX_OUT_Sel_internal_EXM_Stage_output ),   
.mux_rdata_sel_M( MUX_RDATA_Sel_internal_EXM_Stage_output ), 
.out_port_sel_M( OUT_PORT_sel_internal_EXM_Stage_output ),  
.branch_taken_E( branch_taken_E_internal_EXM_Stage_output ),  
.rd_en_M( rd_en_internal_EXM_Stage_output ),         
.ADDER( ADDER_internal_Regf_Addr_MUX_EXM_Stage_output ),    
.read_data_M( RD_DM_internal ), 
.alu_out_M( ALU_OUT_internal_EXM_Stage_output ),   
.IN_PORT_M( INPUT_EXM_Stage_output ),   
.instr_M( INSTR_internal_EXM_Stage_output ),     
.RD2_M( RD2_internal_EXM_Stage_output ),      
.wr_en_regf_W( wr_en_regf_internal_EXM_Stage_output ), 
.mux_out_sel_W( MUX_OUT_Sel_internal_MWB_Stage_output ),
.mux_rdata_sel_W(MUX_RDATA_Sel_internal_MWB_Stage_output),
.out_port_sel_W(OUT_PORT_sel_internal_MWB_Stage_output),
.branch_taken_W(branch_taken_E_internal_MWB_Stage_output), 
.rd_en_W( rd_en_internal_MWB_Stage_output ),
.ADDER_W( ADDER_internal_Regf_Addr_MUX_MWB_Stage_output ),
.read_data_W( RD_DM_internal_MWB_Stage_output ), 
.alu_out_W( ALU_OUT_internal_MWB_Stage_output ), 
.instr_W( INSTR_internal_MWB_Stage_output ), 
.RD2_W( RD2_internal_MWB_Stage_output ),
.IN_PORT_W( INPUT_MWB_Stage_output )
);

//MUX_out
Register_en output_Registered
(
.CLK( CLK ),
.RST( RST ),
.in( RD2_internal_MWB_Stage_output ),
.en( OUT_PORT_sel_internal_MWB_Stage_output ),
.out( OUTPUT )
);



//MUX_RD_IM
mux_2x1 MUX_RD_IM
 (
.i0( RD_DM_internal_MWB_Stage_output ),    
.i1( ALU_OUT_internal_MWB_Stage_output ),   
.s( MUX_OUT_Sel_internal_MWB_Stage_output ),    
.out( MUX_OUT_OUTPUT_internal )    
);

//Hazard unit 
Hazard_Unit HU
(
.rs_E( RA_internal_DEX_Stage_output ),       
.rt_E( RB_internal_DEX_Stage_output ),       
.rd_M(ADDER_internal_Regf_Addr_MUX_EXM_Stage_output),       
.reg_write_M( wr_en_from_mem_to_wb ),     
.rd_W( ADDER_internal_Regf_Addr_MUX_MWB_Stage_output ),       
.reg_write_W( wr_en_regf_internal_EXM_Stage_output ),      
.rs_D( RD_IM_internal_FD_Stage_output[ 3 : 2 ] ),       
.rt_D( RD_IM_internal_FD_Stage_output[ 1 : 0 ] ),       
.is_2byte_D( is_2byte_D_internal ),
.rd_E( ADDER_internal_Regf_Addr_MUX_DEX_Stage_output ),       
.mem_read_E( rd_en_internal_MWB_Stage_output ),       
.branch_taken_E( branch_taken_E_internal_MWB_Stage_output ),   
.is_ret_D( is_ret_internal ),     
.is_ret_E( is_ret_internal_DEX_Stage_output ),      
.is_ret_M( is_ret_internal_EXM_Stage_output ),       
.forward_a_E( forward_a_E_internal ), 
.forward_b_E( forward_b_E_internal ),
.stall_F( stall_F_internal ),     
.stall_D( stall_D_internal ),      
.flush_E( flush_E_internal ),      
.flush_D( flush_D_internal )    
);



endmodule 