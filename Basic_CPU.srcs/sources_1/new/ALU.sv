`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2017 12:53:36
// Design Name: 
// Module Name: ALU
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


module ALU #(parameter BIT_WIDTH=32) (
    input [BIT_WIDTH-1:0] Data1,
    input [BIT_WIDTH-1:0] Data2,
    input [3:0] ALU_operation,
    output logic zero,
    output logic [BIT_WIDTH-1:0] Result
    );
    
    always_comb begin
        case (ALU_operation)
            0:Result <= Data1+Data2; //ADD
            1:Result <= Data1-Data2; //SUB
            2:Result <= Data1&Data2; //AND
            3:Result <= Data1|Data2; //OR
            4:Result <= Data1<Data2 ? 1: 0; //SLT
            default: Result <= 0;
        endcase
        
        zero <= Result == 0? 1:0;
    end
endmodule
