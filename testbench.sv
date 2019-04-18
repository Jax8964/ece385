
module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic         CLK;
integer i = 0;
/////////////////////////////
logic         w,r;
logic [15:0]  address;
logic [7:0]   in;
logic [7:0]  out;
cpu_memory cpu_memory_test(.*);



// Toggle the clock
// #1 means wait for a delay of 1 timeunit

always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end
initial begin: CLOCK_INITIALIZATION
    CLK = 0;
end 
// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program

initial begin: TEST_VECTORS

w = 0;
r = 0;
address = 0;
in = 0;

#2;
// w = 1;
// address = 0;
// in = 8'b1;
// #2;
// w = 0;
// address = 0;
// in = 8'b1;

// #2;
// w = 1;
// address = 3;
// in = 8'hff;
// #2;
// w = 0;
// address = 3;
// in = 8'hff;

// #2;
// w = 1;
// address = 7;
// in = 8'hab;
// #2;
// w = 0;
// address = 7;
// in = 8'hab;


// #2;
// w = 0;
// address = 3;
// in = 8'hab;

for(i=0;i<11;i=i+1) begin
    $display("memory %d\t: %x\n", i, cpu_memory_test.ram[i]);
end



end
endmodule
