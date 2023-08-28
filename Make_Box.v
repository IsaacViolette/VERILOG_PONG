module make_box(
	input [9:0] X_pix,
	input [9:0] Y_pix,
	input [9:0] box_width,
	input [9:0] box_height,
	input [9:0] box_x_location,
	input [9:0] box_y_location,
	input pixel_clk,
	output reg box
);

always @(posedge pixel_clk)
begin
	if((X_pix > box_x_location) && (X_pix < (box_x_location+box_width)) && (Y_pix > box_y_location) && (Y_pix < (box_y_location+box_height)))
		box = 1;
	else
		box = 0;
end
endmodule 



`timescale 1ns/100ps
module make_boxtop_tb();
	reg [9:0] X_pix;
	reg [9:0] Y_pix;
	reg [9:0] box_width;
	reg [9:0] box_height;
	reg [9:0] box_x_location;
	reg [9:0] box_y_location;
	reg pixel_clk = 0;
	wire box;
make_box test(.X_pix,.Y_pix,.box_width,.box_height, .box_x_location,.box_y_location,.pixel_clk,.box);
initial begin
	X_pix <= 0;
	Y_pix <= 0;
	box_width <= 15;
	box_height <= 15;
	box_x_location <= 50;
	box_y_location <= 50;
	forever #20 pixel_clk <= ~pixel_clk;
end

always @(posedge pixel_clk) begin
	if(X_pix < 640)
		X_pix <= X_pix+1;
	else begin
		X_pix <= 0;
		Y_pix <= Y_pix+1;
	end
	if(Y_pix > 479) Y_pix = 0;
	
end
	
endmodule 