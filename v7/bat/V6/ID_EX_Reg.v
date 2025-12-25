module ID_EX_Reg (
    input wire clk, reset,
    input wire flush_E,          // From Hazard Unit 
	input wire is_2_byte ,
	input wire nothing_here ,
    // ================= CONTROL SIGNALS (INPUTS) =================
    input wire [5:0] alu_control, 
    input wire wr_en_regf,     
    input wire wr_en_dmem,     
    input wire rd_en,          
    //input wire rd2_sel,   //// 1 bit      
    input wire mux_out_sel,     //// 1 bit
    input wire [1:0] mux_dmem_a_sel, //// 2 bits
    input wire [1:0] mux_dmem_wd_sel, //// 2 bits
    input wire [1:0] mux_rdata_sel,  //// 2 bits
    input wire f_save,         
    input wire f_restore,      
    input wire is_ret,         
    input wire branch_taken_E,  
    input wire out_port_sel, 
    input wire INC_SP,

    // ================= DATA SIGNALS (INPUTS) =================
    input wire [7:0] RD1, 
    input wire [7:0] RD2, 
    input wire [7:0] imm,       
    input wire [7:0] pc_reg,    
    input wire [7:0] pc_plus_1, 
    input wire [1:0]  RA,        
    input wire [1:0]  RB,        
    input wire [1:0]  ADDER,        
    input wire [1:0]  old_rb,
    input wire [7:0] instr_in,  
    input wire [7:0]  sp,       
    input wire [7:0]  sp_plus_1_or_2,
    input wire [7:0]  IN_PORT,
    input wire [1:0] PC_Sel,
	output reg [1:0] PC_Sel_E, 
    // ================= OUTPUTS TO EXECUTE STAGE =================
    output reg [5:0]  alu_control_E,
    output reg        wr_en_regf_E, wr_en_dmem_E, rd_en_E,
    output reg        mux_out_sel_E, //rd2_sel_E,
    output reg [1:0]  mux_dmem_a_sel_E,mux_dmem_wd_sel_E, mux_rdata_sel_E,
    output reg        f_save_E, f_restore_E, is_ret_E,
    output reg        branch_taken_E_out, out_port_sel_E,
    output reg [7:0] RD1_E, RD2_E, imm_E,
    output reg [7:0] pc_reg_E, pc_plus_1_E,
    output reg [1:0]  RA_E, RB_E, ADDER_E,
    output reg [1:0]  old_rb_E,
    output reg [7:0] instr_out,
    output reg [7:0] sp_E, sp_plus_1_or_2_E,
    output reg [7:0]  IN_PORT_E,
output reg is_2_byte_out ,
	output reg nothing_here_out ,
    output reg INC_SP_E
);

    always @(posedge clk or negedge reset) begin

        if (~reset) begin
            // حالة الريسيت الحقيقي: نرجع لأول البرنامج (M[0])
            alu_control_E      <= 6'b0;
            wr_en_regf_E       <= 1'b0;
            wr_en_dmem_E       <= 1'b0;
            rd_en_E            <= 1'b0;
            mux_out_sel_E      <= 1'b0;
            mux_dmem_a_sel_E   <= 2'b0;
            mux_dmem_wd_sel_E  <= 2'b0;
            mux_rdata_sel_E    <= 2'b0;
            f_save_E           <= 1'b0;
            f_restore_E        <= 1'b0;
            is_ret_E           <= 1'b0;
            branch_taken_E_out <= 1'b0;
            out_port_sel_E     <= 1'b0;
            RD1_E              <= 8'b0;
            RD2_E              <= 8'b0;
            imm_E              <= 8'b0;
            pc_reg_E           <= 8'b0;
            pc_plus_1_E        <= 8'b0;
            RA_E               <= 2'b0;
            RB_E               <= 2'b0;
            ADDER_E            <= 2'b0;
            old_rb_E           <= 2'b0;
            instr_out          <= 8'b0;
            sp_E               <= 8'b0;
            sp_plus_1_or_2_E   <= 8'b0;
            IN_PORT_E          <= 8'b0;
            INC_SP_E           <= 1'b0;
            PC_Sel_E           <= 2'b01; // ريسيت -> ارجع لـ M[0]
            nothing_here_out   <= 'd0;
            is_2_byte_out      <= 'd0;
        end 
        else if (flush_E) begin
            // حالة الفلاش (Hazard): دخل NOP وكمل (PC+1)
            alu_control_E      <= 6'b0;
            wr_en_regf_E       <= 1'b0;
            wr_en_dmem_E       <= 1'b0;
            rd_en_E            <= 1'b0;
            mux_out_sel_E      <= 1'b0;
            mux_dmem_a_sel_E   <= 2'b0;
            mux_dmem_wd_sel_E  <= 2'b0;
            mux_rdata_sel_E    <= 2'b0;
            f_save_E           <= 1'b0;
            f_restore_E        <= 1'b0;
            is_ret_E           <= 1'b0;
            branch_taken_E_out <= 1'b0;
            out_port_sel_E     <= 1'b0;
            RD1_E              <= 8'b0;
            RD2_E              <= 8'b0;
            imm_E              <= 8'b0;
            pc_reg_E           <= 8'b0;
            pc_plus_1_E        <= 8'b0;
            RA_E               <= 2'b0;
            RB_E               <= 2'b0;
            ADDER_E            <= 2'b0;
            old_rb_E           <= 2'b0;
            instr_out          <= 8'b0;
            sp_E               <= 8'b0;
            sp_plus_1_or_2_E   <= 8'b0;
            IN_PORT_E          <= 8'b0;
            INC_SP_E           <= 1'b0;
            PC_Sel_E           <= 2'b00; // فلاش -> كمل PC+1 عادي
            nothing_here_out   <= 'd0;
            is_2_byte_out      <= 'd0;
        end
  
        else begin
            alu_control_E      <= alu_control;
            wr_en_regf_E       <= wr_en_regf;
            wr_en_dmem_E       <= wr_en_dmem;
            rd_en_E            <= rd_en;
            //rd2_sel_E          <= rd2_sel;
            mux_out_sel_E      <= mux_out_sel;
            mux_dmem_a_sel_E   <= mux_dmem_a_sel;
            mux_dmem_wd_sel_E  <= mux_dmem_wd_sel;
            mux_rdata_sel_E    <= mux_rdata_sel;
            f_save_E           <= f_save;
            f_restore_E        <= f_restore;
            is_ret_E           <= is_ret;
            branch_taken_E_out <= branch_taken_E;
            out_port_sel_E     <= out_port_sel;
            RD1_E              <= RD1;
            RD2_E              <= RD2;
            imm_E              <= imm;
            pc_reg_E           <= pc_reg;
            pc_plus_1_E        <= pc_plus_1;
            RA_E               <= RA;
            RB_E               <= RB;
            ADDER_E            <= ADDER;
            old_rb_E           <= old_rb;
            instr_out        <= instr_in;
            sp_E               <= sp;
            sp_plus_1_or_2_E   <= sp_plus_1_or_2;
            IN_PORT_E          <= IN_PORT;
            INC_SP_E           <= INC_SP;
			PC_Sel_E <= PC_Sel; 
			nothing_here_out <=nothing_here ;
			is_2_byte_out <= is_2_byte ;
        end
    end

endmodule
