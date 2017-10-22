module data_memory #(parameter BIT_WIDTH=32,parameter REG_BIT_WIDTH=5) (
    input MemWrite,
    input MemRead,
    input [REG_BIT_WIDTH-1:0] Address,
    input [BIT_WIDTH-1:0] Write_data,
    output logic [BIT_WIDTH-1:0] Read_data
);
reg [BIT_WIDTH-1:0] MEM [REG_BIT_WIDTH-1:0];

always_comb begin
    Read_data <= MemRead ? MEM[Address] : 0;
    MEM[Address] <= MemWrite ? Write_data : 0;
end 

endmodule