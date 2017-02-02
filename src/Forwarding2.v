module Forwarding2(
	input [31:0] inst1,
	input [31:0] inst3,
	output rs1forward,
	output rs2forward
	);

	/*
	Data_hazard
	idea: If we have a data_hazard such as using a resisters before updating it, we will forward the value
	*/
	// R-R type - When we compare inst3 and inst1, if rd is either rs1 or rs2 or both, we need to forward
	// R-I or I-R 
	// I-I type
	localparam ZERO_BRANCH = 32'b0;
	localparam RTYPE = 7'b0110011;
	localparam IMMTYPE = 7'b0010011;
	localparam LOAD_ITYPE = 7'b0000011;
	localparam STYPE = 7'b0100011;  // SB
	localparam SBTYPE = 7'b1100011; // BEQ
	localparam LUI = 7'b0110111;
	localparam AUIPC = 7'b0010111;
	localparam JAL = 7'b1101111;
	localparam JALR = 7'b1100111;
        wire [6:0] op1 = inst1[6:0];
	wire [6:0] op3 = inst3[6:0];
	wire [4:0] rd3 = inst3[11:7];

	// rs1 and rs2 from 2nd instruction
	wire [4:0] rs1_1 = inst1[19:15];
	wire [4:0] rs2_1 = inst1[24:20];

	wire isUsingRD3_inst3 = !((op3 == STYPE) || (op3 == SBTYPE)); // STYPE and SBTYPE
	wire isUsingRS1_inst1 = !((op1 == LUI) || (op1 == AUIPC || op1 == JAL)); // RS1 is used for all three instructions
	wire isUsingRS2_inst1 = (op1 == SBTYPE) || (op1 == STYPE) || (op1 == RTYPE);

	reg r_rs1forward;
	reg r_rs2forward;

	// HAZARD
	always @(*) begin 
		if(isUsingRD3_inst3) begin
			if(isUsingRS1_inst1 && (rd3 == rs1_1))
				r_rs1forward = 1'b1;
			else
				r_rs1forward = 1'b0;
			if(isUsingRS2_inst1 && (rd3 == rs2_1))
				r_rs2forward = 1'b1;
			else
				r_rs2forward = 1'b0;
		end
		else begin
			r_rs1forward = 1'b0;
			r_rs2forward = 1'b0;
		end
	end
        assign rs1forward = r_rs1forward;
        assign rs2forward = r_rs2forward;
endmodule
