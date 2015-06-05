SRC = tb.v ../rtl/lookup3.v ../rtl/jenkins_hash.v

tb : 
	iverilog -o tb_system ${SRC}

sim : tb_system
	./tb_system

wave: test.vcd
	gtkwave test.vcd

clean :
	rm -f tb_system *.vcd 
