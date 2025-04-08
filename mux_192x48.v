`ifndef MUX_192X48
`define MUX_192X48

module mux_192x48(
	output reg [8*6-1:0] out, 
	input [8*6-1:0] fourth, third, second, first,
	input [1:0] select,
	input see_the_record
);
	always @* begin
		if (see_the_record) out = fourth;
	   	else begin	
		case (select) 
			2'b00: out = first;
			2'b01: out = second;
			2'b10: out = third;
			default: out = 0;
		endcase
		end
	end	
endmodule
`endif
