`ifndef HEART_BEATS
`define HEART_BEATS

module heart_beats(
	output reg [7:0] 
	sseg5, sseg4, sseg3, sseg2, sseg1, sseg0,
	input clk_50MHz, reset
);

	//clock freq setup
	//desired freq is 75Hz, DE10 Lite board has 50MHz	
	
	reg [22:0] counter;
	reg [(8*6)-1:0] next_s;

	always @(posedge clk_50MHz, posedge reset) begin
		if (reset) begin
			counter <= 0;
			{sseg5, sseg4, sseg3, sseg2, sseg1, sseg0} <= S0;
		end
		else begin
			if (counter == 23'd4_300_000) begin //666_666
			   	counter <= 0;
				{sseg5, sseg4, sseg3, sseg2, sseg1, sseg0} <= next_s;
			end
			else counter <= counter + 1;
		end
	end
	



	
	localparam 
	S0 = {8'b1111_1111, 8'b1111_1111, 8'b1111_1001, 
		8'b1100_1111, 8'b1111_1111, 8'b1111_1111},
	S1 = {8'b1111_1111, 8'b1111_1111, 8'b1100_1111, 
		8'b1111_1001, 8'b1111_1111, 8'b1111_1111},
	S2 = {8'b1111_1111, 8'b1111_1001, 8'b1111_1111, 
		8'b1111_1111, 8'b1100_1111, 8'b1111_1111},
	S3 = {8'b1111_1111, 8'b1100_1111, 8'b1111_1111, 
		8'b1111_1111, 8'b1111_1001, 8'b1111_1111},
	S4 = {8'b1111_1001, 8'b1111_1111, 8'b1111_1111, 
		8'b1111_1111, 8'b1111_1111, 8'b1100_1111},
	S5 = {8'b1100_1111, 8'b1111_1111, 8'b1111_1111, 
		8'b1111_1111, 8'b1111_1111, 8'b1111_1001};


	always @* begin
		case ({sseg5, sseg4, sseg3, sseg2, sseg1, sseg0}) 
			S0 : next_s = S1;
			S1 : next_s = S2;
			S2 : next_s = S3;
			S3 : next_s = S4;
			S4 : next_s = S5;
			default : next_s = S0;
		endcase
	end

endmodule
`endif
