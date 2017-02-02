/**
 * Top-level module for the RISCV processor.
 * This should contain instantiations of your datapath and control unit.
 * For CP1, the imem and dmem should be instantiated in this top-level module.
 * For CP2 and CP3, the memories are moved to a different module (Memory150),
 * and connected to the datapath via memory ports in the RISC I/O interface.
 *
 * CS150 Fall 14. Template written by Simon Scott.
 */
module Riscv150(
    input clk,
    input rst,
    input stall,
    // Ports for UART that go off-chip to UART level shifter
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX

    // Memory system ports
    // Only used for checkpoint 2 and 3
`ifdef CS150_CHKPNT_2_OR_3
    ,
    output [31:0] dcache_addr,
    output [31:0] icache_addr,
    output [3:0] dcache_we,

    output [3:0] icache_we,
    output dcache_re,
    output icache_re,
    output [31:0] dcache_din,
    output [31:0] icache_din,
    input [31:0] dcache_dout,
    input [31:0] instruction
`endif

    // Graphics ports
    // Only used for checkpoint 3
`ifdef CS150_CHKPNT_3
    ,
    output [31:0]  bypass_addr,
    output [31:0]  bypass_din,
    output [3:0]   bypass_we,

    input          filler_ready,
    input          line_ready,
    output  [23:0] filler_color,
    output         filler_valid,
    output  [31:0] line_color,
    output  [9:0]  line_point,
    output         line_color_valid,
    output         line_x0_valid,
    output         line_y0_valid,
    output         line_x1_valid,
    output         line_y1_valid,
    output         line_trigger
`endif
);
 
    // Understanding stall: When stall is pushed(1), instructions should not advance in the pipeline and the processor state(register files)
    localparam PC_RESET = 32'b0;

    // Declearing wire and register
    // PC unit, FSM
    reg [31:0] P_PC;
    reg [31:0] N_PC;

    // Instantiate the instruction memory here (checkpoint 1 only)
    wire i_ena;
    wire [11:0] i_addrb;
    wire [11:0] i_addra;
    // First instruction wire [31:0] i_doutb;
    wire [3:0] i_wea;

    // Instruction pack
    wire [31:0] i_doutb;
    wire [31:0] inst2;
    wire [31:0] inst3;

    // Contorl Unit
    wire [3:0] alu_op;
    wire regWrite;
    wire rd1Sel;
    wire [2:0] rd2Sel;
    wire dramWrite;
    wire memOrReg;
    wire branch;
    wire jump;
    wire [2:0] size;
    wire [4:0] wa;



    // Instantiate the Register
    wire [4:0] r_ra1;
    wire [4:0] r_ra2;
    wire [4:0] out2_wa;
    wire [31:0] r_wd;
    wire [31:0] r_rd1;
    wire [31:0] r_rd2;

    wire forwarding1;
    wire forwarding2;
    wire [31:0] new_rd1; // This must be handled with (out2_jump == 1'b1) ? OUT_PC :  pip3_alu_result) 
    wire [31:0] new_rd2;


    // Sign extension for immi
    wire [31:0] i_rd2; // 12 bits -> 32 bits, then needs 20 more
    wire [31:0] s_rd2; // 12 bits -> 32 bits, then needs 20 more
    wire [31:0] sb_rd2; // 13 bits -> 32 bits, takes 12 but the last bit is encoded with 0 so I just need 19 more
    wire [31:0] u_rd2; // needs 12 more bits
    wire [31:0] uj; // needs 12 more bits
    wire [31:0] shamt;

    // pipe1
    wire pip1_reset;
    wire [31:0] out_rd1;
    wire [31:0] out_rd2;
    wire [31:0] out_i_rd2;
    wire [31:0] out_s_rd2;
    wire [31:0] out_sb_rd2;
    wire [31:0] out_u_rd2;
    wire [31:0] out_uj;
    wire [3:0] out_ALUop;  // Control
    wire out_regWrite;
    wire out_rd1Sel;
    wire [2:0] out_rd2Sel;
    wire out_dramWrite;
    wire out_memOrReg;
    wire out_jump;
    wire out_branch;
    wire [2:0] out_size;
    wire [31:0] out_P_PC;
    wire [31:0] out_shamt;
    wire [4:0] out_wa;

    // Operand for ALU
    wire [31:0] input1; 
    wire [31:0] input2; 
    wire [31:0] alu_result;
    reg  [31:0] temp;
    wire take_branch;

    // Write control
    wire [31:0] rs2_dmem;
    wire isMemWrite;
    wire isInsWrite;
    wire isIOWrite;


    // Instantiate the data memory here (checkpoint 1 only)
    wire d_ena;
    wire [11:0] d_addr;
    wire [3:0] d_wea;
    wire [31:0] d_douta;

    // UART
    wire [7:0] DataIn;
    wire DataInReady;
    wire DataInValid;
    wire   [7:0] DataOut;
    wire         DataOutValid;
    wire         DataOutReady;


    // pip2
    wire pip2_rst;
    wire [31:0] pip3_alu_result;
    wire pip3_regWrite;
    wire pip3_memOrReg;
    wire out2_jump;
    wire [31:0] pip2_UARTOut;
    wire [2:0] pip3_size;
    wire [31:0] OUT_PC;
    wire OUT_isUARTLoad;
    wire out2_take_branch;

    // Forwarding Unit
    //wire [31:0] inst2;
    //wire [31:0] inst3;
    wire rs1forward;
    wire rs2forward;
    wire flush_pip1;
    wire flush_pip2;

    // Reading Unit
    wire [31:0] MemOut;
   
  
    // MEMOUT doesn't need to go thourhg pipeline2
    wire [31:0] UARTOut;
    wire isUARTLoad;
    reg delay_flush;

    wire [31:0] DataOutEncoding;

    reg [31:0] currPC;

    // PC units
    always @(posedge clk) begin
	if(rst)begin
		P_PC <= 32'b0;
		currPC <= 32'b0;
	end	
	else begin	
		P_PC <= N_PC;
		currPC <= P_PC;           // PC always gets NEXT PC at the rising clk edge
	end
    end

    always @(*) begin
	if(stall)
		N_PC = P_PC;  // when it is stall, maintain its old stall
	else if(rst)
		N_PC = 32'b0; // N_PC beomes 0
	else if(take_branch) // SB TYPE
		N_PC = out_sb_rd2 + out_P_PC - 32'd4; // *Check with GSI, the format of sb_rd2 is already multiplied by 2 so we don't need it
	else if (out_jump)
		N_PC = alu_result - 32'd4;// - 32'd4; // We Jump
	else
		N_PC = P_PC + 32'd4;       // Next PC
    end 


 

    // Instantiate the instruction memory here (checkpoint 1 only)
    assign i_ena = ~stall; // enable only if stall is low
    assign i_addra = alu_result[13:2]; // write address
    assign i_addrb = P_PC[13:2]; // PC
    imem_blk_ram iram(
	.clka(clk), // For UART
	.ena(i_ena), // enable
	.wea(i_wea), // write enable 
	.addra(i_addra),  
	.dina(DataOutEncoding),    //
	.clkb(clk),       // PC **GSI
	.addrb(i_addrb),  // PC **GSI
	.doutb(i_doutb)); // New instructions
    
    // Instantiate your control unit here
    Control controller(
        .inst(i_doutb),
        .ALUop(alu_op),
        .regWrite(regWrite),
	.rd1Sel(rd1Sel),   // 1 means rd1 from reg, 0 means imm
        .rd2Sel(rd2Sel), //11 means 24:20, 00 means 8 bits extend, 01 means 16 bits extend, 10 means 32bits extend   
        .dramWrite(dramWrite),
	.memOrReg(memOrReg), // 1 means Reg while 0 means mem
	.jump(jump),
	.branch(branch),
	.size(size), //imm sel for rd2:01 means 31:25+11:7, 00 means 31:20, and 10 means 31:12
	.wa(wa)
    );

    assign r_ra1 = i_doutb[19:15];
    assign r_ra2 = i_doutb[24:20];
    // Instantiate the Register
    RegFile regfile(
            .clk(clk),
	    .rst(rst),
            .we(pip3_regWrite && ~stall), // 
            .ra1(r_ra1),
	    .ra2(r_ra2),
	    .wa(out2_wa), //** Check with GSI
            .wd(r_wd),
            .rd1(r_rd1),
	    .rd2(r_rd2));


    // Sign extension for immi
    assign i_rd2 = { {20{i_doutb[31]}}, {i_doutb[31:20]} }; // 12 bits -> 32 bits, then needs 20 more
    assign s_rd2 = { {20{i_doutb[31]}}, {i_doutb[31:25]}, {i_doutb[11:7]}}; // 12 bits -> 32 bits, then needs 20 more
    assign sb_rd2 = { {20{i_doutb[31]}}, {i_doutb[7]}, {i_doutb[30:25]}, {i_doutb[11:8]}, {1'b0}};
    assign u_rd2 = { {i_doutb[31:12]}, {12{1'b0}} }; // needs 12 more bits
    assign uj = { {12{i_doutb[31]}}, {i_doutb[19:12]}, {i_doutb[20]}, {i_doutb[30:21]}, {1'b0}}; // needs 12 more bits
    assign shamt = {{27'b0},{i_doutb[24:20]}};




    Forwarding2 fwd2(
	.inst1(i_doutb),
	.inst3(inst3),
	.rs1forward(forwarding1),
	.rs2forward(forwarding2));

    assign new_rd1 = forwarding1 == 1'b1 ? r_wd : r_rd1; // This must be handled with (out2_jump == 1'b1) ? OUT_PC :  pip3_alu_result) 
    assign new_rd2 = forwarding2 == 1'b1 ? r_wd : r_rd2;
    
    //PIPELINE
    assign pip1_reset = out_jump || take_branch || rst || delay_flush ;
    Pipeline1 pip1(
		.clk(clk),
		.stall(stall),
		.rst(pip1_reset),
		.P_PC(P_PC), // **CHECK GSI
		.inst(i_doutb), // instruction
		.rd1(new_rd1),
		.rd2(new_rd2),
		.wa(wa),
		.i_rd2(i_rd2),
		.s_rd2(s_rd2),
		.sb_rd2(sb_rd2),
		.u_rd2(u_rd2),
		.uj(uj),
		.shamt(shamt),
		.ALUop(alu_op),  // Control
		.regWrite(regWrite),
		.rd1Sel(rd1Sel),
		.rd2Sel(rd2Sel),
		.dramWrite(dramWrite),
		.memOrReg(memOrReg),
		.jump(jump),
		.branch(branch),
		.size(size),
		.out_P_PC(out_P_PC),
		.out_inst(inst2), // instruction
		.out_rd1(out_rd1),
		.out_rd2(out_rd2),
		.out_wa(out_wa),
		.out_i_rd2(out_i_rd2),
		.out_s_rd2(out_s_rd2),
		.out_sb_rd2(out_sb_rd2),
		.out_u_rd2(out_u_rd2),
		.out_uj(out_uj),
		.out_shamt(out_shamt),
		.out_ALUop(out_ALUop),  // Control
		.out_regWrite(out_regWrite),
		.out_rd1Sel(out_rd1Sel),
		.out_rd2Sel(out_rd2Sel),
		.out_dramWrite(out_dramWrite),
		.out_memOrReg(out_memOrReg),
		.out_jump(out_jump),
		.out_branch(out_branch),
		.out_size(out_size)
    );

    
	/*
		Stage 2:
	*/


    // Instantiate the Register
    assign input1 = (rs1forward == 1'b1)? r_wd : ((out_rd1Sel == 1'b1) ? out_rd1 : out_P_PC); // if rd1Sel 1, then choose one from register file. Otherwise pc
    
    /*  For input2; */
    always @(*) begin
	case(out_rd2Sel)
		3'b000: temp = out_rd2;
		3'b001: temp = out_sb_rd2;
		3'b010: temp = out_i_rd2;
		3'b011: temp = out_u_rd2;
		3'b100: temp = out_uj;
		3'b101: temp = out_s_rd2;
		3'b110: temp = out_shamt;
	endcase	
    end
    assign input2 = (rs2forward == 1'b1 && out_rd2Sel == 0)? r_wd : temp;
    // No forwarding when using immi
    // assign input2 = (out_rd2Sel == 3'b000) ? (rs2forward == 1'b1 ? r_wd : temp) : temp;

    // ALU UNIT
    ALU alu(
        .A(input1),
        .B(input2),
	.ALUop(out_ALUop),
	.Out(alu_result)
    );
    
    assign take_branch = (out_branch == 1'b1) && (alu_result == 32'b1);
    assign rs2_dmem = rs2forward == 1'b1 ? r_wd : out_rd2;
    WriteMemControl writememControl(
	.data_in(rs2_dmem),
	.addr(alu_result),
	.store(out_dramWrite), // regardless to where, it needs to write
	.size(out_size), // B or H or W - B: 00 H: 01 W: 10
	.d_wea(d_wea),
	.i_wea(i_wea),
	.isMemWrite(isMemWrite),
	.isInsWrite(isInsWrite),
	.isIOWrite(isIOWrite),
	.DataInValid(DataInValid),
	.DataOutEncoding(DataOutEncoding)
	);

    //At the point we had to right to any units
    

    assign DataIn = rs2_dmem[7:0];
    //wire DataInValid = isIOWrite && DataInReady;
    UART uart(
	  .Clock(clk),
	  .Reset(rst),

	  .DataIn(DataIn),
	  .DataInValid(DataInValid), // Writing to UART
	  .DataInReady(DataInReady), // Reading from UART

	  .DataOut(DataOut),
	  .DataOutValid(DataOutValid), // Reading from UART
	  .DataOutReady(DataOutReady), // AFTER Reading from UART

	  .SIn(FPGA_SERIAL_RX),
	  .SOut(FPGA_SERIAL_TX)
     );
//DataOutReady

    // Instantiate the data memory here (checkpoint 1 only)
    assign d_ena = ~stall;
    assign d_addr = alu_result[13:2];
    dmem_blk_ram data_ram(
	.clka(clk), 
	.ena(d_ena),
	.wea(d_wea),
	.addra(d_addr),
	.dina(DataOutEncoding), 
	.douta(d_douta));
   

  
    // Stage 2  // synchrouns read so no need to use pipeline



    UARTReader myreaderforuart(
	.addr(alu_result),
	.load(out_memOrReg), 	       // regardless to where, it needs to load
	.DataOut(DataOut),   // Data from UART
	.DataOutValid(DataOutValid),    // Data from UART
	.DataInReady(DataInReady),     // DataInready
	.UARTOut(UARTOut), // MemOut
	.DataOutReady(DataOutReady),  // After Readfrom UART
	.isUARTLoad(isUARTLoad)
	);
     // Once we read, either three 
    // Stage 3



    // Pipe2
    assign pip2_rst = rst;// || delay_flush;
    Pipeline2 pip2(
	.clk(clk),
	.stall(stall),
	.rst(pip2_rst),
	.inst(inst2), // instruction
        .wa(out_wa),
	.alu_result(alu_result),	
	.regWrite(out_regWrite),	
	.memOrReg(out_memOrReg),
	
	.size(out_size),
	.in_jump(out_jump),
	.PC(out_P_PC),
        .UARTOut(UARTOut),
	.isUARTLoad(isUARTLoad),
	.take_branch(take_branch),
	.out2_take_branch(out2_take_branch),
	.OUT_isUARTLoad(OUT_isUARTLoad),

        .pip2_UARTOut(pip2_UARTOut), // important

	.OUT_PC(OUT_PC),
	.out_jump(out2_jump),
	.out2_inst(inst3), // instruction
	.out2_wa(out2_wa),
	.out2_alu_result(pip3_alu_result),  // Control
	.out2_regWrite(pip3_regWrite),
	.out2_memOrReg(pip3_memOrReg),
	.out2_size(pip3_size)
    );

    // STAGE 3
    
    // Since it is sync reads, it must be encoded data output of the memory here.
    ReadMemControl readmemcontrol(
		.data_mem(d_douta),
		.addr(pip3_alu_result),
		.load(pip3_memOrReg), // regardless to where, it needs to load
		.size(pip3_size), // B or H or W - B: 00 H: 01 W: 10
		.MemOut(MemOut)
		);	

    /*
	Forwarding Unit:
		
    */
    Forwarding fwdUnit(
	.inst2(inst2),
	.inst3(inst3),
	.control_inst2(out2_take_branch),
	.alu_result(pip3_alu_result),
	.rs1forward(rs1forward),
	.rs2forward(rs2forward),
	.flush_pip1(flush_pip1),
	.flush_pip2(flush_pip2)
    );


   //output reg memOrReg, // 1 means Reg while 0 means mem
   // Determine data
    always@(posedge clk) begin
 	if(rst)
		delay_flush <= 1'b1;
	else if(out_jump || take_branch)
		delay_flush <= 1'b1;
	else
		delay_flush <= 1'b0;
    end    

    
    assign r_wd = pip3_memOrReg == 1'b1 ? ((out2_jump == 1'b1) ? (OUT_PC + 4) :  pip3_alu_result) : (OUT_isUARTLoad ? pip2_UARTOut : MemOut); // our out_PC+4



endmodule
