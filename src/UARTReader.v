module UARTReader(
	input [31:0] addr,
	input load, 	       // regardless to where, it needs to load
	input [7:0] DataOut,   // Data from UART
	input DataOutValid,    // Data from UART
	input DataInReady,     // DataInready
	output reg [31:0] UARTOut, // MemOut
	output reg DataOutReady,  // After Readfrom UART
	output isUARTLoad
	);
	
	wire [1:0] offset; 
	assign offset = addr[1:0];  // offset
	assign isUARTLoad = ~load && (addr[31:28] == 4'b1000);
	wire UARTControl;
	assign UARTControl = isUARTLoad && (addr[3:0] == 4'b0000);
	wire UARTDATA;
	assign UARTDATA = isUARTLoad && (addr[3:0] == 4'b0100);


	// Reading
	always@(*) begin
		if (isUARTLoad) begin
			if(UARTControl) begin
				UARTOut = {30'b0, DataOutValid, DataInReady};
				DataOutReady = 1'b0;						
			end
			else if(UARTDATA) begin
				UARTOut = {24'b0, DataOut};
				DataOutReady = 1'b1;
			end
			else begin
				DataOutReady = 1'b0;
			end

		end
		else begin
			UARTOut = 32'b0;
			DataOutReady = 1'b0;
		end
	end


      
endmodule


