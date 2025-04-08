module mux_192x48(
	output reg [8*6-1:0] out, 
	input [8*6*3-1:0] fourth, third, second, first,
	input [1:0] select
);
	always @* begin
		case (select) 
			2'b00: out = first;
			2'b01: out = second;
			2'b10: out = third;
			2'b11: out = fourth;
			default: out = 0;
		endcase
	end	
endmodule
