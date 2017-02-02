module Forwarding(
	input [31:0] inst2,
	input [31:0] inst3,
	input control_inst2,
	input [31:0] alu_result,
	output rs1forward,
	output rs2forward,
	output flush_pip1,
	output flush_pip2
	);


	/*
	Data_hazard
	idea: If we have a data_hazard such as using a resisters before updating it, we will forward the value
	*/
	// R-R type - When we compare inst3 and inst2, if rd is either rs1 or rs2 or both, we need to forward
	// R-I or I-R 
	// I-I type
	localparam ZERO_BRANCH = 32'b1;
	localparam RTYPE = 7'b0110011;
	localparam IMMTYPE = 7'b0010011;
	localparam LOAD_ITYPE = 7'b0000011;
	localparam STYPE = 7'b0100011;  // SB
	localparam SBTYPE = 7'b1100011; // BEQ
	localparam LUI = 7'b0110111;
	localparam AUIPC = 7'b0010111;
	localparam JAL = 7'b1101111;
	localparam JALR = 7'b1100111;
        wire [6:0] op2 = inst2[6:0];
	wire [6:0] op3 = inst3[6:0];
	wire [4:0] rd3 = inst3[11:7];
	wire [4:0] rd2 = inst2[11:7];
	
	// rs1 and rs2 from 2nd instruction
	wire [4:0] rs1_2 = inst2[19:15];
	wire [4:0] rs2_2 = inst2[24:20];

	wire isUsingRD3_inst3 = !((op3 == STYPE) || (op3 == SBTYPE)); // STYPE and SBTYPE
	wire isUsingRS1_inst2 = !((op2 == LUI) || (op2 == AUIPC || op2 == JAL)); // RS1 is used for all three instructions
	wire isUsingRS2_inst2 = (op2 == SBTYPE) || (op2 == STYPE) || (op2 == RTYPE);

	wire isControl = ((op2 == SBTYPE) && (control_inst2)) || (op2 == JAL || op2 == JALR);
	wire isLoad = (op3 == LOAD_ITYPE) && (((isUsingRS1_inst2) && (rd3 == rs1_2)) || ((isUsingRS2_inst2)&&(rd3 == rs2_2))); // Need to check if 
	//wire isData;


	reg t_isControl;
	reg t_isLoad;
	reg t_isData;

	reg r_rs1forward;
	reg r_rs2forward;
	reg r_flush_pip1;
	reg r_flush_pip2;
	reg r_PC_ORIGNAL;


	// HAZARD
	always @(*) begin 
		// Control 
		if(isControl) begin
			r_rs1forward = 1'b0;
			r_rs2forward = 1'b0;
			r_flush_pip1 = 1'b1;
			r_flush_pip2 = 1'b1;
		end
		else if(isLoad) begin
			if(isUsingRD3_inst3) begin // Instead feeding NOP, just flushing pipeline
				r_flush_pip1 = 1'b0;
				r_flush_pip2 = 1'b0;
				if(isUsingRS1_inst2 && (rd3 == rs1_2))
					r_rs1forward = 1'b1;
				else
					r_rs1forward = 1'b0;
				if(isUsingRS2_inst2 && (rd3 == rs2_2))
					r_rs2forward = 1'b1;
				else
					r_rs2forward = 1'b0;
			end
			else begin
				r_flush_pip1 = 1'b0;
				r_flush_pip2 = 1'b0;
				r_rs1forward = 1'b0;
				r_rs2forward = 1'b0;
			end
		end
		else if(isUsingRD3_inst3) begin // Instead feeding NOP, just flushing pipeline
			r_flush_pip1 = 1'b0;
			r_flush_pip2 = 1'b0;
			if(isUsingRS1_inst2 && (rd3 == rs1_2))
				r_rs1forward = 1'b1;
			else
				r_rs1forward = 1'b0;
			if(isUsingRS2_inst2 && (rd3 == rs2_2))
				r_rs2forward = 1'b1;
			else
				r_rs2forward = 1'b0;
		end
		else begin
			r_flush_pip1 = 1'b0;
			r_flush_pip2 = 1'b0;
			r_PC_ORIGNAL = 1'b0;
			r_rs1forward = 1'b0;
			r_rs2forward = 1'b0;
		end
	end

	assign rs1forward = r_rs1forward;
	assign rs2forward = r_rs2forward;
	assign flush_pip1 = r_flush_pip1;
	assign flush_pip2 = r_flush_pip2;
	
endmodule

