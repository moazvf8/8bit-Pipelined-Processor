module ALU (
    input wire                 reset,
    input wire signed [7:0]    a,
    input wire signed [7:0]    b,
    input wire [5:0]           alu_fun, 
    input wire [3:0]           flags_in,
    output reg signed [7:0]    alu_out,
    output wire [3:0]           flags
);

    reg zero, neg, cout, overflow;

    assign flags = { overflow, cout, neg, zero };

    always @(*) begin

        overflow = flags_in[3];
        cout = flags_in[2];
        neg = flags_in[1];
        zero = flags_in[0];

        if (~reset) begin
            alu_out   = 'd0;
            zero      = 'd0;
            neg       = 'd0;
            cout      = 'd0;
            overflow  = 'd0;
        end else begin
            case (alu_fun)

                'd2: begin // ADD Instruction
                    { cout, alu_out } = a + b;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                    overflow          = (a[7] == b[7]) && (alu_out[7] != a[7]);
                end

                'd3: begin // SUB Instruction
                    { cout, alu_out } = a - b;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                    overflow          = (a[7] != b[7]) && (alu_out[7] != a[7]);
                end

                'd5: begin // OR Instruction
                    alu_out           = a | b;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd6: begin // RLC
                    alu_out           = { b[6:0], cout };
                    cout              = b[7];
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd7: begin // RRC
                    alu_out           = { cout, b[7:1] };
                    cout              = b[0];
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd8: begin // SETC
                    cout              = 'd1;
                end

                'd9: begin // CLRC
                    cout              = 'd0;
                end

                'd14: begin // NOT Instruction (1's Complement)
                    alu_out           = ~b;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd15: begin // NEG Instruction (2's Complement)
                    alu_out           = ~b + 1;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd16: begin // INC Instruction
                    alu_out           = b + 1;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                    overflow = (~b[7]) && alu_out[7];
                    cout =&b;
                end

                'd17: begin // DEC Instruction
                    alu_out           = b - 1;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                    overflow = (~b[7]) && alu_out[7];
                    cout =|b;  //Carry = 1 if NO borrow
                end

                'd22: begin // loop Instruction
                    alu_out           = a - 1;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd30: begin // LDI Instruction
                    alu_out           = a;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                'd31: begin // STI Instruction
                    alu_out           = a;
                    zero              = ~|alu_out;
                    neg               = alu_out[7];
                end

                default: begin
                    alu_out           = b;
                end

            endcase
        end
    end

endmodule
