vlib work
vlog adder.v ALU.V CCR.V CPU.V CPU_tb.v CU.v Data_memory.v EX_MEM_Reg.v
vlog Hazard_Unit.v ID_EX_Reg.v IF_ID_Reg.v Instruction_memory.v 
vlog MEM_WB_Reg.v mux_2x1.v mux_4x1_2bits.v mux_4x1.v pc.v
vlog Register_file.v Register_en.v
vsim -voptargs=+acc work.CPU_tb
add wave *
add wave -position insertpoint  \
sim:/CPU_tb/DUT/Reg_file/wr_en \
sim:/CPU_tb/DUT/Reg_file/SP \
sim:/CPU_tb/DUT/Reg_file/rst \
sim:/CPU_tb/DUT/Reg_file/RDATA \
sim:/CPU_tb/DUT/Reg_file/RD2 \
sim:/CPU_tb/DUT/Reg_file/RD1 \
sim:/CPU_tb/DUT/Reg_file/RB \
sim:/CPU_tb/DUT/Reg_file/RA \
sim:/CPU_tb/DUT/Reg_file/R \
sim:/CPU_tb/DUT/Reg_file/clk \
sim:/CPU_tb/DUT/Reg_file/ADDER \
sim:/CPU_tb/DUT/PC/pc_out \
sim:/CPU_tb/DUT/PC/pc_in \
sim:/CPU_tb/DUT/PC/enable \
sim:/CPU_tb/DUT/PC/clk \
sim:/CPU_tb/DUT/DM/Write_EN \
sim:/CPU_tb/DUT/DM/WD \
sim:/CPU_tb/DUT/DM/RST \
sim:/CPU_tb/DUT/DM/Read_EN \
sim:/CPU_tb/DUT/DM/RD \
sim:/CPU_tb/DUT/DM/MEM \
sim:/CPU_tb/DUT/DM/i \
sim:/CPU_tb/DUT/DM/CLK \
sim:/CPU_tb/DUT/DM/A \
sim:/CPU_tb/DUT/I_memory/RST \
sim:/CPU_tb/DUT/I_memory/RD \
sim:/CPU_tb/DUT/I_memory/MEM \
sim:/CPU_tb/DUT/I_memory/M1 \
sim:/CPU_tb/DUT/I_memory/M0 \
sim:/CPU_tb/DUT/I_memory/i \
sim:/CPU_tb/DUT/I_memory/CLK \
sim:/CPU_tb/DUT/I_memory/A \
sim:/CPU_tb/DUT/Control_unit/wr_en_regf \
sim:/CPU_tb/DUT/Control_unit/wr_en_dmem \
sim:/CPU_tb/DUT/Control_unit/storage \
sim:/CPU_tb/DUT/Control_unit/SP_Sel \
sim:/CPU_tb/DUT/Control_unit/SP_INC \
sim:/CPU_tb/DUT/Control_unit/SECOND_BYTE \
sim:/CPU_tb/DUT/Control_unit/rst \
sim:/CPU_tb/DUT/Control_unit/rd_en \
sim:/CPU_tb/DUT/Control_unit/RD2_Sel \
sim:/CPU_tb/DUT/Control_unit/PC_Sel \
sim:/CPU_tb/DUT/Control_unit/OUT_PORT_sel \
sim:/CPU_tb/DUT/Control_unit/opcode \
sim:/CPU_tb/DUT/Control_unit/old_rb \
sim:/CPU_tb/DUT/Control_unit/next_state \
sim:/CPU_tb/DUT/Control_unit/MUX_RDATA_Sel \
sim:/CPU_tb/DUT/Control_unit/MUX_OUT_Sel \
sim:/CPU_tb/DUT/Control_unit/MUX_DMEM_WD_Sel \
sim:/CPU_tb/DUT/Control_unit/MUX_DMEM_A_Sel \
sim:/CPU_tb/DUT/Control_unit/LOOP_STATE \
sim:/CPU_tb/DUT/Control_unit/is_ret \
sim:/CPU_tb/DUT/Control_unit/is_2byte_D \
sim:/CPU_tb/DUT/Control_unit/INTR_in \
sim:/CPU_tb/DUT/Control_unit/instr_rb \
sim:/CPU_tb/DUT/Control_unit/instr_ra \
sim:/CPU_tb/DUT/Control_unit/instr_opcode \
sim:/CPU_tb/DUT/Control_unit/instr_brx \
sim:/CPU_tb/DUT/Control_unit/IDLE \
sim:/CPU_tb/DUT/Control_unit/flags \
sim:/CPU_tb/DUT/Control_unit/F_Save \
sim:/CPU_tb/DUT/Control_unit/F_Restore \
sim:/CPU_tb/DUT/Control_unit/current_state \
sim:/CPU_tb/DUT/Control_unit/clk \
sim:/CPU_tb/DUT/Control_unit/branch_taken_E \
sim:/CPU_tb/DUT/Control_unit/alu_control \
sim:/CPU_tb/DUT/Control_unit/ADDR_Sel \
sim:/CPU_tb/DUT/ALU1/zero \
sim:/CPU_tb/DUT/ALU1/reset \
sim:/CPU_tb/DUT/ALU1/overflow \
sim:/CPU_tb/DUT/ALU1/neg \
sim:/CPU_tb/DUT/ALU1/flags_in \
sim:/CPU_tb/DUT/ALU1/flags \
sim:/CPU_tb/DUT/ALU1/cout \
sim:/CPU_tb/DUT/ALU1/b \
sim:/CPU_tb/DUT/ALU1/alu_out \
sim:/CPU_tb/DUT/ALU1/alu_fun \
sim:/CPU_tb/DUT/ALU1/a \
sim:/CPU_tb/DUT/MUX1_ALU/i0 \
sim:/CPU_tb/DUT/MUX1_ALU/i1 \
sim:/CPU_tb/DUT/MUX1_ALU/i2 \
sim:/CPU_tb/DUT/MUX1_ALU/i3 \
sim:/CPU_tb/DUT/MUX1_ALU/s0 \
sim:/CPU_tb/DUT/MUX1_ALU/s1 \
sim:/CPU_tb/DUT/MUX1_ALU/out \
sim:/CPU_tb/DUT/MUX2_ALU/i0 \
sim:/CPU_tb/DUT/MUX2_ALU/i1 \
sim:/CPU_tb/DUT/MUX2_ALU/i2 \
sim:/CPU_tb/DUT/MUX2_ALU/i3 \
sim:/CPU_tb/DUT/MUX2_ALU/s0 \
sim:/CPU_tb/DUT/MUX2_ALU/s1 \
sim:/CPU_tb/DUT/MUX2_ALU/out
run -all
#quit -sim

      