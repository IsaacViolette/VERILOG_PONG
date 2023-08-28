module Ball_Movement(
	input Ball_Clock,
	input [9:0] paddle_location,
	output reg [9:0] ball_x, //ball location on the x
	output reg [9:0] ball_y, //ball location on the y
	output reg [7:0] score_counter //keeps track of number of bounces
);
	//parameters for the movement of the ball
	reg movingRight;
	reg movingDown;
	
	//Ball Reset/Start Location
	reg game_reset;
	assign game_reset = (ball_y == 480) ? 0 : 1;
	
	//continuously updates the ball coordinates
	always @(posedge Ball_Clock) begin
		//the reset stage which starts the ball at a certain coordinate
		if(~game_reset) begin
			ball_x <= 313;
			ball_y <= 80;
			movingRight = 1;
			movingDown = 0;
			score_counter = 0;
		end
		
		else begin
		if(movingRight) begin //checks if the ball is moving left
			ball_x = ball_x + 1; //moves ball right
			if (ball_x == 625) //hits right wall
				movingRight <= 0; //changes direction left
		end
		
		if(movingDown) begin //checks if the ball is moving down
			ball_y = ball_y + 1; //moves ball down
			
			//for edge case when paddle is on far left of screen because we want the ball to hit the paddle
			if(paddle_location < 15) begin 
			
				if (ball_y == 436 && (((ball_x >= (paddle_location))) && (ball_x <= (paddle_location + 80)))) begin
					movingDown <= 0;
					score_counter <= score_counter + 1;
				end
			end
			//When the paddle is 15 away from left
			else begin
				if (ball_y == 436 && (((ball_x >= (paddle_location - 14))) && (ball_x <= (paddle_location + 80)))) begin
					movingDown <= 0;
					score_counter <= score_counter + 1;
				end
			end
		end
		
		if(~movingRight)  begin //moving left
			ball_x = ball_x - 1;//moves ball left
			if (ball_x == 0) //hits left wall
				movingRight <= 1; //changes direction to right
		end
		
		if(~movingDown) begin //moving up
			ball_y = ball_y - 1; //moves ball up
			if (ball_y == 0) //hits top wall
				movingDown <= 1; //changes direction to up
		end
		end
	end
	
endmodule 

//This used to work but we updated the module since the prgress report
/*
`timescale 1ns/100ps
module Ball_Movement_tb();
	reg Ball_Clock = 0;
	reg [9:0] paddle_location;
	wire [9:0] ball_x;
	wire [9:0] ball_y;
	wire [7:0] score_counter;

Ball_Movement test_ball (.Ball_Clock,.paddle_location,.ball_x,.ball_y,.score_counter);

initial begin
	paddle_location = 0; score_counter = 0;
	forever #20 Ball_Clock <= ~Ball_Clock;
end
	
endmodule 
*/