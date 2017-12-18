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
interface IF_ID_REG #(BIT_WIDTH=32);
logic [BIT_WIDTH-1:0] next_pc ;
logic [BIT_WIDTH-1:0] instruction;
endinterface

interface ID_EX_REG #(BIT_WIDTH=32);
logic [BIT_WIDTH-1:0] next_pc ;
logic [BIT_WIDTH-1:0] reg_data_1;
logic [BIT_WIDTH-1:0] reg_data_2;
logic [BIT_WIDTH-1:0] signed_extended;
endinterface

interface EX_MEM_REG #(BIT_WIDTH=32);
logic [BIT_WIDTH-1:0] alu_result ;
logic zero;
logic [BIT_WIDTH-1:0] pc;
logic [BIT_WIDTH-1:0] write_data;
endinterface

interface MEM_WB_REG #(BIT_WIDTH=32);
logic [BIT_WIDTH-1:0] read_data ;
logic [BIT_WIDTH-1:0] alu_result;
endinterface


module Top # (parameter BIT_WIDTH=32) (
    input clock,
    input reset,
    input RegWrite, ALUSrc, PCSrc, MemRead, MemWrite, MemtoReg,
    input [3:0] ALU_operation
    );
    
    logic [BIT_WIDTH-1:0] PC,Next_PC,Instruction,Memory_data,Reg_data_1,Reg_data_2,ALU_data_2,ALU_result, Mem_data;

    
    //First stage registers (IF)
    IF_ID_REG #(.BIT_WIDTH(BIT_WIDTH)) if_id_reg();
    //Second stage registers (ID)
    ID_EX_REG #(.BIT_WIDTH(BIT_WIDTH)) id_ex_reg();
    //Third stage registers (EX)
    EX_MEM_REG #(.BIT_WIDTH(BIT_WIDTH))  ex_mem_reg();
    //Forth stage registers (MEM)
    MEM_WB_REG #(.BIT_WIDTH(BIT_WIDTH)) mem_wb_reg();
        
    //For every clock cycle, updating pipeline registers    
    always_ff @(posedge clock, negedge reset) begin 
        if (!reset) begin 
            PC<=0;
            if_id_reg.next_pc = 0;
            if_id_reg.instruction = 0;
            id_ex_reg.next_pc =0;
        end
        Next_PC = PC + 4;
        PC <= PCSrc ? ex_mem_reg.pc : Next_PC;
        if_id_reg.next_pc = Next_PC;
        if_id_reg.instruction = Instruction;
        
        id_ex_reg.next_pc = if_id_reg.next_pc; 
        id_ex_reg.signed_extended = (32'(signed'(if_id_reg.instruction & 16'HFFFF)));
        
        ex_mem_reg.pc = id_ex_reg.next_pc + id_ex_reg.signed_extended << 2;
        ex_mem_reg.write_data = if_id_reg.reg_data_2;
        
        mem_wb_reg.alu_result = ex_mem_reg.alu_result;
        
    end 
    
    //First stage logics
    instruction_memory #(.BIT_WIDTH(BIT_WIDTH)) instruction_memory (.Read_address(PC), .Instruction(Instruction));
    
    //Second stage logics
    registers #(.BIT_WIDTH(BIT_WIDTH)) registers (.Read_register_1(if_id_reg.instruction[25:21]), 
     .Read_register_2(if_id_reg.instruction[20:16]), .Write_register(if_id_reg.instruction[15:11]), 
     .Write_data (Memory_data), .Read_data_1 (if_id_reg.reg_data_1), .Read_data_2 (if_id_reg.reg_data_2), .RegWrite(RegWrite));
    
    //Third stage logics
    assign ALU_data_2 = ALUSrc ? if_id_reg.reg_data_2:id_ex_reg.signed_extended;
    ALU #(.BIT_WIDTH(BIT_WIDTH)) ALU (.Data1(if_id_reg.reg_data_1), .Data2(ALU_data_2), .Result(ex_mem_reg.alu_result), .zero(ex_mem_reg.zero));
    
    //Forth stage logics 
    data_memory #(.BIT_WIDTH(BIT_WIDTH)) data_memory (.Address(ex_mem_reg.alu_result), .Write_data(ex_mem_reg.write_data), .Read_data(mem_wb_reg.read_data));
    
    //Fifth stage logics
    assign Memory_data = MemtoReg ? mem_wb_reg.alu_result: mem_wb_reg.read_data;
endmodule
