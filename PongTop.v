`include "./DE0_VGA.v"
`include "./make_box.v"
`include "./Ball_Movement.v"
`include "./Paddle_Movement.v"
`include "./score_display.v"

module PongTop(CLK_50, VGA_BUS_R, VGA_BUS_G, VGA_BUS_B, VGA_HS, VGA_VS, ORG_BUTTON, HEX0_D, HEX1_D, HEX2_D);

input	wire			CLK_50;
input [2:0]			ORG_BUTTON;
output [6:0]		HEX0_D;
output [6:0]		HEX1_D;
output [6:0]		HEX2_D;

output	reg	[3:0]		VGA_BUS_R;		//Output Red
output	reg	[3:0]		VGA_BUS_G;		//Output Green
output	reg	[3:0]		VGA_BUS_B;		//Output Blue

output	reg	[0:0]		VGA_HS;			//Horizontal Sync
output	reg	[0:0]		VGA_VS;			//Vertical Sync

reg			[9:0]		X_pix;			//Location in X of the driver
reg			[9:0]		Y_pix;			//Location in Y of the driver

reg			[0:0]		H_visible;		//H_blank?
reg			[0:0]		V_visible;		//V_blank?

wire		[0:0]		pixel_clk;		//Pixel clock. Every clock a pixel is being drawn. 
reg			[9:0]		pixel_cnt;		//How many pixels have been output.

reg			[11:0]		pixel_color;	//12 Bits representing color of pixel, 4 bits for R, G, and B
										//4 bits for Blue are in most significant position, Red in least
	
//Draw left border
	wire [9:0] left_width = 5;
	wire [9:0] left_height = 480;
	wire [9:0] left_x_location = 0;
	wire [9:0] left_y_location = 0;
	reg left;
	
	make_box draw_left (
		.X_pix(X_pix),
		.Y_pix(Y_pix),
		.box_width(left_width),
		.box_height(left_height),
		.box_x_location(left_x_location),
		.box_y_location(left_y_location),
		.pixel_clk(pixel_clk),
		.box(left)
	
	);


//Draw right border
	wire [9:0] right_width = 5;
	wire [9:0] right_height = 480;
	wire [9:0] right_x_location = 635;
	wire [9:0] right_y_location = 0;
	reg right;
	
	make_box draw_right (
		.X_pix(X_pix),
		.Y_pix(Y_pix),
		.box_width(right_width),
		.box_height(right_height),
		.box_x_location(right_x_location),
		.box_y_location(right_y_location),
		.pixel_clk(pixel_clk),
		.box(right)
	
	);
	
	

//Draw top border
	wire [9:0] top_width = 640;
	wire [9:0] top_height = 5;
	wire [9:0] top_x_location = 0;
	wire [9:0] top_y_location = 3;
	reg top;
	
	make_box draw_top (
		.X_pix(X_pix),
		.Y_pix(Y_pix),
		.box_width(top_width),
		.box_height(top_height),
		.box_x_location(top_x_location),
		.box_y_location(top_y_location),
		.pixel_clk(pixel_clk),
		.box(top)
	
	);

	

//Draw the player paddle
	wire [9:0] paddle_width = 80;
	wire [9:0] paddle_height = 15;
	wire [9:0] paddle_x_location;
	wire [9:0] paddle_y_location = 450;
	reg paddle;
	reg paddle_clock;
	reg [31:0] paddle_counter = 0;
	
	Paddle_Movement move_paddle(
	.Paddle_Clock(paddle_clock),
	.moving_right(ORG_BUTTON[2]),  //player input
	.moving_left(ORG_BUTTON[1]),   //player input
	.paddle_x(paddle_x_location)
	);
	
	
	make_box draw_paddle (
		.X_pix(X_pix),
		.Y_pix(Y_pix),
		.box_width(paddle_width),
		.box_height(paddle_height),
		.box_x_location(paddle_x_location),
		.box_y_location(paddle_y_location),
		.pixel_clk(pixel_clk),
		.box(paddle)
	
	);
	
	
	//Paddle clock to control how fast the paddle location is updating
	always @(posedge CLK_50) begin
		if(paddle_counter != 120000+(score_counter*250))
			paddle_counter = paddle_counter+1;
		else begin
			paddle_counter = 0;
			paddle_clock = !paddle_clock;
		end
	end
	
	

	//Draw the ball
	wire [9:0] ball_width = 15;
	wire [9:0] ball_height = 15;
	wire [9:0] ball_x_location;
	wire [9:0] ball_y_location;
	reg ball;
	reg ball_clock = 0;
	reg [31:0] ball_counter = 0;

	//Ball clock to control how fast the ball moves on display
	always @(posedge CLK_50) begin
		if(ball_counter != 80000-(500*score_counter))
			ball_counter = ball_counter+1;
		else begin
			ball_counter = 0;
			ball_clock = !ball_clock;
		end
	end
	
	Ball_Movement(
	.Ball_Clock(ball_clock),
	.paddle_location(paddle_x_location),
	.ball_x(ball_x_location),
	.ball_y(ball_y_location),
	.score_counter(score_counter)
	);
	
	
	make_box draw_ball(
		.X_pix(X_pix),
		.Y_pix(Y_pix),
		.box_width(ball_width),
		.box_height(ball_height),
		.box_x_location(ball_x_location),
		.box_y_location(ball_y_location),
		.pixel_clk(pixel_clk),
		.box(ball)
	
	);
	
	
	wire [7:0] score_counter;
	
	//to track the total times the ball bounces off paddle on hex display
	score_display(
	.Score_Counter(score_counter),
	.HEX0_D(HEX0_D),
	.HEX1_D(HEX1_D),
	.HEX2_D(HEX2_D)
	);
	

	always @(posedge pixel_clk)
	begin
		if(paddle) pixel_color <= 12'b1111_1111_1111;
		else if(ball) pixel_color <= 12'b1111_1111_1111;
		else if(left) pixel_color <= 12'b1111_1111_1111;
		else if(right) pixel_color <= 12'b1111_1111_1111;
		else if(top) pixel_color <= 12'b1111_1111_1111;
		else pixel_color <= 12'b0000_0000_0000;
	end
	
		//Pass pins and current pixel values to display driver
		DE0_VGA VGA_Driver
		(
			.clk_50(CLK_50),
			.pixel_color(pixel_color),
			.VGA_BUS_R(VGA_BUS_R), 
			.VGA_BUS_G(VGA_BUS_G), 
			.VGA_BUS_B(VGA_BUS_B), 
			.VGA_HS(VGA_HS), 
			.VGA_VS(VGA_VS), 
			.X_pix(X_pix), 
			.Y_pix(Y_pix), 
			.H_visible(H_visible),
			.V_visible(V_visible), 
			.pixel_clk(pixel_clk),
			.pixel_cnt(pixel_cnt)
		);

endmodule
