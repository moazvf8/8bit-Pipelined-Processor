module IF_ID_Reg (
    input wire clk,
    input wire reset,
    
    // --- Control Signals from Hazard Unit ---
    input wire stall_D,   // If 0, the register holds its value (Freeze)
    input wire flush_D,   // If 1, the register clears to NOP (Clear)

    // --- Inputs from Fetch Stage ---
    input wire [7:0] instr_in,      // From Instruction Memory
    input wire [7:0] pc_reg_in,     // From PC Register
    input wire [7:0] pc_plus_1_in,  // From PC Adder
    
    // --- Outputs to Decode Stage ---
    output reg [7:0] instr_out,
    output reg [7:0] pc_reg_out,
    output reg [7:0] pc_plus_1_out
);

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            instr_out      <= 8'h00;
            pc_reg_out     <= 8'h00;
            pc_plus_1_out  <= 8'h00;
        end 
        else if (flush_D) begin
            // Hazard detected 
            instr_out      <= 8'h00; 
            pc_reg_out     <= 8'h00;
            pc_plus_1_out  <= 8'h00;
        end 
        else if (stall_D) begin
            // In  Hazard Unit, stall_D = 1 means "run" 
            // and stall_D = 0 means "freeze".
            instr_out      <= instr_in;
            pc_reg_out     <= pc_reg_in;
            pc_plus_1_out  <= pc_plus_1_in;
        end
    end

endmodule
