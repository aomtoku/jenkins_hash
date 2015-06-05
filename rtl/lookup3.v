module mix(
	output wire [31:0] OA,
	output wire [31:0] OB,
	output wire [31:0] OC,
	input  wire [31:0] a,
	input  wire [31:0] b,
	input  wire [31:0] c,
	input  wire [ 4:0] shift,
	input  wire        clk
   );
   
   assign 	 OA = (a - c) ^ ( (c << shift) | (c >> (32 - shift)) );
   assign 	 OC = c + b;
   assign 	 OB = b;
   
endmodule

module lookup3(
	// Outputs
	output wire [31:0] x,
	output wire [31:0] y,
	output wire [31:0] z,
	output wire [31:0] out,
	output wire        done,
	// Inputs
	input  wire [31:0] k0,
	input  wire [31:0] k1,
	input  wire [31:0] k2,
	input  wire        clk,
	input  wire        en,
	input  wire        rst
);

wire [31:0] 	 OA, OB, OC;

wire [31:0] 	 O0A, O0B, O0C;
wire [31:0] 	 O1A, O1B, O1C;
wire [31:0] 	 O2A, O2B, O2C;
wire [31:0] 	 O3A, O3B, O3C;
wire [31:0] 	 O4A, O4B, O4C;
wire [31:0] 	 O5A, O5B, O5C;

reg [4:0] 	 shift;
reg [31:0] 	 a, b, c;

always @ (posedge clk) begin
	if (rst) begin
		a <= 32'd0;
		b <= 32'd0;
		c <= 32'd0;
	end else if (en) begin
		a <= k0;
		b <= k1;
		c <= k2;
	end
end

mix M0(
	.OA(O0A[31:0]),
	.OB(O0B[31:0]),
	.OC(O0C[31:0]),
	.a(a[31:0]),
	.b(b[31:0]),
	.c(c[31:0]),
	.clk(clk),
	.shift(5'd4)
);

mix M1(
	.OA(O1A[31:0]),
	.OB(O1B[31:0]),
	.OC(O1C[31:0]),
	.a(O0B[31:0]),
	.b(O0C[31:0]),
	.c(O0A[31:0]),
	.clk(clk),
	.shift(5'd6)
);

mix M2(
	.OA(O2A[31:0]),
	.OB(O2B[31:0]),
	.OC(O2C[31:0]),
	.a(O1B[31:0]),
	.b(O1C[31:0]),
	.c(O1A[31:0]),
	.clk(clk),
	.shift(5'd8)
);

mix M3(
	.OA(O3A[31:0]),
	.OB(O3B[31:0]),
	.OC(O3C[31:0]),
	.a(O2B[31:0]),
	.b(O2C[31:0]),
	.c(O2A[31:0]),
	.clk(clk),
	.shift(5'd16)
);

mix M4(
	.OA(O4A[31:0]),
	.OB(O4B[31:0]),
	.OC(O4C[31:0]),
	.a(O3B[31:0]),
	.b(O3C[31:0]),
	.c(O3A[31:0]),
	.clk(clk),
	.shift(5'd19)
);

mix M5(
	.OA(O5A[31:0]),
	.OB(O5B[31:0]),
	.OC(O5C[31:0]),
	.a(O4B[31:0]),
	.b(O4C[31:0]),
	.c(O4A[31:0]),
	.clk(clk),
	.shift(5'd4)
);


assign out = O5A[31:0];
assign z   = O5A[31:0];
assign y   = O5B[31:0];
assign x   = O5C[31:0];


endmodule 
