module top (
	input wire        SYS_CLK,
	input wire        RSTBTN,
	output wire [7:0] LED
);

BUFG inst_clk_bufg (.I(SYS_CLK), .O(clk));

reg  [1:0] state;
reg [63:0] id;
reg        ce;
reg        last;
wire       busy_n;
wire [31:0] out;

always @ (posedge clk)
	if (rst) begin
		id    <= 0;
		state <= 2'd0;
		ce    <= 1'd0;
		last  <= 1'b0;
	end	else 
		case (state)
			2'b00 : begin
				ce    <= 1'b1;
				state <= 2'b01;
				last  <= 1'b0;
			end
			2'b01 : begin
				id <= 64'hffff_ffff_ffff_ffff;
				state <= 2'b10;
				last <= 1'b1;
			end
			2'b10 : begin
				id <= 64'h1234_5678_9abc_deff;
				state <= 2'b11;
				ce <= 1'b0;
				last <= 1'b0;
			end
			2'b11 : if (busy_n) state <= 2'b11;
		endcase



jenkins_hash inst_jhash (
	.clk        (clk),
	.rst        (rst),
	.ce         (ce),
	.id         (id), // Input Data 64bit
	.last       (last),
	.len        (12'd2), // Length 12bit
	.hash_done  (busy_n),
	.hash_dout  (out) // Output Data 32bit
);

assign LED = out[7:0];
endmodule
