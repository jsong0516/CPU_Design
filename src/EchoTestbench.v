`timescale 1ns/1ps

module EchoTestbench();

    reg Clock, Reset;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    reg   [7:0] DataIn;
    reg         DataInValid;
    wire        DataInReady;
    wire  [7:0] DataOut;
    wire        DataOutValid;
    reg         DataOutReady;

    //`ifdef RISCV_CLK_50
        parameter HalfCycle = 10;
    //`endif `ifdef RISCV_CLK_100
    //   parameter HalfCycle = 5;
    //`endif
    parameter Cycle = 2*HalfCycle;

    initial Clock = 0;
    always #(HalfCycle) Clock <= ~Clock;

    // Instantiate your Riscv CPU here and connect the FPGA_SERIAL_TX wires
    // to the UART we use for testing
    Riscv150 CPU(
	    .clk(Clock),
	    .rst(Reset),
	    .stall(1'b0),
    
    // Ports for UART that go off-chip to UART level shifter
    .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
    .FPGA_SERIAL_TX(FPGA_SERIAL_TX));



    // Instantiate the UART
    UART          uart( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_TX),
                        .SOut(            FPGA_SERIAL_RX));


    initial begin
	  Reset = 0;
	  DataIn = 8'h7a;
	  DataInValid = 0;
	  DataOutReady = 0;
	  #(10*Cycle)

	  Reset = 1;
	  #(30*Cycle)
	  Reset = 0;

	  // Wait until transmit is ready
	  while (!DataInReady) #(Cycle);
	  DataInValid = 1'b1;
	  #(Cycle)
	  DataInValid = 1'b0;

	  $display("PASSED DATAINREADY");
	  // Wait for something to come back
	  while (!DataOutValid) #(Cycle);
	  $display("Entered %d", DataIn);
	  $display("Got %d", DataOut);

	  DataIn = 8'hBB;
	  DataInValid = 0;
	  DataOutReady = 0;
	  #(10*Cycle)

	  Reset = 1;
	  #(30*Cycle)
	  Reset = 0;

	  // Wait until transmit is ready
	  while (!DataInReady) #(Cycle);
	  DataInValid = 1'b1;
	  #(Cycle)
	  DataInValid = 1'b0;

	  $display("PASSED DATAINREADY");
	  // Wait for something to come back
	  while (!DataOutValid) #(Cycle);
	  $display("Entered %d", DataIn);
	  $display("Got %d", DataOut);

	  DataIn = 8'h12;
	  DataInValid = 0;
	  DataOutReady = 0;
	  #(10*Cycle)

	  Reset = 1;
	  #(30*Cycle)
	  Reset = 0;

	  // Wait until transmit is ready
	  while (1'b1) #(Cycle);
	  DataInValid = 1'b1;
	  #(Cycle)
	  DataInValid = 1'b0;

	  $display("PASSED DATAINREADY");
	  // Wait for something to come back
	  while (!DataOutValid) #(Cycle);
	  $display("Entered %d", DataIn);
	  $display("Got %d", DataOut);

	  DataIn = 8'h21;
	  DataInValid = 0;
	  DataOutReady = 0;
	  #(10*Cycle)

	  Reset = 1;
	  #(30*Cycle)
	  Reset = 0;

	  // Wait until transmit is ready
	  while (!DataInReady) #(Cycle);
	  DataInValid = 1'b1;
	  #(Cycle)
	  DataInValid = 1'b0;

	  $display("PASSED DATAINREADY");
	  // Wait for something to come back
	  while (!DataOutValid) #(Cycle);
	  $display("Entered %d", DataIn);
	  $display("Got %d", DataOut);

	  DataIn = 8'h13;
	  DataInValid = 0;
	  DataOutReady = 0;
	  #(10*Cycle)

	  Reset = 1;
	  #(30*Cycle)
	  Reset = 0;

	  // Wait until transmit is ready
	  while (!DataInReady) #(Cycle);
	  DataInValid = 1'b1;
	  #(Cycle)
	  DataInValid = 1'b0;

	  $display("PASSED DATAINREADY");
	  // Wait for something to come back
	  while (!DataOutValid) #(Cycle);
	  $display("Entered %d", DataIn);
	  $display("Got %d", DataOut);
	  $finish();



    end

endmodule
