// WriteModule
module WriteMemControl(
	input [31:0] data_in, // Data needs to be encoded
	input [31:0] addr,    // Address 
	input store, // regardless to where, it needs to load
	input [2:0] size, // B or H or W - B: 00 H: 01 W: 10
	output reg [3:0] d_wea,
	output reg [3:0] i_wea,
	output isMemWrite,
	output isInsWrite,
	output isIOWrite,
	output reg DataInValid,
	output reg [31:0] DataOutEncoding
	);
	
	wire [1:0] offset;
	assign offset = addr[1:0];  // offset
	assign isMemWrite = store && (addr[31] == 1'b0) && (addr[28] == 1'b1); //(addr[31:28] == 4'b0xx1);
	assign isInsWrite = store && (addr[31] == 1'b0) && (addr[29] == 1'b1);//(addr[31:28] == 4'b0x1x);
	assign isIOWrite = store && (addr[31:28] == 4'b1000) && (addr[3:0] == 4'b1000);
	
	always@(*) begin
			if(size == 3'b000) begin
				case(offset)
					2'b00:  DataOutEncoding = data_in;
					2'b01:  DataOutEncoding = {16'b0, data_in[7:0], 8'b0}; //  data_in << 32'd8; 
					2'b10:  DataOutEncoding = {8'b0, data_in[7:0], 16'b0}; //  << 32'd16; 
					2'b11:  DataOutEncoding = {data_in[7:0], 24'b0};// data_in << 32'd24; 
				endcase 
			end
			// if sh
			else if(size == 3'b001) begin
				case(offset)
					2'b11:  DataOutEncoding = {data_in[15:0], 16'b0};
					2'b10:  DataOutEncoding = {data_in[15:0], 16'b0};
					2'b01:  DataOutEncoding = data_in;
					2'b00:  DataOutEncoding = data_in;
				endcase
			end
			else
				DataOutEncoding = data_in;
	end


	// Reading
	always@(*) begin
		if(isMemWrite) begin
			//if sb
			if(size == 3'b000) begin
				case(offset)
					2'b00:  d_wea = 4'b0001;
					2'b01:  d_wea = 4'b0010;
					2'b10:  d_wea = 4'b0100;
					2'b11:  d_wea = 4'b1000;
					//*/
				endcase 
			end
			// if sh
			else if(size == 3'b001) begin
				case(offset)
					2'b11:  d_wea = 4'b1100; 
					2'b10:  d_wea = 4'b1100; 
					2'b01:  d_wea = 4'b0011; 
					2'b00:  d_wea = 4'b0011; 
					//*/
					default: d_wea = 4'bz;
				endcase
			end
			// if sw
			else if(size == 3'b010) begin
				d_wea = 4'b1111;
			end
			else
				d_wea = 4'bz;
		end
		else begin
			//DataInValid = 1'b0;
			d_wea = 4'b0000;
		end

		if(isInsWrite) begin
			//if sb
			if(size == 3'b000) begin
				case(offset)
					///*
					2'b00: i_wea = 4'b0001;
					2'b01: i_wea = 4'b0010;
					2'b10: i_wea = 4'b0100;
					2'b11: i_wea = 4'b1000;
					default: i_wea = 4'bz;
				endcase 
			end
			// if sh
			else if(size == 3'b001) begin
				case(offset)
					2'b11:  i_wea = 4'b1100; 
					2'b10:  i_wea = 4'b1100; 
					2'b01: i_wea = 4'b0011; 
					2'b00: i_wea = 4'b0011; 
					default: i_wea = 4'bz;
				endcase
			end
			// if sw
			else if(size == 3'b010) begin
				i_wea = 4'b1111;	
			end
			else
				i_wea = 4'bz;
		end
		else begin
			i_wea = 4'b0000;
		end

		if(isIOWrite) begin
			DataInValid = 1'b1;
		end
		else begin
			DataInValid = 1'b0;
		end
	end
endmodule

