`ifndef RECORD_LOGIC
`define RECORD_LOGIC

module record_logic(
	output reg [13:0] nxt_record,
	output reg [15:0] nxt_record_bcd,
   	input [3:0] bcd3, bcd2, bcd1, bcd0,
	input [13:0] record,
	input [15:0] record_bcd,
	input [14:0] ms_counter, 
	input enable
);
	always @* begin
		if (enable && (record > ms_counter)) begin
			nxt_record = ms_counter;
			nxt_record_bcd = {bcd3, bcd2, bcd1, bcd0};
		end
		else begin
			nxt_record = record;
			nxt_record_bcd = record_bcd;
		end	
	end

endmodule

`endif
