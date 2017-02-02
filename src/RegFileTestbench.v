`timescale 1ns/1ps

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

module RegFileTestbench();

    reg Clock;

    reg         we;
    reg      [4:0]   ra1;
    reg      [4:0]   ra2;
    reg      [4:0]    wa;
    reg      [31:0]   wd;
    reg      [31:0]   rd1_expect;
    reg      [31:0]   rd2_expect;
    wire     [31:0]   rd1;
    wire     [31:0]   rd2;

    parameter Halfcycle = 5; //half period is 5ns
    localparam Cycle = 2*Halfcycle;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;


    // Task for checking output
    task checkOutput;
	input   [31:0]     rd1_expect;
	input   [31:0]     rd2_expect;
	input   [31:0]     rd1;
	input   [31:0]     rd2;        
	if ( rd1 !== rd1_expect || rd2 !== rd2_expect ) begin
		$display("FAIL: Incorrect result for rd1_expect = %d, rd1 = %d , rd2_expect = %d, rd2 = %d", rd1_expect, rd1, rd2_expect, rd2);
	end
	else begin
		$display("PASS: Incorrect result for rd1_expect = %d, rd1 = %d , rd2_expect = %d, rd2 = %d", rd1_expect, rd1, rd2_expect, rd2);
	end
    endtask


    // Instantiate the Regfile
    RegFile regfiles(.clk(Clock),
               .we(we),
               .ra1(ra1), 
	       .ra2(ra2),
               .wa(wa),
               .wd(wd),
               .rd1(rd1), 
	       .rd2(rd2));



    initial begin
	    #1; // Storing && reading same register
		we = 1'b1;
    		ra1 = 5'd5; // Read from r5
    		ra2 = 5'd5; // Read from r5
    		wa = 5'd5;  // Write to r5
    		wd = 32'd11; // Write 11
		#(Cycle);
    		rd1_expect = 32'd11; // Expecting 11
    		rd2_expect = 32'd11; // Expecting 11
	    #1;
	    checkOutput(rd1_expect, rd2_expect, rd1, rd2);   

	    #2; // Storing && reading same register
		we = 1'b0;
    		ra1 = 5'd5; // Read from r5
    		ra2 = 5'd5; // Read from r5
    		wa = 5'd5;  // Write to r5
    		wd = 32'd11; // Write 11
    		rd1_expect = 32'd11; // Expecting 11
    		rd2_expect = 32'd11; // Expecting 11
	    	#(Cycle);
	    #2;
	    checkOutput(rd1_expect, rd2_expect, rd1, rd2);   

/*
	    #2; // Just reading not storing
	    	we = ;
	    	ra1 = ;
	    	ra2 = ;
	    	wa = ;
	    	wd = ;
	    	#(Cycle);
	    #2;
	    checkOutput(opcode, funct, add_rshift_type);

	    #3; // Just reading
	    	we = ;
	    	ra1 = ;
	    	ra2 = ;
	    	wa = ;
	    	wd = ;
	    	#(Cycle);
	    #3;
	    checkOutput(opcode, funct, add_rshift_type);

	    #4; // Setting R0
	    	we = ;
	    	ra1 = ;
	    	ra2 = ;
	    	wa = ;
	    	wd = ;
	    	#(Cycle);
	    #4;
	    checkOutput(opcode, funct, add_rshift_type);

	    #5; // Reading and Setting 
	    	we = ;
	    	ra1 = ;
	    	ra2 = ;
	    	wa = ;
	    	wd = ;
	    	#(Cycle);
	    #5;
	    checkOutput(opcode, funct, add_rshift_type);
*/

    $finish();
    end

endmodule
