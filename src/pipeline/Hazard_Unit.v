module Hazard_Unit (
    // ================= FORWARDING INPUTS =================
    input wire [1:0] rs_E,       
    input wire [1:0] rt_E,       
    
    input wire [1:0] rd_M,       
    input wire reg_write_M,     
    
    input wire [1:0] rd_W,       
    input wire reg_write_W,      

    // Signals for 2-Byte Handling
    input wire is_2_byte_d ,
    input wire is_2_byte_e ,
    input wire is_2_byte_m ,
    input wire is_2_byte_wb ,
    
    input wire nothing_here_d ,
    input wire nothing_here_e ,
    input wire nothing_here_m ,
    input wire nothing_here_wb ,

    // ================= STALLING INPUTS =================
    input wire [1:0] rs_D,       
    input wire [1:0] rt_D,       
    input wire is_2byte_D, 
    
    input wire [1:0] rd_E,       
    input wire mem_read_E, 
    input wire reg_write_E, // محتاجين دي عشان نتأكد إن LDM بتكتب
    
    input wire branch_taken_E,   
    input wire is_ret_D,      
    input wire is_ret_E,       
    input wire is_ret_M,        

    // ================= OUTPUTS =================
    output reg [1:0] forward_a_E, 
    output reg [1:0] forward_b_E,
    output reg stall_F,      
    output reg stall_D,      
    output reg flush_E,      
    output reg flush_D       
);

    wire valid_reg_write_M;
    wire valid_reg_write_W;

    assign valid_reg_write_M = reg_write_M && (~nothing_here_m);
    assign valid_reg_write_W = reg_write_W && (~nothing_here_wb);

    always @(*) begin
        // ---------------------------------------------------------
        // 1. FORWARDING LOGIC 
        // ---------------------------------------------------------
        forward_a_E = 2'b00; 
        forward_b_E = 2'b00; 

        // بنعمل Forwarding بس لو التعليمة اللي فاتت *مش* 2-byte
        // لأننا معندناش سلك يوصل الـ Immediate للـ ALU
        if (is_2_byte_e == 1'b0) begin 
            
            // Forward A
            if (valid_reg_write_M && (rd_M == rs_E) && (is_2_byte_m == 1'b0)) begin
                forward_a_E = 2'b10; 
            end 
            else if (valid_reg_write_W && (rd_W == rs_E) && (is_2_byte_wb == 1'b0)) begin
                forward_a_E = 2'b01; 
            end

            // Forward B
            if (valid_reg_write_M && (rd_M == rt_E) && (is_2_byte_m == 1'b0)) begin
                forward_b_E = 2'b10;
            end 
            else if (valid_reg_write_W && (rd_W == rt_E) && (is_2_byte_wb == 1'b0)) begin
                forward_b_E = 2'b01;
            end
        end 

        // ---------------------------------------------------------
        // 2. HAZARD DETECTION LOGIC
        // ---------------------------------------------------------
        stall_F = 1'b1;     
        stall_D = 1'b1;     
        flush_E = 1'b0;     
        flush_D = 1'b0;     

        // 1. RET/RTI 
        if ((is_ret_D && !nothing_here_d) || (is_ret_E && !nothing_here_e) || (is_ret_M && !nothing_here_m)) begin
            stall_F = 1'b0;     
            flush_D = 1'b1;         
        end

        // 2. Branch Taken 
        else if (branch_taken_E && !nothing_here_e) begin
            flush_E = 1'b1;     
            flush_D = 1'b1;     
        end

        // 3. LOAD & LDM STALL (The Fix)
        // لو فيه تعليمة 2-byte (زي LDM) بتكتب في register إحنا محتاجينه دلوقتي
        // لازم نعمل Stall سواء هي في Execute أو Memory أو Writeback
        // لأننا مش بنعرف نعملها Forwarding
        else if (
            // الحالة الأولى: LDM في مرحلة Execute
            ( (is_2_byte_e && reg_write_E && !nothing_here_e) && ((rd_E == rs_D) || (rd_E == rt_D)) ) ||
            
            // الحالة الثانية: LDM في مرحلة Memory
            ( (is_2_byte_m && reg_write_M && !nothing_here_m) && ((rd_M == rs_D) || (rd_M == rt_D)) ) ||
            
            // الحالة الثالثة: LDM في مرحلة Writeback (عشان القراءة والكتابة في نفس اللحظة)
            ( (is_2_byte_wb && reg_write_W && !nothing_here_wb) && ((rd_W == rs_D) || (rd_W == rt_D)) ) ||

            // الحالة الرابعة: Load Instruction العادية (Load Use Hazard)
            ( (mem_read_E && !nothing_here_e) && ((rd_E == rs_D) || (rd_E == rt_D)) )
        ) 
        begin
             // Stall Logic
             if (!is_2byte_D) begin // نتأكد إننا مش بنوقف الجزء التاني من LDM نفسها
                stall_F = 1'b0;     
                stall_D = 1'b0;     
                flush_E = 1'b1; 
             end
        end
    end
endmodule