`include "reaction_timer.v" 
`timescale 1ns / 1ns
module stimulus;
	reg clk=0, reset=0, stop=1, start=1, record=0;
	wire [7:0] sseg3, sseg2, sseg1, sseg0;
	wire led;
	reaction_timer timer(
		.start(start),
		.clk(clk),
		.reset(reset),
		.stop(stop),
		.led(led),
		.see_the_record(record),
		.sseg3(sseg3),
		.sseg2(sseg2),
		.sseg1(sseg1),
		.sseg0(sseg0)
	);

	initial forever #10 clk = ~clk;

	always @(posedge clk) 
		$display("state: %d, led: %d counter: %d, ms_counter: %d",  
			timer.state, led, timer.counter, timer.ms_counter);

	initial begin
		reset = 1;
		@(posedge clk) reset = 0; 
		start=0;
		wait(led);
		start=1;
		#2000000 stop = 0;
		@(posedge clk);
		#1 $display("STATE BEFORE %d", timer.state);
		record=1;
		@(posedge clk);	
		#1 $display("STATE AFTER %d", timer.state);
		if ({timer.record_sseg3, timer.record_sseg2, timer.record_sseg1, 
			timer.record_sseg0} == {sseg3, sseg2, sseg1, sseg0})
			$display("Passed");
		else $display("Fail");
		$display("%d %d %d %d", timer.record_bcd[15:12], timer.record_bcd[11:8], 
			timer.record_bcd[7:4], timer.record_bcd[3:0]);
		$display(timer.state);
		repeat(5) @(posedge clk);
		$display("state %d", timer.state);

		repeat(5) @(posedge clk);
			
		$display("%b %b %b %b", sseg3, sseg2, sseg1, sseg0);

		record = 0;
		@(posedge clk);
		#5 $display(timer.state);	
		$finish;
	end
endmodule
