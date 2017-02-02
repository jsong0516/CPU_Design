//-----------------------------------------------------------------------------
// Lab5Control
// CS 150 Fall 2014
// Description:
//      Implement your control logic in this module.
//-----------------------------------------------------------------------------
`include "Opcode.vh"
`include "ALUop.vh"
module Control(
        input  [31:0]inst,
        output reg [3:0] ALUop,
        output reg regWrite,
	output reg rd1Sel,   // 1 means rd1 from reg, 0 means pc
        output reg [2:0] rd2Sel, //000 means rs2, 001 means 31:25+11:7 : SB, 010 means 31:20 : I, and 011 means 31:12 : U //  100 - 31:12 UJ // 101 - 31:25+11:7 : S // 110 - SHAMT
        output reg dramWrite,
	output reg memOrReg, // 1 means Reg while 0 means mem
	output reg jump,
	output reg branch,
	output [2:0] size,
	output [4:0] wa
);
        wire[6:0] opcode;
        wire[4:0] rd;
        wire[2:0] funct3;
        wire[4:0] rs1;
        wire[4:0] rs2;
        wire[6:0] funct7;
	assign wa = inst[11:7];
        assign opcode = inst[6:0];
	assign rd = inst[11:7];
        assign funct3 = inst[14:12];
        assign rs1 = inst[19:15];
        assign rs2 = inst[24:20];
        assign funct7 = inst[31:25];
	assign size = inst[14:12]; 
        always@(*)begin
               case(opcode)
                    `OPC_ARI_RTYPE:begin //Rtype inst
                                regWrite = 1;
                                memOrReg = 1;
                                rd1Sel = 1;
                                rd2Sel = 3'b000;
                                dramWrite = 0;
                                jump = 0;
                                branch =0;
                                case(funct3)
                                        `FNC_ADD_SUB: begin
                                                   if(funct7 == 7'b0100000)
                                                       ALUop = `ALU_SUB;
                                                   else 
						       ALUop = `ALU_ADD;
					end
 					`FNC_AND: ALUop = `ALU_AND;
					`FNC_OR: ALUop = `ALU_OR;
					`FNC_XOR: ALUop = `ALU_XOR;
					`FNC_SLT: ALUop = `ALU_SLT;
					`FNC_SLTU: ALUop = `ALU_SLTU;
					`FNC_SLL: ALUop = `ALU_SLL;
                                        `FNC_SRL_SRA: begin
					           if(funct7 == 7'b0100000)
                                                       ALUop = `ALU_SRA;
                                                   else 
						       ALUop = `ALU_SRL;
                                        end
                              endcase
                   end
                   `OPC_ARI_ITYPE: begin //Itype and Stype inst
				regWrite = 1;
                                memOrReg = 1;
                                rd1Sel = 1;
                                dramWrite = 0;
                                jump = 0;
                                branch = 0;	                              
				case(funct3)
                                     `FNC_ADD_SUB: begin
					ALUop = `ALU_ADD;
                                	rd2Sel = 3'b010; 
				      end
				     `FNC_AND: begin 
					ALUop = `ALU_AND;
					rd2Sel = 3'b010; 
				      end
				     `FNC_OR: begin
					ALUop = `ALU_OR;
					rd2Sel = 3'b010;
				      end
				     `FNC_XOR: begin 
					ALUop = `ALU_XOR;
					rd2Sel = 3'b010;
				      end					
				     `FNC_SLT: begin 
					ALUop = `ALU_SLT;
					rd2Sel = 3'b010;
				      end
				     `FNC_SLTU: begin
					ALUop = `ALU_SLTU;
					rd2Sel = 3'b010;
				      end
				     `FNC_SLL: begin 
					ALUop = `ALU_SLL;
					rd2Sel = 3'b110;
				      end
                                     `FNC_SRL_SRA: begin
					   rd2Sel = 3'b110;
				           if(funct7 == 7'b0100000)
                                               ALUop = `ALU_SRA;
                                           else 
					       ALUop = `ALU_SRL;
                                     end
                             endcase
                   end
                   `OPC_STORE: begin //store -S
                            regWrite = 0;
                            memOrReg = 1;
                            rd1Sel = 1;
                            dramWrite = 1;
                            jump = 0;
                            branch =0;
                            //sign_extend=1;
                            rd2Sel = 3'b101;
                            ALUop = `ALU_ADD;
                   end
                 `OPC_LOAD: begin //load - ITYPE
                           regWrite = 1;
                           memOrReg = 0;
                           rd1Sel = 1;
                           dramWrite = 0;
                           jump = 0;
                           branch = 0;
                           rd2Sel = 3'b010;
                           ALUop = `ALU_ADD;
                end
               `OPC_BRANCH: begin //branch -SB type
                       regWrite = 0;
                       memOrReg = 1;
                       rd1Sel = 1;
                       rd2Sel = 3'b000;
                       dramWrite = 0;
                       jump = 0;
                       branch =1;
                       case(funct3)
                             `FNC_BEQ:begin
                                   ALUop = `ALU_EQ;
                              end
                              `FNC_BNE:begin
                                   ALUop = `ALU_NE;
                              end
                              `FNC_BLT:begin
                                   ALUop = `ALU_SLT;
                              end
                              `FNC_BGE:begin
                                   ALUop = `ALU_GE;
                              end
                              `FNC_BLTU:begin
                                   ALUop = `ALU_SLTU;
                              end
                              `FNC_BGEU:begin
                                   ALUop = `ALU_GEU;
                              end
                      endcase
                 end
                `OPC_JAL:begin //Jal - UJ
                      regWrite = 1;
                      memOrReg = 1;
                      rd1Sel = 0; //use PC
                      rd2Sel = 3'b100;
                      dramWrite = 1;
                      jump = 1;
                      branch =0;
                      ALUop = `ALU_ADD;
                end
                `OPC_JALR:begin //Jalr - I
                     regWrite = 1;
                     memOrReg = 1;
                     rd1Sel = 1;
                     rd2Sel = 3'b010;
                     dramWrite = 0;
                     jump = 1;
                     branch =0;
                     ALUop = `ALU_ADD;
                end
               `OPC_LUI:begin //Lui - U
                      regWrite = 1;
                      memOrReg = 1;
                      rd1Sel = 1;
                      rd2Sel = 3'b011;
                      dramWrite = 0;
                      jump = 0;
                      branch =0;
                      ALUop = `ALU_LUI;
               end
              `OPC_AUIPC:begin //AUIPC - U
                      regWrite = 1;
                      memOrReg = 1;
                      rd1Sel = 0; //use pc
                      rd2Sel = 3'b011;
                      dramWrite = 0;
                      jump = 0;
                      branch =0;
                      ALUop = `ALU_ADD;
              end
		default: begin
                      regWrite = 1'bz;
                      memOrReg = 1'bz;
                      rd1Sel = 1'bz; //use pc
                      rd2Sel = 3'bz;
                      dramWrite = 1'bz;
                      jump = 1'bz;
                      branch =1'bz;
                      ALUop = `ALU_ADD;
		end
        endcase
end 
endmodule
