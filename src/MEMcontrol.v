//mem control
module MEMcontrol(
            input [31:0] address,
            input [7:0] Udatain,
            input [7:0] Udataout,
            input UDataOutValid,
            input UDataInReady,
            output[31:0] reg UdataEncoding
            output reg DWrite,
            output reg DRead,
            output reg IWrite,
            output reg URead,
            output reg UWrite,
	    output reg [3:0] i_wea,
	    output reg [3:0] d_wea
);
            wire[3:0] first_4;
            wire[3:0] last_4;
            assign first_4 = address[31:28]; 
            assign last_4 = address[3:0];
            always@(*)begin
                 DWrite = 0;
                 DRead = 0;
                 IWrite = 0;
                 URead = 0;
                 UWrite = 0;
                 UdataEncoding = 32'b0;
                 case(first_4)
                       4'b0001:begin
                                DRead = 1;
                                DWrite = 1;
                       end
                       4'b0011:begin
                                DRead = 1;
                                DWrite = 1;
				IWrite = 1;
                       end
                       4'b0101:begin
                                DRead = 1;
                                DWrite = 1;
                       end
                       4'b0111:begin
                                DRead = 1;
                                DWrite = 1;
				IWrite = 1;
                       end
                       4'b0010:begin
                                IWrite = 1;
                       end
                       4'b0110:begin
                                IWrite = 1;
                       end
                       4'b1000:begin     //URAT
                                URead = 1;
                                UWrite = 1;
                                case(last_4)
                                    4'b0000:begin   //UART control
                                            URead = 1;
                                            UWrite = 0;
                                            UdataEncoding = {30'b0,UDataOutValid,UDataInReady};                       
                                    end
                                    4'b0100:begin //URAT receiver
                                            URead = 1;
                                            UWrite = 0;
                                            UdataEncoding = {24'b0,Udataout};
                                    end  
                                    4'b1000:begin //URAT transmitter
                                            URead = 0;
                                            UWrite = 1;
                                            UdataEncoding = {24'b0,Udatain};
                                    end
                                    default:begin
                                            URead = 0;
                                            UWrite = 0;
                                   end
                               endcase
                       end
                       default:begin
                       end
                 endcase
            end
endmodule
