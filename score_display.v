//From Lab06 part 1
//replaced switches with score counter
module score_display(
	input [9:0] Score_Counter,
	output [6:0]HEX0_D,
	output [6:0]HEX1_D,
	output [6:0]HEX2_D
);
	wire [11:0]hold;
	Binary_to_BCD_8bit test1(Score_Counter[7:0],hold[11:0]);	
	hex_display	ones (hold[3:0], HEX0_D[6:0]);
	hex_display tens (hold[7:4],HEX1_D[6:0]);
	hex_display hundreds ({1'b0,1'b0,hold[9:8]},HEX2_D[6:0]);
endmodule 

module shift_add_three(
	input [3:0]A,
	output [3:0]S
);
	assign S[3:0]= (A[3:0]>4'd4) ? (A[3:0]+4'd3) : A[3:0];
endmodule 

module Binary_to_BCD_8bit(
	input [7:0]binary,
	output [11:0]BCD
);
	wire [3:0]first;
	wire [3:0]second;
	wire [3:0]third;
	wire [3:0]fourth;
	wire [3:0]fifth;
	wire [3:0]sixth;
	wire [3:0]seventh;
	shift_add_three  one ({1'b0, binary[7:5]},first[3:0]);
	shift_add_three two ({first[2:0],binary[4]},second[3:0]);
	shift_add_three three ({second[2:0],binary[3]},third[3:0]);
	shift_add_three four ({1'b0,first[3],second[3],third[3]},fourth[3:0]);
	shift_add_three five ({third[2:0],binary[2]},fifth[3:0]);
	shift_add_three six ({fourth[2:0],fifth[3]},sixth[3:0]);
	shift_add_three seven ({fifth[2:0],binary[1]},seventh[3:0]);
	assign BCD[11] = 1'b0;
	assign BCD[10] = 1'b0;
	assign BCD[9] = fourth[3];
	assign BCD[8:5] = sixth[3:0];
	assign BCD[4:1] = seventh[3:0];
	assign BCD[0] = binary[0];

endmodule 

module hex_display(
input [3:0] in,
output [6:0] HEX0_D
);
wire [3:0] BCD;
wire [6:0] LED_Seg;
assign BCD[3:0] = in[3:0];
assign HEX0_D[6:0] = LED_Seg[6:0];
assign LED_Seg[0] = ( (BCD[2] & !BCD[1] & !BCD[0])|(!BCD[3] & !BCD[2] & !BCD[1] & BCD[0]) );
assign LED_Seg[1] = ( (BCD[2] & !BCD[1] & BCD[0])|(BCD[2] & BCD[1] & !BCD[0]) );
assign LED_Seg[2] = (!BCD[2]& BCD[1] & !BCD[0]);
assign LED_Seg[3] = ((BCD[2] & BCD[1] & BCD[0])| (BCD[2] & !BCD[1] & !BCD[0])|(!BCD[3] & !BCD[2] & !BCD[1] & BCD[0]) );
assign LED_Seg[4] = ((BCD[2] & !BCD[1])|(!BCD[2] & BCD[0]) | (!BCD[3]&BCD[0]) );
assign LED_Seg[5] = ( (BCD[1] & BCD[0])|(!BCD[2] & BCD[1])|(!BCD[3] & !BCD[2] & BCD[0]) );
assign LED_Seg[6] = ( (!BCD[3] & !BCD[2] & !BCD[1])|
								(BCD[2] & BCD[1] & BCD[0]) );
endmodule 