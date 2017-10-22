module instruction_memory #(parameter BIT_WIDTH=32,parameter REG_BIT_WIDTH=5) (
    input [REG_BIT_WIDTH-1:0] Read_address,
    output logic [BIT_WIDTH-1:0] Instruction
);

always_comb begin
    case (Read_address)
     0: Instruction <= 32'HFEFE;
     default: Instruction <= 0;
    endcase
end


endmodule