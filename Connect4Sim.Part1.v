//Eddie Carrizales
//Evan Nibbe
//Srivatsan Srirangam
//This iVerilog code will display the following equations using a truth table.
//The iVerilog code can be modified and any other equations can be added to also be displayed.
//----------------------------------------------------------------------
module Breadboard	(w,x,y,z,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9);	//Module Header
input w,x,y,z;                        					//Specify inputs
output r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;                      	 	//Specify outputs
reg r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;                         	  	//Output is a memory area.

always @ ( w,x,y,z,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9) begin      		//Create a set of code that works line by line
                                      					// if the variables are used


//Equations:

//f0= yz+wx+wz+xy
	r0= (y & z) | (w & x) | (w & z) | (x & y);

//f1= xz+yz+wx
	r1= (x & z) | (y & z) | (w & x);

//f2= zwx + ywx + yzw +yzx                                         	//Comment for the formula
	r2= (z & w & x) | (y & w & x) | (y & z & w) | (y & z & x);              //Bitwise operation of the formula

//f3= yx + zw
	r3= (y & x) | (z & w);

//f4= yz
	r4= (y & z);

//f5= w'x'+y'z'
	r5=(!(w) & !(x)) | (!(y) & !(z));

//f6= w'x'y + w'y'z + xy'z + wx'y'z'
	r6= (!(w) & !(x) & y) | (!(w) & !(y) & z) | (x & !(y) & z) | (w & !(x) & !(y) & !(z));

//f7=wxy'z' + xy'z + w'x'yz +w'xyz' + wx'yz'
	r7= (w & x & !(y) & !(z)) | (x & !(y) & z) | (!(w) & !(x) & (y) & z) | ((!w) & (x) & (y) & !(z)) | ((w) & !(x) & (y) & !(z));

//f8= yz
	r8= y & z;
//	1	2	   3		4	5	6.   7		8
//f9= w’x’y’z + w’x’yz’ + w’xy’z’ + w’xyz + wxy’z + wxyz’ + wx’y’z’ + wx’yz;
	r9= ((!w) & !(x) & !(y) & (z)) | ((!w) & !(x) & (y) & !(z)) | ((!w) & (x) & !(y) & !(z)) | ((!w) & (x) & (y) & (z)) | ((w) & (x) & !(y) & (z)) | ((w) & (x) & (y) & !(z)) | ((w) & !(x) & !(y) & !(z)) | ((w) & !(x) & (y) & (z));
//		1				2			3				4			5			8

end                                   // Finish the Always block

endmodule                             //Module End

//----------------------------------------------------------------------

module testbench();

  //Registers act like local variables
  reg [4:0] i; //A loop control for 16 rows of a truth table.
  reg  w;//Value of 2^3
  reg  x;//Value of 2^2
  reg  y;//Value of 2^1
  reg  z;//Value of 2^0

  //A wire can hold the return of a function
  wire  f0,f1,f2,f3,f4,f5,f6,f7,f8,f9;

  //Modules can be either functions, or model chips.
  //They are instantiated like an object of a class,
  //with a constructor with parameters.  They are not invoked,
  //but operate like a thread.
  Breadboard zap(w,x,y,z,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9);


  //Initial means "start," like a Main() function.
  //Begin denotes the start of a block of code.
  initial begin

  //$display acts like a classic C printf command.
  $display ("|##|W|X|Y|Z|F0|F1|F2|F3|F4|F5|F6|F7|F8|F9|");
  $display ("|==+=+=+=+=+==+==+==+==+==+==+==+==+==+==|");

    //A for loop, with register i being the loop control variable.
	for (i = 0; i < 16; i = i + 1)
	begin//Open the code blook of the for loop
		w=(i/8)%2;//High bit
		x=(i/4)%2;
		y=(i/2)%2;
		z=(i/1)%2;//Low bit

		//Oh, Dr. Becker, do you remember what belongs here?
		#60;

		$display ("|%2d|%1d|%1d|%1d|%1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d|",i,w,x,y,z,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9);
		if(i%4==3) //Every fourth row of the table, put in a marker for easier reading.
		 $display ("|--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-|");//Only one line, does not need a code block

	end//End of the for loop code block

	#10; //A time dealy of 10 time units. Hashtag Delay
	$finish;//A command, not unlike System.exit(0) in Java.
  end  //End the code block of the main (initial)

endmodule //Close the testbench module
