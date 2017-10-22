module registers #(parameter BIT_WIDTH=32,parameter REG_BIT_WIDTH=5) (
    input RegWrite,
    input [REG_BIT_WIDTH-1:0] Read_register_1,
    input [REG_BIT_WIDTH-1:0] Read_register_2,
    input [REG_BIT_WIDTH-1:0] Write_register,
    input [BIT_WIDTH-1:0] Write_data,
    output logic [BIT_WIDTH-1:0] Read_data_1,
    output logic [BIT_WIDTH-1:0] Read_data_2
);

reg [BIT_WIDTH-1:0] MEM [REG_BIT_WIDTH-1:0];

always_comb begin
    Read_data_1 <= MEM[Read_register_1];
    Read_data_2 <= MEM[Read_register_2];
    MEM[Write_register] <= RegWrite ? Write_data : MEM[Write_register];
end


endmodule