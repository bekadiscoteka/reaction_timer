`ifndef bcd2sseg
`define bcd2sseg
module bcd2sseg (
    input wire [15:0] bcd_in, // 16-bit BCD input (4 digits)
    output reg [6:0] seg0,    // Active-low 7-segment output for digit 0
    output reg [6:0] seg1,    // Active-low 7-segment output for digit 1
    output reg [6:0] seg2,    // Active-low 7-segment output for digit 2
    output reg [6:0] seg3     // Active-low 7-segment output for digit 3
);

    // 7-Segment Decoder Function (Active-Low for DE10-Lite)
    function [6:0] bcd_to_sseg;
        input [3:0] bcd;
        begin
            case (bcd)
                4'd0: bcd_to_sseg = 7'b0111111; // 0
                4'd1: bcd_to_sseg = 7'b0000110; // 1
                4'd2: bcd_to_sseg = 7'b1011011; // 2
                4'd3: bcd_to_sseg = 7'b1001111; // 3
                4'd4: bcd_to_sseg = 7'b1100110; // 4
                4'd5: bcd_to_sseg = 7'b1101101; // 5
                4'd6: bcd_to_sseg = 7'b1111101; // 6
                4'd7: bcd_to_sseg = 7'b0000111; // 7
                4'd8: bcd_to_sseg = 7'b1111111; // 8
                4'd9: bcd_to_sseg = 7'b1101111; // 9
                default: bcd_to_sseg = 7'b0000000; // All segments off (blank)
            endcase
        end
    endfunction

    // Convert each BCD digit to 7-segment format
    always @(*) begin
        seg0 = ~bcd_to_sseg(bcd_in[3:0]);   // Least significant digit
        seg1 = ~bcd_to_sseg(bcd_in[7:4]);   // Second digit
        seg2 = ~bcd_to_sseg(bcd_in[11:8]);  // Third digit
        seg3 = ~bcd_to_sseg(bcd_in[15:12]); // Most significant digit
    end

endmodule
`endif
