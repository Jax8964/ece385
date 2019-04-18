
module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic           CLK;
integer         i = 0;
/////////////////////////////
logic         w;
logic [15:0]  address;
logic [7:0]   in;
logic [7:0]   OUTL,OUTH;
logic [15:0]  data;
cpu_memory cpu_memory_test(.*);
always_ff @(posedge CLK) begin
    data <= {OUTH,OUTL};
end


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
address = 0;
in = 0;
#1;

w = 1;
address = 4;
in = 8'h99;
#2;
w = 1;
address = 5;
in = 8'h22;

#2;
w = 1;
address = 6;
in = 8'h00;

#2;
w = 0;
address = 0;
#2;
address = 1;
#2;
address = 2;
#2;
address = 3;
#2;
address = 4;
#2;
address = 5;
#2;
address = 6;
#10;
#2;
w = 0;
address = 3;
in = 8'hff;

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

for(i=0;i<10;i=i+1) begin
    $display("memory %d\t: %h\n", i, cpu_memory_test.ram[i]);
end



end
endmodule
