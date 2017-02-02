module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;
  parameter   START = 1'b0;
  parameter   STOP = 1'b1;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------
  reg     [ClockCounterWidth-1:0] ClockCounter;
  wire                            SymbolEdge;
  wire                            Start;
  wire                            TXRunning;
  reg     [9:0]                   TXShift;
  reg     [3:0]                   BitCounter;



  // Goes high at every symbol edge
  assign  SymbolEdge   = (ClockCounter == SymbolEdgeTime - 1);
  // Goes high halfway through each symbol

  // Goes high when it is time to start receiving a new character
  assign  Start         = !TXRunning; //!SIn && !TXRunning;
  assign  TXRunning     = BitCounter != 4'd0;

  // Outputs
  assign  SOut = TXShift[0]; // Get the first element
  assign  DataInReady = Start;
  //assign  DataInValid = HasByte && !RXRunning; ///*


  // Counts cycles until a single symbol is done
  always @ (posedge Clock) begin
    ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end


  // Counts down from 10 bits for every character
  always @ (posedge Clock) begin
    if (Reset) begin
      BitCounter <= 4'b0;
    end else if (Start && DataInValid) begin
      BitCounter <= 4'd10;
    end else if (SymbolEdge && TXRunning) begin
      BitCounter <= BitCounter - 1;
    end
  end
	
  //--|Shift Register|----------------------------------------------------------
  always @(posedge Clock) begin
    if (Reset) TXShift <= 10'b1; //10{Stop};
    else if (SymbolEdge && TXRunning) TXShift <= {STOP, TXShift[9:1]}; // Shift to right [10:0]
    else if(DataInValid) TXShift <= {STOP, DataIn, START};
  end



endmodule
