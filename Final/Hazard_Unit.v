module Hazard_Unit (
    // ================= FORWARDING INPUTS (For ALU) =================
    input wire [1:0] rs_E,       
    input wire [1:0] rt_E,       
    
    // Memory Stage 
    input wire [1:0] rd_M,       
    input wire reg_write_M,     
    
    // WriteBack Stage 
    input wire [1:0] rd_W,       
    input wire reg_write_W,      

    // ================= STALLING INPUTS =================
    // Decode Stage )
    input wire [1:0] rs_D,       
    input wire [1:0] rt_D,       
    input wire is_2byte_D,
    
    // Execute Stage
    input wire [1:0] rd_E,       
    input wire mem_read_E,       

    // ================= CONTROL HAZARD INPUTS =================
    // 1. Branch/Jump Resolved in Execute
    input wire branch_taken_E,   // 1 if Branch condition is met (Z=1, JMP, CALL)

    // 2. RET/RTI Detection 
    input wire is_ret_D,     
    input wire is_ret_E,      
    input wire is_ret_M,       

    // ================= OUTPUTS =================
    // Forwarding Selectors (To ALU Muxes)
    // 00 = Original Value, 10 = Forward from MEM, 01 = Forward from WB
    output reg [1:0] forward_a_E, 
    output reg [1:0] forward_b_E,
    
    // Stall Signals (To Pipeline Registers & PC)
    output reg stall_F,      // 0 = Freeze PC (Keep current address)
    output reg stall_D,      // 0 = Freeze IF/ID (Keep current instruction)
    output reg flush_E,      // 1 = Clear ID/EX (Send NOP to Execute)
    output reg flush_D       // 1 = Clear IF/ID (Send NOP to Decode)
);

    always @(*) begin
        // ---------------------------------------------------------
        // 1. FORWARDING LOGIC 
        // ---------------------------------------------------------
        
        // Forward A (Operand 1)
        forward_a_E = 2'b00; // Default: No forwarding
        if (reg_write_M && (rd_M == rs_E)) begin
            forward_a_E = 2'b10; // Forward from Memory Stage
        end else if (reg_write_W && (rd_W == rs_E)) begin
            forward_a_E = 2'b01; // Forward from Writeback Stage
        end

        // Forward B (Operand 2)
        forward_b_E = 2'b00; // Default: No forwarding
        if (reg_write_M && (rd_M == rt_E)) begin
            forward_b_E = 2'b10;
        end else if (reg_write_W && (rd_W == rt_E)) begin
            forward_b_E = 2'b01;
        end


        // ---------------------------------------------------------
        // 2. HAZARD DETECTION LOGIC
        // ---------------------------------------------------------
        
        // Default State: Run normally (Enable all writes, no flushes)
        stall_F = 1'b1;     // Enable PC Write
        stall_D = 1'b1;     // Enable IF/ID Write
        flush_E = 1'b0;     // Do not flush ID/EX
        flush_D = 1'b0;     // Do not flush IF/ID


        // 1. RET/RTI (Highest Priority - wait for PC update)
        if (is_ret_D || is_ret_E || is_ret_M) begin
            // 1. Stop fetching new instructions.
            stall_F = 1'b0;     
            // 2. Kill the instruction currently in the IF/ID register.
            flush_D = 1'b1;        
        end

        // 2. Branch Taken (Clear the wrong path immediately)
        //  Control Hazard (Branch/JMP) ---
        // Only trigger this if we are NOT currently stalled by a RET logic above.
        // This handles JZ, JN, JMP, CALL, LOOP.
        else if (branch_taken_E) begin
            flush_E = 1'b1;     // Flush the instruction that was about to execute
            flush_D = 1'b1;     // Flush the instruction in Decode (it's wrong)
        end

        // 3. 2-Byte Fetch (Need second byte for a valid instruction)
        else if (is_2byte_D) begin 
        stall_F = 1'b0; 
        stall_D = 1'b0;
        flush_E = 1'b1; 
         end

        // 4. Load-Use (Wait for data)
        // If instruction in EX is a Load, and instruction in ID uses that data.
        // We must stall 1 cycle to wait for the data to come from Memory.
        else if (mem_read_E && ((rd_E == rs_D) || (rd_E == rt_D))) begin
            stall_F = 1'b0;     // Freeze PC
            stall_D = 1'b0;     // Freeze IF/ID (Retain instruction in Decode)
            flush_E = 1'b1;     // Flush ID/EX (Send NOP to Execute)
        end
    end

endmodule