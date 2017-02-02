module ReadMemControl(
	input [31:0] data_mem,
	input [31:0] addr,     // Address
	input load, 	       // regardless to where, it needs to load
	input [2:0] size,      // Masking B or H or W - B: 00 H: 01 W: 10
	output reg [31:0] MemOut // MemOut
	);
	
	wire [1:0] offset; 
	assign offset = addr[1:0];  // offset
	wire isMemLoad = ~load && (addr[31] == 1'b0 && addr[28] == 1'b1);

	// Reading
	always@(*) begin
		if(isMemLoad) begin
			//if lb
			if(size == 3'b000) begin
				case(offset)
					2'b00: MemOut = {{24{data_mem[7]}}, {data_mem[7:0]}}; // The other way
					2'b01: MemOut = {{24{data_mem[15]}}, {data_mem[15:8]}};
					2'b10: MemOut = {{24{data_mem[23]}}, {data_mem[23:16]}};
					2'b11: MemOut = {{24{data_mem[31]}}, {data_mem[31:24]}};
				endcase 
			end
			// if lh
			if(size == 3'b001) begin
				case(offset)
					2'b11: MemOut = {{16{data_mem[31]}}, data_mem[31:16]};
					2'b10: MemOut = {{16{data_mem[31]}}, data_mem[31:16]};
				
					2'b01: MemOut = {{16{data_mem[15]}}, data_mem[15:0]};
					2'b00: MemOut = {{16{data_mem[15]}}, data_mem[15:0]};
					default: MemOut = 32'bz;
				endcase
			end
			// if lw
			if(size == 3'b010) begin
				MemOut = data_mem;
			end
			
			if(size == 3'b100) begin // LBU
				case(offset)
					2'b00: MemOut = {24'b0, data_mem[7:0]};
					2'b01: MemOut = {24'b0, data_mem[15:8]};
					2'b10: MemOut = {24'b0, data_mem[23:16]};
					2'b11: MemOut = {24'b0, data_mem[31:24]};
				endcase 	
			end
			if(size == 3'b101) begin // LHU
				case(offset)
					2'b11: MemOut = {16'b0, data_mem[31:16]};
					2'b10: MemOut = {16'b0, data_mem[31:16]};
				
					2'b01: MemOut = {16'b0, data_mem[15:0]};
					2'b00: MemOut = {16'b0, data_mem[15:0]};
					default: MemOut = 32'bz;
				endcase
			end
		end
		else begin
			MemOut = 32'b0;
		end
	end

 


endmodule


