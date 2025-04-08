`include "heart_beats.v"
`include "bcd2sseg.v"
`include "mux_192x48.v"
`include "record_logic.v"
module reaction_timer(
	output [7:0] 
	sseg5, sseg4, sseg3, sseg2, sseg1, sseg0, //segments are active-low
	output led, // done_tick, ready, 
	input clk, reset, start, stop, see_the_record // start, stop active-low
);
	localparam [1:0]
	GREETING=0,
	START=1,
	TIMER=2,
	RESULT=3;

	//initializations
	
	reg [1:0] state, nxt_state, mux_select;
	reg [15:0] counter, nxt_counter; 
	reg [14:0] ms_counter, nxt_ms_counter;
	reg [13:0] record; 
	wire [13:0] nxt_record;
	reg [15:0] record_bcd;
	wire [15:0] nxt_record_bcd;
	wire record_enable;
	reg [3:0] rand_counter, nxt_rand_counter;
	reg [3:0] bcd3, nxt_bcd3,
		bcd2, nxt_bcd2,
		bcd1, nxt_bcd1,
		bcd0, nxt_bcd0;

	wire [7:0] 
		greeting_sseg0, 
		greeting_sseg1,
   		greeting_sseg2,
   		greeting_sseg3,
		greeting_sseg4,
		greeting_sseg5,
		
		result_sseg0,
		result_sseg1,
		result_sseg2,
		result_sseg3,

		record_sseg0,
		record_sseg1,
		record_sseg2,
		record_sseg3;
	assign 
	{result_sseg3[7], result_sseg2[7], result_sseg1[7], result_sseg0[7]} = 
		4'b0111;	
	assign 
	{record_sseg3[7], record_sseg2[7], record_sseg1[7], record_sseg0[7]} = 
		4'b0111;	

	heart_beats greeting(
		.clk_50MHz(clk),
		.reset(reset),
		.sseg0(greeting_sseg0),
		.sseg1(greeting_sseg1),
		.sseg2(greeting_sseg2),
		.sseg3(greeting_sseg3),
		.sseg4(greeting_sseg4),
		.sseg5(greeting_sseg5)
	);	
	bcd2sseg result_convertion(
		.bcd_in({bcd3, bcd2, bcd1, bcd0}),
		.seg0(result_sseg0[6:0]),
		.seg1(result_sseg1[6:0]),
		.seg2(result_sseg2[6:0]),
		.seg3(result_sseg3[6:0])
	);

	bcd2sseg record_convertion(
		.bcd_in(record_bcd),
		.seg0(record_sseg0[6:0]),
		.seg1(record_sseg1[6:0]),
		.seg2(record_sseg2[6:0]),
		.seg3(record_sseg3[6:0])
	);

	mux_192x48 mux(
		.out({sseg5, sseg4, sseg3, sseg2, sseg1, sseg0}),
		.second({
			~16'b0,
			8'b10111111,
			8'b10111111,	
			8'b10111111,
			8'b10111111
		}),
		.fourth({
			~16'b0, 
			record_sseg3, 
			record_sseg2, 
			record_sseg1,
		   	record_sseg0
		}),
		.third({
			~16'b0,
		   	result_sseg3,
			result_sseg2,
		   	result_sseg1,
		   	result_sseg0
		}),
		.first({
			greeting_sseg5,
			greeting_sseg4,		
			greeting_sseg3,
			greeting_sseg2,
			greeting_sseg1,
			greeting_sseg0
		}),
		.select(mux_select),
		.see_the_record(see_the_record)
	);

	record_logic recordLogic(
		.bcd3(bcd3),
		.bcd2(bcd2),
		.bcd1(bcd1),
		.bcd0(bcd0),
		.record(record),
		.record_bcd(record_bcd),
		.ms_counter(ms_counter),
		.nxt_record(nxt_record),
		.nxt_record_bcd(nxt_record_bcd),
		.enable(record_enable)
	);
	
	assign led = state == TIMER;
	assign record_enable = state == RESULT;

	always @(posedge clk, posedge reset) begin
		if (reset) begin
			bcd3 <= 0;
			bcd2 <= 0;
			bcd1 <= 0;
			bcd0 <= 0;
			state <= 0;
			counter <= 0;
			ms_counter <= 0;
			rand_counter <= 0;			
			record <= 9999;
			record_bcd <= {4'd9, 4'd9, 4'd9, 4'd9};
		end
		else begin
			bcd3 <= nxt_bcd3;
			bcd2 <= nxt_bcd2;
			bcd1 <= nxt_bcd1;
			bcd0 <= nxt_bcd0;
			state <= nxt_state;
			counter <= nxt_counter;
			ms_counter <= nxt_ms_counter;
			rand_counter <= nxt_rand_counter;
			record <= nxt_record;
			record_bcd <= nxt_record_bcd;
		end
	end	


	always @* begin
		//default values
		nxt_state = state;
		nxt_counter = counter + 1;
		nxt_ms_counter = ms_counter;
		nxt_rand_counter = rand_counter;

		nxt_bcd3 = bcd3;
		nxt_bcd2 = bcd2;
		nxt_bcd1 = bcd1;
		nxt_bcd0 = bcd0;
		if (counter == 49_999) begin
			nxt_counter = 0;
			nxt_ms_counter = ms_counter + 1;
		end

		case (state) 
			GREETING: begin
				mux_select = GREETING;
				if (rand_counter >= 6 || rand_counter < 1) 
					nxt_rand_counter = 1;
				else nxt_rand_counter = rand_counter + 1;
				if (!start) begin
					nxt_state = START;
					nxt_ms_counter = 0;
					nxt_counter = 0;
				end
			end
			START: begin
				mux_select = START;
				if (!stop) begin
					nxt_counter = 0;
					nxt_ms_counter = 9999; 
					nxt_bcd3 = 9;
					nxt_bcd2 = 9;
					nxt_bcd1 = 9;
					nxt_bcd0 = 9;
					nxt_state = RESULT;
				end
				if (ms_counter >= (1000 * rand_counter)) begin
					nxt_state = TIMER;
					nxt_counter = 0;
					nxt_ms_counter = 0;
				end
			end
			TIMER: begin
				mux_select = TIMER;
				if (!stop) begin
					nxt_counter = 0;
					nxt_state = RESULT;
				end
				if (counter == 49_999) begin
					if (bcd0 == 9) begin
						if (bcd1 == 9) begin
							if (bcd2 == 9) begin
								nxt_bcd3 = 9;
								nxt_bcd2 = 9;
								nxt_bcd1 = 9;
								nxt_bcd0 = 9;
								nxt_state = RESULT;
								nxt_counter = 0;
								nxt_ms_counter = 9999;
							end
							else begin
								nxt_bcd2 = bcd2 + 1;
								nxt_bcd1 = 0;
								nxt_bcd0 = 0;
							end
						end
						else begin
							nxt_bcd1 = bcd1 + 1;
							nxt_bcd0 = 0;	
						end
					end	
					else nxt_bcd0 = bcd0 + 1;	
				end
			end
			RESULT: begin
				nxt_counter = counter;
				mux_select = TIMER;
				nxt_rand_counter = rand_counter + 1;	
				if (rand_counter >= 6 || rand_counter < 1) 
					nxt_rand_counter = 1;
				//if (ms_counter > 10_000) nxt_state = GREETING;	
				if (!start) begin
				   	nxt_state = START;	
					nxt_counter = 0;
					nxt_ms_counter = 0;
					nxt_bcd3 = 0;
					nxt_bcd2 = 0;
					nxt_bcd1 = 0;
					nxt_bcd0 = 0;
				end  
			end			
		endcase
	end

endmodule
