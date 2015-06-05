`timescale 1ns/1ns
module tb ();

//`define one_shot_sim

reg rst;
initial rst = 1'b0;

reg clk;
initial clk = 1'b0;
always #10 clk <= ~clk;

wire getn, endn;
reg in_cal_en = 1'b0;
`ifdef one_shot_sim
reg [63:0] in0 [1:0];
initial begin
in0[0] = 64'h62626262_61616161;
in0[1] = 64'h00000000_63636363;
end
`else
reg [63:0] in0 [96:0];
integer i, j;
reg [7:0] i0, i1, i2, i3;
reg [7:0] i4, i5, i6, i7;
initial begin
	j = 0;
	for (i = 0; i < 512; i = i + 8) begin
		i0 = i + 0;  i1 = i + 1;  i2 = i + 2;  i3 = i + 3; 
		i4 = i + 4;  i5 = i + 5;  i6 = i + 6;  i7 = i + 7;
		in0[j] = {i7, i6, i5, i4, i3, i2, i1, i0};
		j = j + 1;
	end
	in_cal_en = 1'b1;
end
`endif /* one_shot_sim */

reg [7:0]cnt = 0;
wire [63:0] in = in0[cnt];
wire [31:0] o0, o1, o2;

reg cal_en;
reg srcemp;
reg full;

`ifdef one_shot_sim
wire last = (cnt == 1);
`else
wire last = (cnt == 63);
`endif
reg busy = 0;

always @ (posedge clk) begin
	if (rst)
		cnt <= 0;
	else if (busy == 0) begin
		cnt <= cnt + 1;
	end
end

wire        done;
wire [31:0] hash;

jenkins_hash inst_jhash ( 
	.clk(clk), 
	.rst(rst), 
	.ce(1),
	.id(in),
	.last(last),
`ifdef one_shot_sim
	.len(2),
`else
	.len(64),
`endif
	.hash_done(done),
	.hash_dout(hash)
);
task waitclock;
begin
	@(posedge clk);
	#1;
end
endtask

initial begin
	$dumpfile("./test.vcd");
	$dumpvars(0, tb);
`ifndef one_shot_sim
	wait (in_cal_en);
	for (i = 0; i < 512/8; i = i + 1) begin 
		$display("Input Data : %8x",in0[i]);
	end
`endif

	srcemp = 1'b1;
	rst = 1'b1;
	waitclock;
	waitclock;
	waitclock;
	rst = 1'b0;
	full = 0;
	
	srcemp = 1'b0;
	cal_en = 1'b1;
	waitclock;
	//cal_en = 1'b0;
	
	wait (done);
	#1;
`ifdef one_shot_sim
	$display("Hash Value : %4x\tCorrect Value : aae2d3d1", hash);
`else
	$display("Hash Value : %4x\tCorrect Value : b79375ae, (512 Byte) (127 Word)", hash);
`endif
	waitclock;
	waitclock;

	$finish();
end

endmodule 
