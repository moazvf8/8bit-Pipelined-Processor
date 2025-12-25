module EX_MEM_Reg (
    input wire clk, reset,

    // ================= CONTROL SIGNALS (INPUTS) =================
    input wire wr_en_regf,     
    input wire wr_en_dmem,     
    input wire rd_en,          
    input wire out_port_sel,   
    input wire is_ret,         
    input wire branch_taken_E, 
    input wire mux_out_sel,    /// 1 bit 
    input wire [1:0] mux_rdata_sel,  /// 2 bits 
    

    // ================= DATA SIGNALS (INPUTS) =================
    input wire [7:0] alu_out,    
    input wire [7:0] RD2,      
    input wire [1:0]  ADDER,      
    input wire [7:0]  IN_PORT,    
    input wire [1:0]  RA,         
    input wire [1:0]  RB,         
    input wire [7:0] instr_in,   
    input wire [7:0] MUX_DMEM_1, 
    input wire [7:0] MUX_DMEM_2, 
    input wire [1:0] PC_Sel_E, 
	output reg [1:0] PC_Sel_M, 
    // ================= OUTPUTS TO MEMORY STAGE =================
    output reg        wr_en_regf_M, wr_en_dmem_M, rd_en_M,
    output reg        out_port_sel_M, is_ret_M, branch_taken_M,
    output reg        mux_out_sel_M, 
    output reg [1:0]  mux_rdata_sel_M,
    output reg [7:0] alu_out_M,
    output reg [7:0] RD2_M,
    output reg [1:0]  rd_M,       
    output reg [7:0]  IN_PORT_M,
    output reg [1:0]  RA_M, RB_M,
    output reg [7:0] instr_M,
    output reg [7:0] mem_addr_M, // From MUX_DMEM_1
    output reg [7:0] mem_wd_M    // From MUX_DMEM_2
);

 
    always @(posedge clk or negedge reset) begin
        if (~reset) begin

            wr_en_regf_M     <= 1'b0;
            wr_en_dmem_M     <= 1'b0;
            rd_en_M          <= 1'b0;
            out_port_sel_M   <= 1'b0;
            is_ret_M         <= 1'b0;
            branch_taken_M   <= 1'b0;
            mux_out_sel_M    <= 1'b0;
            mux_rdata_sel_M  <= 2'b0;
            alu_out_M        <= 8'b0;
            RD2_M            <= 8'b0;
            rd_M             <= 2'b0;
            IN_PORT_M        <= 8'b0;
            RA_M             <= 2'b0;
            RB_M             <= 2'b0;
            instr_M          <= 8'b0;
            mem_addr_M       <= 8'b0;
            mem_wd_M         <= 8'b0;
			PC_Sel_M <= 2'b00; 
        end 
        else begin
            wr_en_regf_M     <= wr_en_regf;
            wr_en_dmem_M     <= wr_en_dmem;
            rd_en_M          <= rd_en;
            out_port_sel_M   <= out_port_sel;
            is_ret_M         <= is_ret;
            branch_taken_M   <= branch_taken_E;
            mux_out_sel_M    <= mux_out_sel;
            mux_rdata_sel_M  <= mux_rdata_sel;
            alu_out_M        <= alu_out;
            RD2_M            <= RD2;
            rd_M             <= ADDER;
            IN_PORT_M        <= IN_PORT;
            RA_M             <= RA;
            RB_M             <= RB;
            instr_M          <= instr_in;
            mem_addr_M       <= MUX_DMEM_1;
            mem_wd_M         <= MUX_DMEM_2;
			PC_Sel_M <= PC_Sel_E; 
        end
    end

endmodule
