`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2017 14:30:05
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top # (parameter BIT_WIDTH=32) (
    input clock,
    input reset,
    input RegWrite, ALUSrc, PCSrc, MemRead, MemWrite, MemtoReg,
    input [3:0] ALU_operation
    );
    
    logic [BIT_WIDTH-1:0] PC,Next_PC,Instruction,Memory_data,Reg_data_1,Reg_data_2,Signed_extended,ALU_data_2,ALU_result, Mem_data;
    assign Next_PC = PC + 4;
    assign Signed_extended = (32'(signed'((Instruction & 16'HFFFF)<<2)));
    always_ff @(posedge clock, negedge reset) begin
        if (!reset) begin
            PC<=0;
        end 
        else begin
            PC <= PCSrc ? Next_PC: Next_PC+ Signed_extended;
        end
    end
    
    instruction_memory #(.BIT_WIDTH(BIT_WIDTH)) instruction_memory (.Read_address(PC), .Instruction(Instruction));
    
    registers #(.BIT_WIDTH(BIT_WIDTH)) registers (.Read_register_1(Instruction[25:21]), 
     .Read_register_2(Instruction[20:16]), .Write_register(Instruction[15:11]), 
     .Write_data (Memory_data), .Read_data_1 (Reg_data_1), .Read_data_2 (Reg_data_2), .RegWrite(RegWrite));
    
    assign ALU_data_2 = ALUSrc ? Reg_data_2:Signed_extended;
    ALU #(.BIT_WIDTH(BIT_WIDTH)) ALU (.Data1(Reg_data_1), .Data2(ALU_data_2), .Result(ALU_result));
    data_memory #(.BIT_WIDTH(BIT_WIDTH)) data_memory (.Address(ALU_result), .Write_data(Reg_data_2), .Read_data(Mem_data));
    assign Memory_data = MemtoReg ? Mem_data: ALU_result;
endmodule
