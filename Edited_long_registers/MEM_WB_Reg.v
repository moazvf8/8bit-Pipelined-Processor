module MEM_WB_Reg (
    input wire clk, reset,

    // ================= 12 INPUTS =================
    // Control Signals 
    input wire wr_en_regf_M,    // Register File Write Enable
    input wire mux_out_sel_M,   // Memory-to-Reg Select
    input wire mux_rdata_sel_M, // Register Data Mux Select
    input wire out_port_sel_M,  // Output Port Select
    input wire branch_taken_E,  // Branch status
    input wire rd_en_M,         // Memory Read Enable
    //////////////////////////////////////////////
    input wire [1:0] ADDER,     // Destination Register Address (rd_M)
    // Data Signals
    input wire [7:0] read_data_M, // Data from Memory RD port
    input wire [7:0] alu_out_M,   // ALU Result
    input wire [7:0]  IN_PORT_M,   // Input Port Data
    input wire [7:0] instr_M,     // Current Instruction bits
    input wire [7:0] RD2_M,       // Register Data 2
    // ================= OUTPUTS TO WRITEBACK STAGE =================
    output reg        wr_en_regf_W, mux_out_sel_W, mux_rdata_sel_W,
    output reg        out_port_sel_W, branch_taken_W, rd_en_W,
    output reg [1:0]  ADDER_W,
    output reg [7:0] read_data_W, alu_out_W, instr_W, RD2_W,
    output reg [7:0]  IN_PORT_W
);

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            wr_en_regf_W    <= 1'b0;
            mux_out_sel_W   <= 1'b0;
            mux_rdata_sel_W <= 1'b0;
            out_port_sel_W  <= 1'b0;
            branch_taken_W  <= 1'b0;
            rd_en_W         <= 1'b0;
            ADDER_W         <= 2'b0;
            read_data_W     <= 8'b0;
            alu_out_W       <= 8'b0;
            IN_PORT_W       <= 8'b0;
            instr_W         <= 8'b0;
            RD2_W           <= 8'b0;
        end 
        else begin
            wr_en_regf_W    <= wr_en_regf_M;
            mux_out_sel_W   <= mux_out_sel_M;
            mux_rdata_sel_W <= mux_rdata_sel_M;
            out_port_sel_W  <= out_port_sel_M;
            branch_taken_W  <= branch_taken_E;
            rd_en_W         <= rd_en_M;
            ADDER_W         <= ADDER;
            read_data_W     <= read_data_M;
            alu_out_W       <= alu_out_M;
            IN_PORT_W       <= IN_PORT_M;
            instr_W         <= instr_M;
            RD2_W           <= RD2_M;
        end
    end
endmodule