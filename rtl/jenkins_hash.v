module jenkins_hash(
   input  wire        clk, 
   input  wire        rst, 
   input  wire        ce,
   input  wire [63:0] id,
   input  wire        last,
   input  wire [11:0] len,
   output wire        hash_done,
   output wire [31:0] hash_dout
);

reg [9:0] cnt;
reg [1:0] cnt3;
reg [31:0] a, b, c, d;
reg cal_en;
wire [31:0] o0, o1, o2;

always @ (*) begin
	if (rst) begin
		a <= 0;
		b <= 0;
		c <= 0;
		d <= 0;
	end else begin
		case (cnt3)
			0 : begin
				a <= (cnt > 1) ? id[31:0]  + o1 : id[31:0];
				b <= (cnt > 1) ? id[63:32] + o0 : id[63:32];
				cal_en <= (len != cnt) ? 0 : 1;
			end
			1 : begin
				c <= (cnt > 1) ? id[31:0]  + o2 : id[31:0];
				d <= id[63:32];
				cal_en <= 1;
			end
			2 : begin
				a <= (cnt > 1) ?        d  + o1 : d;
				b <= (cnt > 1) ? id[31:0]  + o0 : id[63:32];
				c <= (cnt > 1) ? id[63:32] + o2 : id[31:0] ;
				cal_en <= 1;
			end
		endcase
	end
end


always @ (posedge clk) begin
    if (rst | last) begin
        cnt  <= 0;
        cnt3 <= 0;
    end else begin
        cnt <= cnt + 10'd1;
        cnt3 <= (cnt3 == 2'd2) ? 0 : cnt3 + 2'd1;
    end
end

lookup3 inst_lookup3 (
	// Outputs
	.x(o0), 
	.y(o1), 
	.z(o2), 
	.done(),
	// Inputs
	.k0(a), 
	.k1(b), 
	.k2(c), 
	.clk(clk), 
	.en(cal_en), 
	.rst(rst)
);

reg bf_done;
assign hash_done = bf_done; 
assign hash_dout = o2;

always @ (posedge clk) 
	if (rst)
		bf_done <= 1'b0;
	else 
		bf_done <= last;


endmodule 
