module Paddle_Movement(
	input Paddle_Clock,
	input moving_right,
	input moving_left,
	output reg [9:0] paddle_x 
);

	initial begin
		paddle_x <= 280; //paddle starts in the middle of screen on initial start
	end
	
	always @(posedge Paddle_Clock) begin
		if(moving_left == moving_right) //both or neither buttons pressed at same time
			paddle_x <= paddle_x; //paddle doesn't move
		else if(moving_right && paddle_x !== 555) begin //when button[1] is pressed and location of paddle isn't all the way right
			paddle_x <= paddle_x + 1; //paddle moves right
		end
		else if(moving_left && paddle_x !== 5) begin //when button[2] is pressed and location of paddle isn't all the way left
			paddle_x <= paddle_x - 1; //paddle moves left
		end
		
	end

endmodule 


`timescale 1ns/100ps
module Paddle_Movement_tb();
	reg Paddle_Clock = 0;
	reg moving_right;
	reg moving_left;
	wire [9:0] paddle_x;
	
	Paddle_Movement test_paddle (.Paddle_Clock,.moving_right,.moving_left,.paddle_x);
	
	initial begin
		
		moving_left <= 0; moving_right <= 0;
		#300 moving_left = 1; moving_right = 0;
		#300 moving_left = 0; moving_right = 1;
		#300 moving_left = 1; moving_right = 1;
	end
	
	initial begin
		forever #1 Paddle_Clock <= ~Paddle_Clock;
	end
	
endmodule 