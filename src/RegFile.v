//-----------------------------------------------------------------------------
//  Module: RegFile
//  Desc: An array of 32 32-bit registers
//  Inputs Interface:
//    clk: Clock signal
//    ra1: first read address (asynchronous)
//    ra2: second read address (asynchronous)
//    wa: write address (synchronous)
//    we: write enable (synchronous)
//    wd: data to write (synchronous)
//  Output Interface:
//    rd1: data stored at address ra1
//    rd2: data stored at address ra2
//-----------------------------------------------------------------------------

module RegFile(input clk,
               input we,
	       input rst,
               input  [4:0] ra1, ra2, wa,
               input  [31:0] wd,
               output reg [31:0] rd1, rd2);

    // Implement your register file here, then delete this comment.
    localparam R0 = 5'd0;
    localparam R1 = 5'd1;
    localparam R2 = 5'd2;
    localparam R3 = 5'd3;
    localparam R4 = 5'd4;
    localparam R5 = 5'd5;
    localparam R6 = 5'd6;
    localparam R7 = 5'd7;
    localparam R8 = 5'd8;
    localparam R9 = 5'd9;
    localparam R10 = 5'd10;
    localparam R11 = 5'd11;
    localparam R12 = 5'd12;
    localparam R13 = 5'd13;
    localparam R14 = 5'd14;
    localparam R15 = 5'd15;
    localparam R16 = 5'd16;
    localparam R17 = 5'd17;
    localparam R18 = 5'd18;
    localparam R19 = 5'd19;
    localparam R20 = 5'd20;
    localparam R21 = 5'd21;
    localparam R22 = 5'd22;
    localparam R23 = 5'd23;
    localparam R24 = 5'd24;
    localparam R25 = 5'd25;
    localparam R26 = 5'd26;
    localparam R27 = 5'd27;
    localparam R28 = 5'd28;
    localparam R29 = 5'd29;
    localparam R30 = 5'd30;
    localparam R31 = 5'd31;

    ///////////////////////////// total 32 registers ///////////////////////////////////
    (* ram_style = "distributed" *) reg [31:0] reg0;
    (* ram_style = "distributed" *) reg [31:0] reg1;
    (* ram_style = "distributed" *) reg [31:0] reg2;
    (* ram_style = "distributed" *) reg [31:0] reg3;
    (* ram_style = "distributed" *) reg [31:0] reg4;
    (* ram_style = "distributed" *) reg [31:0] reg5;
    (* ram_style = "distributed" *) reg [31:0] reg6;
    (* ram_style = "distributed" *) reg [31:0] reg7;
    (* ram_style = "distributed" *) reg [31:0] reg8;
    (* ram_style = "distributed" *) reg [31:0] reg9;
    (* ram_style = "distributed" *) reg [31:0] reg10;
    (* ram_style = "distributed" *) reg [31:0] reg11;
    (* ram_style = "distributed" *) reg [31:0] reg12;
    (* ram_style = "distributed" *) reg [31:0] reg13;
    (* ram_style = "distributed" *) reg [31:0] reg14;
    (* ram_style = "distributed" *) reg [31:0] reg15;
    (* ram_style = "distributed" *) reg [31:0] reg16;
    (* ram_style = "distributed" *) reg [31:0] reg17;
    (* ram_style = "distributed" *) reg [31:0] reg18;
    (* ram_style = "distributed" *) reg [31:0] reg19;
    (* ram_style = "distributed" *) reg [31:0] reg20;
    (* ram_style = "distributed" *) reg [31:0] reg21;
    (* ram_style = "distributed" *) reg [31:0] reg22;
    (* ram_style = "distributed" *) reg [31:0] reg23;
    (* ram_style = "distributed" *) reg [31:0] reg24;
    (* ram_style = "distributed" *) reg [31:0] reg25;
    (* ram_style = "distributed" *) reg [31:0] reg26;
    (* ram_style = "distributed" *) reg [31:0] reg27;
    (* ram_style = "distributed" *) reg [31:0] reg28;
    (* ram_style = "distributed" *) reg [31:0] reg29;
    (* ram_style = "distributed" *) reg [31:0] reg30;
    (* ram_style = "distributed" *) reg [31:0] reg31;

    // sync write
    always@(posedge clk) begin
	if(rst) begin
		reg0 <= 32'b0;
		reg1 <= 32'b0;
		reg2 <= 32'b0;
		reg3 <= 32'b0;
		reg4 <= 32'b0;
		reg5 <= 32'b0;
		reg6 <= 32'b0;
		reg7 <= 32'b0;
		reg8 <= 32'b0;
		reg9 <= 32'b0;
		reg10 <= 32'b0;
		reg11 <= 32'b0;
		reg12 <= 32'b0;
		reg13 <= 32'b0;
		reg14 <= 32'b0;
		reg15 <= 32'b0;
		reg16 <= 32'b0;
		reg17 <= 32'b0;
		reg18 <= 32'b0;
		reg19 <= 32'b0;
		reg20 <= 32'b0;
		reg21 <= 32'b0;
		reg22 <= 32'b0;
		reg23 <= 32'b0;
		reg24 <= 32'b0;
		reg25 <= 32'b0;
		reg26 <= 32'b0;
		reg27 <= 32'b0;
		reg28 <= 32'b0;
		reg29 <= 32'b0;
		reg30 <= 32'b0;
		reg31 <= 32'b0;
	end
	else if(we) begin
		case (wa)
			R0: reg0 <= 32'b0;
			R1: reg1 <= wd;
			R2: reg2 <= wd;
			R3: reg3 <= wd;
			R4: reg4 <= wd;
			R5: reg5 <= wd;
			R6: reg6 <= wd;
			R7: reg7 <= wd;
			R8: reg8 <= wd;
			R9: reg9 <= wd;
			R10: reg10 <= wd;
			R11: reg11 <= wd;
			R12: reg12 <= wd;
			R13: reg13 <= wd;
		    	R14: reg14 <= wd;
			R15: reg15 <= wd;
			R16: reg16 <= wd;
			R17: reg17 <= wd;
			R18: reg18 <= wd;
			R19: reg19 <= wd;
			R20: reg20 <= wd;
			R21: reg21 <= wd;
			R22: reg22 <= wd;
			R23: reg23 <= wd;
			R24: reg24 <= wd;
			R25: reg25 <= wd;
			R26: reg26 <= wd;
			R27: reg27 <= wd;
			R28: reg28 <= wd;
			R29: reg29 <= wd;
			R30: reg30 <= wd;
			R31: reg31 <= wd;
			default: reg0 <= 32'b0;
		endcase
	end
	// else, maintain the old value
	else begin
		case (wa)
			R0: reg0 <= reg0;
			R1: reg1 <= reg1;
			R2: reg2 <= reg2;
			R3: reg3 <= reg3;
			R4: reg4 <= reg4;
			R5: reg5 <= reg5;
			R6: reg6 <= reg6;
			R7: reg7 <= reg7;
			R8: reg8 <= reg8;
			R9: reg9 <= reg9;
			R10: reg10 <= reg10;
			R11: reg11 <= reg11;
			R12: reg12 <= reg12;
			R13: reg13 <= reg13;
		    	R14: reg14 <= reg14;
			R15: reg15 <= reg15;
			R16: reg16 <= reg16;
			R17: reg17 <= reg17;
			R18: reg18 <= reg18;
			R19: reg19 <= reg19;
			R20: reg20 <= reg20;
			R21: reg21 <= reg21;
			R22: reg22 <= reg22;
			R23: reg23 <= reg23;
			R24: reg24 <= reg24;
			R25: reg25 <= reg25;
			R26: reg26 <= reg26;
			R27: reg27 <= reg27;
			R28: reg28 <= reg28;
			R29: reg29 <= reg29;
			R30: reg30 <= reg30;
			R31: reg31 <= reg31;
			default: reg0 <= 32'b0;
		endcase
	end
    end

    // async read for ra1
    always @(*) begin
	case(ra1)
		R0: rd1 = 32'b0;
		R1: rd1 = reg1;
		R2: rd1 = reg2;
		R3: rd1 = reg3;
		R4: rd1 = reg4;
		R5: rd1 = reg5;
		R6: rd1 = reg6;
		R7: rd1 = reg7;
		R8: rd1 = reg8;
		R9: rd1 = reg9;
		R10: rd1 = reg10;
		R11: rd1 = reg11;
		R12: rd1 = reg12;
		R13: rd1 = reg13;
	    	R14: rd1 = reg14;
		R15: rd1 = reg15;
		R16: rd1 = reg16;
		R17: rd1 = reg17;
		R18: rd1 = reg18;
		R19: rd1 = reg19;
		R20: rd1 = reg20;
		R21: rd1 = reg21;
		R22: rd1 = reg22;
		R23: rd1 = reg23;
		R24: rd1 = reg24;
		R25: rd1 = reg25;
		R26: rd1 = reg26;
		R27: rd1 = reg27;
		R28: rd1 = reg28;
		R29: rd1 = reg29;
		R30: rd1 = reg30;
		R31: rd1 = reg31;
		default: rd1 = 32'bz;
	endcase
    end

    // async read for ra2
    always @(*) begin
	case(ra2)
		R0: rd2 = 32'b0;
		R1: rd2 = reg1;
		R2: rd2 = reg2;
		R3: rd2 = reg3;
		R4: rd2 = reg4;
		R5: rd2 = reg5;
		R6: rd2 = reg6;
		R7: rd2 = reg7;
		R8: rd2 = reg8;
		R9: rd2 = reg9;
		R10: rd2 = reg10;
		R11: rd2 = reg11;
		R12: rd2 = reg12;
		R13: rd2 = reg13;
	    	R14: rd2 = reg14;
		R15: rd2 = reg15;
		R16: rd2 = reg16;
		R17: rd2 = reg17;
		R18: rd2 = reg18;
		R19: rd2 = reg19;
		R20: rd2 = reg20;
		R21: rd2 = reg21;
		R22: rd2 = reg22;
		R23: rd2 = reg23;
		R24: rd2 = reg24;
		R25: rd2 = reg25;
		R26: rd2 = reg26;
		R27: rd2 = reg27;
		R28: rd2 = reg28;
		R29: rd2 = reg29;
		R30: rd2 = reg30;
		R31: rd2 = reg31;
		default: rd2 = 32'bz;
	endcase
    end
endmodule
