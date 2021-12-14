//Evan Nibbe, Srivatsan Srirangam, Eddie Carrizales
//Dec 11, 2021
//Connect4Sim.Part4.v
//This code is derived from the code given by Dr. Eric Becker
//This code is an Arithmetic Logic Unit that can Multiply, Divide, Mod, AND, OR, NOT, XOR, XNOR, NAND, NOR, PRESET two inputs. (NOW WITH CLOCK)
//It will display the output in binary and decimal.
//The operations can be made using opcode which runs through a multiplexor to change the operation. 

//For this final part, we will use the Arithmetic Logic Unit to display Fibonacci numbers, will calculate the area and volume of three shapes,
//and will calculate the roots of a polynomial using Newton's Method of approximation.

//It will also communicate and send value to C code to calculate parts of the operations above to simplify operations.

//=============================================
// Half Adder
//=============================================
module HalfAdder(A,B,carry,sum);
	input A;
	input B;
	output carry;
	output sum;
	reg carry;
	reg sum;
//---------------------------------------------	
	always @(*) 
	  begin
	    sum= A ^ B;
	    carry= A & B;
	  end
//---------------------------------------------
endmodule



//=============================================
// Full Adder
//=============================================
module FullAdder(A,B,C,carry,sum);
	input A;
	input B;
	input C;
	output carry;
	output sum;
	reg carry;
	reg sum;
//---------------------------------------------	
	wire c0;
	wire s0;
	wire c1;
	wire s1;
//---------------------------------------------
//	HalfAdder ha1(A ,B,c0,s0);
//	HalfAdder ha2(s0,C,c1,s1);
//---------------------------------------------
	always @(*) 
	  begin
	    sum=s1;//
		sum= A^B^C;
	    carry=c1|c0;//
		carry= ((A^B)&C)|(A&B);  
	  end
//---------------------------------------------
	
endmodule

module AddSub(inputA,inputB,mode,sum,carry,overflow);
	function [1:0] full_adder(input a, b, c);
		begin
			full_adder[0]= (a^b)^c; //| 
			full_adder[1]=(((a & b) | (b & c) | (a & c)));
		end
	endfunction
    input [15:0] inputA;
	input [15:0] inputB;
    input mode;
    output [31:0] sum;
	output carry;
    output overflow;
	reg c0,c1,c2,c3,c4; //Carry Interfaces
	reg [1:0]car; //for using a 2 bit result function
	reg [15:0] count;
	reg [31:0] result;
always @(*) begin
	result=0;
	//#6
	for (count=0; count<16; count=count+1) begin
		c4=c1;
		if (count==0) begin
			car=full_adder(inputA[count], inputB[count]^mode, mode);
			c1=car[1];
			result[count]=car[0];
		end else begin
			car=full_adder(inputA[count], inputB[count]^mode, c4);
			c1=car[1];
			result[count]=car[0];
			
		end
	end
	//$display("Add line 91, A: %d, B: %d, sum %d", inputA, inputB, result);
	//now just replicate the bit at index 15 to cover all the rest of the bits of output
 end //end of always block
	assign sum=result;
	assign carry=c4;
	assign overflow=c4^mode;
endmodule

module multiply(inputA, inputB, res);
	input [15:0]inputA;
	input [15:0]inputB;
	output [31:0]res;
	
	reg [31:0]partial;
	reg [31:0]count;
	reg [15:0]count2;
	reg [31:0]count3;
	reg [31:0]mult;
	reg [31:0]addition;
	reg [1:0]car;
	function automatic [1:0] full_adder(input a, input b, input c);
		begin
			full_adder[0]= (a^b)^c; //| 
			full_adder[1]=(((a & b) | (b & c) | (a & c)));
		end
	endfunction
	//the following will need to be bitshifted left by i after it is calculated
	function automatic [31:0] partial_sum(input [15:0]a, input [15:0]i, input [15:0]b); 
		begin
			for(count=0; count<32; count=count+1) begin
				if (count<i) begin
					partial_sum[count]=0;
				end else if (count<i+16) begin
					partial_sum[count]=a[i] && b[count-i]; //thus multiplying one bit of a by each bit of b
				end else begin
					partial_sum[count]=a[15] ^ b[15]; //two positive numbers make a positive, two negative numbers a positive, one pos one neg makes neg
				end
			end
		end
	endfunction
	always @(*) begin
			mult=0;
			for (count2=0; count2<16; count2=count2+1) begin
				//mult=addition(mult, partial_sum(a, count2, b)); 
				partial=partial_sum(inputA, count2, inputB);
				car=0;
				for (count3=0; count3<32; count3=count3+1) begin
					car=full_adder(car[1], mult[count3], partial[count3]);
					//#6;
					addition[count3]=car[0];
				end
				//#6;
				mult=addition;
			end
		//$display("mult line 145, A: %d, B: %d, sum %d", inputA, inputB, mult);
	end //end always block
	assign res=mult;
endmodule

module divide(inputA, inputB, resDiv, divZero);
	input [15:0] inputA;
	input [15:0]inputB;
	output [31:0]resDiv;
	output divZero;
	reg [31:0] res;
	reg dZ;
	always @(*) begin
		if (inputB==0) begin
			dZ=1;
			res=-1;
		end else begin
			res=inputA/inputB;
			dZ=0;
		end
		//$display("div line 165, A: %d, B: %d, sum %d", inputA, inputB, res);
	end
	assign divZero=dZ;
	assign resDiv=res;
endmodule

module modulo(inputA, inputB, resMod, divZero);
	input [15:0] inputA;
	input [15:0] inputB;
	output [31:0] resMod;
	output divZero;
	reg [31:0] res;
	reg dZ;
	always @(*) begin
		if (inputB==0) begin
			 dZ=1;
			res=-1;
		end else begin
			res=inputA%inputB;
			dZ=0;
		end
		//$display("mod line 186, A: %d, B: %d, sum %d", inputA, inputB, res);
	end
	assign divZero=dZ;
	assign resMod=res;
endmodule



module Dec4x16(binary,onehot);
	input [31:0] binary;
	output [31:0]onehot;
	
	assign onehot[ 0]=~binary[3]&~binary[2]&~binary[1]&~binary[0];
	assign onehot[ 1]=~binary[3]&~binary[2]&~binary[1]& binary[0];
	assign onehot[ 2]=~binary[3]&~binary[2]& binary[1]&~binary[0];
	assign onehot[ 3]=~binary[3]&~binary[2]& binary[1]& binary[0];
	assign onehot[ 4]=~binary[3]& binary[2]&~binary[1]&~binary[0];
	assign onehot[ 5]=~binary[3]& binary[2]&~binary[1]& binary[0];
	assign onehot[ 6]=~binary[3]& binary[2]& binary[1]&~binary[0];
	assign onehot[ 7]=~binary[3]& binary[2]& binary[1]& binary[0];
	assign onehot[ 8]= binary[3]&~binary[2]&~binary[1]&~binary[0];
	assign onehot[ 9]= binary[3]&~binary[2]&~binary[1]& binary[0];
	assign onehot[10]= binary[3]&~binary[2]& binary[1]&~binary[0];
	assign onehot[11]= binary[3]&~binary[2]& binary[1]& binary[0];
	assign onehot[12]= binary[3]& binary[2]&~binary[1]&~binary[0];
	assign onehot[13]= binary[3]& binary[2]&~binary[1]& binary[0];
	assign onehot[14]= binary[3]& binary[2]& binary[1]&~binary[0];
	assign onehot[15]= binary[3]& binary[2]& binary[1]& binary[0];
	
endmodule

 
//MUX Multiplexer 16 by 4
module Mux16x4a(channels,select,b);
input [15:0][31:0]channels;
input       [3:0] select;
output      [31:0] b;
wire  [15:0][31:0] channels;
reg         [31:0] b;

always @(*)
begin
 b=channels[select]; //This is disgusting....
end

endmodule
 

module Mux16x4b(channels, select, b);
input [15:0][31:0] channels;
input      [31:0] select;
output      [31:0] b;
//wire  [15:0][31:0] channels;
//wire        [31:0] b;


	assign b = ({32{select[15]}} & channels[15]) | 
               ({32{select[14]}} & channels[14]) |
			   ({32{select[13]}} & channels[13]) |
			   ({32{select[12]}} & channels[12]) |
			   ({32{select[11]}} & channels[11]) |
			   ({32{select[10]}} & channels[10]) |
			   ({32{select[ 9]}} & channels[ 9]) |
			   ({32{select[ 8]}} & channels[ 8]) |
			   ({32{select[ 7]}} & channels[ 7]) |
			   ({32{select[ 6]}} & channels[ 6]) |
			   ({32{select[ 5]}} & channels[ 5]) |
			   ({32{select[ 4]}} & channels[ 4]) |
			   ({32{select[ 3]}} & channels[ 3]) |
			   ({32{select[ 2]}} & channels[ 2]) | 
               ({32{select[ 1]}} & channels[ 1]) |
               ({32{select[ 0]}} & channels[ 0]) ;

endmodule

module Logic(inputA, inputB, op_code, resLog);
input [15:0]inputA;
input [15:0]inputB;
input [3:0]op_code;
output [31:0]resLog;
wire [15:0]inputA;
wire [15:0]inputB;
wire [3:0]op_code;
wire [31:0]resLog;
reg [15:0]res;

always @(*) begin
	if (op_code==5) begin //AND
		res=inputA & inputB;
	end else if (op_code==6) begin //OR
		res=inputA | inputB;
	end else if (op_code==7) begin //NAND
		res=~(inputA & inputB);
	end else if (op_code==9) begin //NOR
		res=~(inputA | inputB);
	end else if (op_code==10) begin //XOR
		res=inputA ^ inputB;
	end else if (op_code==11) begin //XNOR
		res=(inputA & inputB) | ~(inputA | inputB); //is true when both are false or when both are true 
	end else begin //NOT (would be on 12, or on any other call.)
		res=~inputA;
	end


end //end always

assign resLog=res;

endmodule


//=============================================
// DFF
//=============================================
module DFF(clk,in,out, choice, compare);
 parameter n=32;//width
 input clk;
	input choice;
	input compare;
//  initial 
//  	forever begin
//     		#26 
//		clk = ~clk;
//  	end

 input [n-1:0] in;
 output [n-1:0] out;
 reg [n-1:0] out;
	//output [3:0]op_code;
	//reg [3:0]op_code;
	//reg [n-1:0]maintain;
	always @(posedge clk) begin
		#3;
		if (choice==compare) begin
			out<=in;
		end
		//setting op_code to NO-OP after changes results in unresolved wires, so I will just have to change the clock in order to make sure everything runs properly
		//op_code<=4'b1101; //set to No-op in order to avoid repeat changes.
		//out=maintain;
		//$display("DFF run, input %d or %b", in, in);
	end //end always
 //assign out = maintain;
endmodule

module BreadBoard(inputA,inputB,opcode,R,error,registe, regist);
input [31:0] registe;
input [31:0] regist;
reg [31:0] register;
//reg [31:0] register; 
input [15:0]inputA;
input [15:0]inputB;
input [4:0] opcode;
wire [3:0] op_code;
assign op_code[3]=opcode[4];
assign op_code[2:0]=opcode[2:0];
output [31:0]R;
output error;
wire [15:0]inputA;
wire [15:0]inputB;
reg [31:0]R;
reg error;
reg [6:0] display;


//Local Variables
//Full Adder
reg mode;
wire [31:0] sum;
wire [31:0] resMod;
wire [31:0] resDiv;
wire [31:0] resLog; //AND, OR, NAND, NOR, XOR, XNOR, NOT
wire divZero;
wire divZero2; //a dummy variable since only one of these two needs to discover that inputB is 0
wire [31:0] res; //multiplication
wire carry;
wire overflow;

//Multiplexer
wire [15:0][31:0] channels ;
wire [31:0] onehotMux;
wire [31:0] b;

//Seven Segment Display
wire [31:0] D;
wire [31:0] replace_op_code; //need 32 bits to maintain consistency with other changes
assign replace_op_code=op_code;
 

Dec4x16 DecBeta(b,D);
Dec4x16 DecAlpha(replace_op_code,onehotMux);
AddSub nept(inputA,inputB,mode,sum,carry,overflow);
multiply Mult3(inputA, inputB, res);
divide div3(inputA, inputB, resDiv, divZero);
modulo mod3(inputA, inputB, resMod, divZero2);
Logic log(inputA, inputB, op_code, resLog);
//Mux16x4a uran(channels,op_code,b);
Mux16x4b satu(channels,onehotMux,b);



assign channels[ 0]=sum;//Addition
assign channels[ 1]=resMod;//Modulo
assign channels[ 2]=resDiv;//Divide
assign channels[ 3]=32'b000000000000000000000000000000;//GROUND=0 //reset 0
assign channels[ 4]=res;//Multiplication
assign channels[ 5]=resLog;//AND
assign channels[ 6]=resLog;//OR
assign channels[ 7]=resLog;//NAND
assign channels[ 8]=sum;//Subtraction
assign channels[ 9]=resLog;//NOR
assign channels[10]=resLog;//XOR
assign channels[11]=resLog;//XNOR
assign channels[12]=resLog;//NOT
assign channels[13]=register;//GROUND=0 //will eventually be the No-op command once the register is used
assign channels[14]=0;//GROUND=0
assign channels[15]=32'b11111111111111111111111111111111; //preset 111111111111111111111111111111


always @(*)  
begin
//input [31:0] registe; //original register
//input [31:0] regist; //other register to choose
if (opcode[3]==0) begin
	register=registe;
end
if (opcode[3]==1) begin
	register=regist;
end
//-------------------------------------------------------------
 mode=op_code[3];
//$display("line 334 sum: %b, b: %b", sum, b);
	R=b;
 error=overflow;
//------------------------------------------------------------- 
//-------------------------------------------------------------	   
end

endmodule



module TestBench();
  reg clk=0;
  reg [15:0] inputA;
  wire [15:0] inputB;
  reg [31:0] inputF0;
  reg [31:0] inputF1;
  reg [31:0] fibIncrement;
        reg [31:0] est;
        reg [31:0] num_args;
        reg [31:0] a0; //used for the constant in the polynomial in newton's method
        reg [31:0] a1; 
        reg [31:0] a2;
        reg [31:0] a3;
        reg [31:0] rootRet;
  reg [4:0] op_code; //bit 4 does what bit 3 did previously when op_code was 4 bits long. Bit 3 now represents the choice of whether to use the normal register or a different register

	wire [31:0] result;
	wire [31:0]R;
	wire error;
	wire [1:0] E; //the output error
	wire divZero;
	wire desired;
	assign desired=0;

	//-----------------------------------------
	//geometric operations registers
	reg [15:0] tempresult1;
	reg [15:0] tempresult2;
	reg [15:0] tempresult3;
	reg [15:0] up_tempresult;
	reg [15:0] dn_tempresult;
	reg [15:0] up_tempresult2;
	reg [15:0] dn_tempresult2;
	reg [15:0] pi = 31416; //we will divide results by 10000 to get precise answer with decimal
	reg [15:0] divpi; //31416/10000
	reg [15:0] modpi; //31416mod10000
	reg [15:0] squaredradius;
	reg [15:0] side = 9; //side/edge of cibe
	reg [15:0] height = 8;
	reg [15:0] radius = 6;
	reg [15:0] slope; //result of pythagoran theorem (will be 10 in this case)
	reg [15:0] geoa; //a^2
	reg [15:0] geob; //b^2
	reg [15:0] SAfront; //integer surface area
	reg [15:0] SAback; //decimal surface area
	//---------------------------------------------
  
  reg [31:0] register;
	reg [31:0] register2;
	assign inputB=register[15:0];
	DFF DFF1(clk,R,register, op_code[3], desired);
	DFF DFF2(clk,R,register2, op_code[3], ~desired);
  BreadBoard BB8(inputA,inputB,op_code,R,error,register, register2);
  reg k1,k2,k3,k4,k5;
  reg [10:0]segA;
  reg [7:0] charA;
  reg [6*8-1:0] operation;
  //CLOCK Thread
  initial
	begin
		clk=0;
		//R=0;
		#1;
		clk=1;
		#1;
		clk=0;
		charA=0;
			forever
				begin
					#20;
					clk=1;
					#30;
					clk=0;
					//if (charA<120 && charA%7==3) begin
					//	
					//	$display("clock run %d times", charA);
					//end
					//charA=charA+1;
					
				end
	end
	assign E[1]=((!(inputB || inputB)) && (op_code==1 || op_code==2))		; //divideZero

	assign E[0]= (op_code==0 || op_code==5'b01000 || op_code==5'b10000 || op_code==5'b11000); //determine whether addoverflow could occur.
	initial begin
		assign inputA  = 65535;
		//assign inputB  = 4'b1001;
	
		//(!(op_code || op_code) || op_code[3]) && error; //addOverflow
	
		$display("inputA\tinputA (bin)\t\tinputB\tinputB (bin)\t\tOperation\top_code\t\tOutput\tOutput (bin)\t\t\t\tError");

		//Each line of the table is done by replicating the effect of this, though this will be edited to use the feedback from the clock on each operation to
		//the register in a feedback loop
		assign op_code = 5'b00011;
		operation="RESET ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b10101;
		operation="NO-OP ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00000;
		operation="ADD   ";
		while (clk==0) begin
			#3;
		end
	
		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign inputA=8191;
		operation="ADD   ";
		while (clk==0) begin
			#3;
		end
	
		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		assign op_code=5'b00011; //reset
		while (clk==0) begin
			#3;
		end
		operation="RESET ";
		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00000;
		operation="ADD   ";
		assign inputA=9999;
		while (clk==0) begin
			#3;
		end
	
		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		
				

		assign inputA=1003;
		assign op_code = 5'b10000;
		operation="SUB   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00100;
		operation="MUL   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00010;
		operation="DIV   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00001;
		operation="MOD   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00101;
		operation="AND   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00110;
		operation="OR    ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b10100;
		operation="NOT   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b10010;
		operation="XOR   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b10011;
		operation="XNOR  ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b00111;
		operation="NAND  ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b10001;
		operation="NOR   ";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		assign op_code = 5'b10111;
		operation="PRESET";
		while (clk==0) begin
			#3;
		end

		$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
		while (clk==1) begin
			#3;
		end

		$display(" ");


//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Now we are going to do a simple math operation, then a medium difficulty problem, then a hard difficulty problem
	$display("---------------------------| First Math Operation: FIBONNACI SERIES |---------------------------");

		assign op_code = 5'b00011; //reset
		assign inputA=0;
		while (clk==0) begin
			#3;
		end

		while (clk==1) begin
			#3;
		end
		//value of inputB is now 0
		//To do the Fibonnaci series, I will need an extra register (this is represented by a choice within the register made by bit [1] of the 5 bit op_code), and inputB and that other
		
		//register will be swapping with each other to recieve the next value.
		//this means that the system design diagram needs to change
		assign op_code = 5'b00000;
		$display("%d",register);
		
		inputF0=0;
		assign inputA=1;
		while (clk==0) begin
			#3;
		end
		
		while (clk==1) begin
			#3;
		end
		$display("%d",register);
		inputF1=1;
		$display("%d",inputF1);
		fibIncrement=0;
		//Loop start
		while(fibIncrement<=8) begin
			assign inputA=inputF1;
			inputF0=register;
			
			while (clk==0) begin
				#3;
			end
			while (clk==1) begin
				#3;
			end
			$display("%d",register);
			assign inputA=inputF0;
			inputF1=register;
			while (clk==0) begin
				#3;
			end
			while (clk==1) begin
				#3;
			end
			$display("%d",register);
			fibIncrement<=fibIncrement+1;	
		end
		//Loop end
		//assign inputC;
		//assign fibVal=0;
		//while (fibVal<=10) begin
		//	inputC=inputF0+inputF1;
		//	inputF0=inputF1;
		//	inputF1=inputC;
		//	fibVal=fibVal+1;
		//end
		//output(inputC)//Fibonnaci value

	$display(" ");

		//SECOND OPERATION IMPLEMENTATION
	//--------------------------------------------------------------------------------------------------------//
	

	//Pythagorean theorem
	//a^2 + b^2 = c^2
	//h^2 + r^2 = slope

	$display("------------------------------| Second Math Operation: GEOMETRIC EQUATIONS |-------------------------------");

	$display(" ");
	$display(" ");

	$display("--------------------------------| CONE WITH HEIGHT = %2D AND RADIUS = %2D |----------------------------------",height,radius);

	//--------------Pi operations for mod and div 10000 (will help us avoid repeating code later on)---------------

	//divpi
	assign op_code = 5'b00011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10000;

	assign op_code = 5'b00000; //add (add 0+ 10000) = 10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = pi;
	assign op_code = 5'b00010; //divide 31416/10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end
	divpi <= register;
	//$display("divpi: %d", register); //3


	//modpi
	assign op_code = 5'b00011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10000;

	assign op_code = 5'b00000; //add (add 0+ 10000) = 10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = pi;
	assign op_code = 5'b00001; //mod (31416 % 10000)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end
	modpi <= register;
	//$display("modpi: %d", register); //1416

	//--------------------------------------Pi operations for mod and div 10000 DONE------------------------------------

	//$display("SURFACE AREA OF A CONE: SA=πrs+πr^2");

	//Next before we begin with the formula we must use pythagorean theorem to get "s" which is the slope (also called "c")

	//----------------------------------Pythagorean theorem to find the slope-------------------------

	//a^2+b^2 = sqrt(slope)

	//part a^2
	assign op_code = 5'b00011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = height; //height = 8
	assign op_code = 5'b00000; //add (add 0+ 8) = 8
	
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = height; //height = 8
	
	assign op_code = 5'b00100; //multiply (8 * 8) = 64

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	geoa <= register; //slower assign statement

	//$display("a^2: %d",register);//64

	//part b^2
	assign inputA = 0;
	assign op_code = 5'b00011;//reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //radius = 6

	assign op_code = 5'b00000; //add ( 0 + 6) = 6

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //radius = 6

	assign op_code = 5'b00100; //multiply ( 6 * 6) = 36

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("b^2: %d",register); //36

	assign inputA = geoa; //64
	assign op_code = 5'b00000; //add (add 64 + 36)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	slope <= register; //at this point we have a^2 + b^2

	//$display("a^2 + b^2: %d",register); //100

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//pythagorean theorem result is:
	est=$my_sqrt(slope);
	slope <= est/10000; //$sqrt(result of a^2 + b^2), due to this being a perfect square, we can discard the fractional part contained in est.
	//slope <= 10;
	//at this point slope is the square root of the result of those two numbers

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("squared slope: %d",slope); //10

	//-----------------------------------------End of Pythagorean theorem ----------------------------------


	//SURFACE AREA OF CONE: SA=πrs+πr^2

	//Now, first we will do the first part of the formula: πrs

	//--------------------------------------First part of surface area of cone πrs------------------------
	

	//divpi * radius (upper part)

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = divpi;

	assign op_code = 5'b00000; //add (add 0+ 3) = 3

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //6

	assign op_code = 5'b00100; //multiply (multiply 3 * 6) = 18

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	up_tempresult <= register; //πr (upper part)

	//$display("up_tempresult: %d",register); //18

	//modpi * radius (lower part)

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = modpi;

	assign op_code = 5'b00000; //add (add 0 + 1416) = 1416

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //6

	assign op_code = 5'b00100; //multiply (multiply 1416 * 6) = 8496

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	dn_tempresult <= register; //πr (lower part)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("dn_tempresult: %d",dn_tempresult);//πr (lower part) 8496

	//(up_tempresult (currently upper πr) * already squarerooted slope (s))

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = slope;//10
	assign op_code = 5'b00000; //add (add 0 + slope) = 

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = up_tempresult;//18
	assign op_code = 5'b00100; //multiply (up_tempresult * slope) = should be 180

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	up_tempresult <= register; //(up_tempresult * slope) = should be 180

	//$display("updated up_tempresult: %d", register); //180

	//(dn_tempresult (currently lower πr) * squarerooted slope) 
	//NOTE: since it will be divided by 10000 to find the carry but also multiplied by 10 due to the slope we can do divide by 1000 instead

	//division by 1000 to split the dn_tempresult to carry the integer

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 1000;

	assign op_code = 5'b00000; //add (add 0+ 1000) = 1000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = dn_tempresult; //8496

	assign op_code = 5'b00010; //divide 8496/10000
	
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	tempresult1 <= register; //8

	//$display("first tempresult1: %d", register); //8

	//we add tempresult1 (which is 8) and up_tempresult

	assign op_code = 5'b00011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = tempresult1; //8

	assign op_code = 5'b00000; //add (add 0+ 8) = 8

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = up_tempresult;
	assign op_code = 5'b00000; //add (add 8 + 180) = 188

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	up_tempresult <= register; //now up_tempresult is 188

	//$display("final up_tempresult: %d", register); //188

	//next we must update the dn_tempresult

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 1000;

	assign op_code = 5'b00000; //add (add 0+ 1000) = 1000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = dn_tempresult;

	assign op_code = 5'b00001; // mod 8496%1000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	dn_tempresult <= register;
	//$display("final dn_tempresult: %d", register); //496

	//----------End of first part of surface area of cone:  πr (we have it as up_tempresult and dn_tempresult)-------------

	//-----------------------------------Second part of surface area of cone: πr -------------------------------

	//πr^2 (this the second part of the equation)
	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //radius = 6

	assign op_code = 5'b00000; //add (add 0+ 6) = 6

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //radius = 6

	assign op_code = 5'b00100; //multiply (multiply 6 * 6) = 36

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	squaredradius <= register;
	//$display("squareradius: %d",register); //36

	//divpi * squaredradius (upper part)

	assign op_code = 5'b00011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = divpi;

	assign op_code = 5'b00000; //add (add 0+ 3) = 3

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = squaredradius; 

	assign op_code = 5'b00100; //multiply (multiply 3 * 36) = 108

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	up_tempresult2 <= register; //πr^2 (upper part) //108

	//$display("up_tempresult2: %d",register); //108

	//modpi * squaredradius (lower part)

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = modpi;

	assign op_code = 5'b00000; //add (add 0 + 1416) = 1416

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = squaredradius; 

	assign op_code = 5'b00100; //multiply (multiply 1416 * 36) = 50,976

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	dn_tempresult2 <= register; //πr^2 (lower part)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("dn_tempresult2: %d",dn_tempresult2);//πr^2 (lower part) 50,976

	//now, we have to split the dn_tempresult into its integer 

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10000;

	assign op_code = 5'b00000; //add (add 0+ 10000) = 10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = dn_tempresult2;

	assign op_code = 5'b00010; //divide 50976/10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	tempresult2 <= register; //5

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("tempresult2: %d", tempresult2); //5

	//we add tempresult2 (which is 5) and up_tempresult2 (108)

	assign op_code = 5'b00011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = tempresult2;

	assign op_code = 5'b00000; //add (add 0+ 5) = 5

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = up_tempresult2;
	assign op_code = 5'b00000; //add (add 5 + 108) = 113

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	up_tempresult2 <= register; //now up_tempresult is 113

	//$display("final up_tempresult2: %d", register); //113

	//next we have dn_tempresult2

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10000;

	assign op_code = 5'b00000; //add (add 0+ 10000) = 10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = dn_tempresult2;

	assign op_code = 5'b00001; // mod 50976%10000

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	dn_tempresult2 <= register;

	//$display("final dn_tempresult2: %d", register); //0976

	//now we put both formulas together

	//front
	assign op_code = 5'b00011;//reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = up_tempresult;
	assign op_code = 5'b00000; //add (add 0 + 188)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = up_tempresult2; //(up_tempresult + up_tempresult2) also known as (188 + 113)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	SAfront <= register;

	//SA decimal
	assign op_code = 5'b00011;//reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = dn_tempresult;
	assign op_code = 5'b00000; //add (add 0 + 496)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10;

	assign op_code = 5'b00100; //mult 496 *10 since 976 must have a zero in front when they are added 

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = dn_tempresult2; //(dn_tempresult + dn_tempresult2) also known as (4960 + 976) = 
	assign op_code = 5'b00000; //add (add 4960 + 976)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	SAback <= register;

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("Surface Area : %4D.%1D",SAfront, SAback);

	//Volume
	//-----------------------------------------Volume of cone: v=1/3 (πr^2h)----------------------------------

	//we will use 1/3 * 10000 = 3333 and divide by 10000 at the end

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = height; //8
	assign op_code = 5'b00000; //add (add 0+ 8) = 8

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = squaredradius; //36

	assign op_code = 5'b00100; //multiply (8*36) (h * r^2)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = pi;

	assign op_code = 5'b00100; //multiply (8*36*31416) which is (h * r^2*pi)

	//$display("h*r^2",register); 

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("h * r^2*pi",register,); //9047808

	$display("Volume : %d.%1D",register/10000*1/3, ((((register%1000000)*33333)/100000)-10000));
	$display("Note: Surface area and volume are very close since the height, radius, and slope form a right triangle in the cone.");
	$display(" ");

	//Surface Area
	//--------------------------------------------------Surface Area of Sphere: 4πr^2---------------------------------------
	
	$display("--------------------------------------| SPHERE WITH RADIUS = %3D |-----------------------------------------",radius);

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 4; //constant
	assign op_code = 5'b00000; //add (add 0+ 4) = 4

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = squaredradius; //36

	assign op_code = 5'b00100; //multiply (4*36) (4 * r^2)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = pi;

	assign op_code = 5'b00100; //multiply (4*36*31416) which is (4 * r^2*pi)

	//$display("4*r^2",register); 

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("4 * r^2*pi",register,); //9047808


	$display("Surface area : %4D.%1D",register/10000, register%10000);

	//Volume
	//---------------------------------------Volume of Sphere: v=4/3 (πr^3)-----------------------------------------

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //6
	assign op_code = 5'b00000; //add (add 0+ 6) = 6

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //6
	assign op_code = 5'b00100; //multiply (6*6) =36

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = radius; //6
	assign op_code = 5'b00100; //multiply (36 *6) = 216

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("r^3 ",register); 

	assign inputA = pi;

	assign op_code = 5'b00100; //multiply (31416*216) (31416 * r^3)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	//$display("31416 * r^3 ",register); 
	$display("Volume : %d.%1D",register/10000*4/3, ((register%10000)*13333333)/100000);
	$display(" ");

	//Surface Area
	//---------------------------------Surface Area of a Cube: 6(side/edge^2)-----------------------------------

	$display("----------------------------------------| CUBE WITH EDGE = %3D |-------------------------------------------",side);

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = side; //constant from formula of cube
	assign op_code = 5'b00000; //add (add 0+ 9) = 9

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = side; //9
	assign op_code = 5'b00100; //multiply (9*9) =81

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 6; //constant from forumula of cube
	assign op_code = 5'b00100; //multiply (81 * 6) = 486

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("Surface area : %4D",register);//486

	//Volume
	//------------------------------------Volume of a Cube: (edge/side^3)-----------------------------

	assign op_code = 5'b00011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = side; //9
	assign op_code = 5'b00000; //add (add 0+ 9) = 9

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = side; //9
	assign op_code = 5'b00100; //multiply (9*9) = 81

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = side; //9
	assign op_code = 5'b00100; //multiply (81 * 9) = 729

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("Volume : %d",register);//729

	$display(" ");

	//--------------------------------------------------------------------------------------------------------//

                //Now using the Verilog PLI to solve for a root of a polynomial
                //The PLI takes in 32 bit numbers, and has a process for dealing with negative numbers.
                //The result is sent back multiplied by 10,000 in order to allow 
                //verilog to have 4 digits after the decimal.
                //when this result is negative, we can assign inputA first to the lower order bits,
                //use the NOT operation
                //then assign inputA to 1 and use the ADD operation
                //the result is then stored in a 32-bit variable
                //assign inputA to the higher-order 16 bits of the number that was returned by PLI
                //use the NOT operation
                //then assign inputA to bit [16] of the previous stored variable
                //use the add operation.
                //store the result in the higher order bits of the previous 32-bit variable
                //display the 32-bit variable with $display("%d.%d", result/10000, result%10000);
                est=5;
                num_args=4;
                a0=1;
                a1=-4;
                a2=6;
                a3=7;
                //solving for 0=1-4*x+6*x^2+7*x^3
                rootRet=$newton(est, num_args, a0, a1, a2, a3);
                //I know that the result of this operation is negative, so I am not testing for that
                //$display("line inputA[15:0]=root, before is %d", inputA);

                assign inputA=rootRet[15:0];
                //$display("line inputA[15:0]=root, after is %d", inputA);
                assign op_code = 5'b10100; //NOT
                        while (clk==0) begin
                                #3;
                        end
                        while (clk==1) begin
                                #3;
                        end
                assign inputA=1;
                assign op_code=5'b00000; //ADD
                        while (clk==0) begin
                                #3;
                        end
                        while (clk==1) begin
                                #3;
                        end
                //$display("line est[16:0]=register, before is %d", est);

                est[16:0]=register;
                //$display("line est[16:0]=register, after is %d", est);

                assign inputA=rootRet[31:16];
                //$display("line inputA[15:0]=root, after is %d", inputA);
                assign op_code =5'b10100; //NOT
                        while (clk==0) begin
                                #3;
                        end
                        while (clk==1) begin
                                #3;
                        end
                //$display("line inputA=est[16], before is %d", inputA);
                assign inputA={15'b000000000000000, est[16]};
                //$display("line inputA=est[16], after is %d", inputA);
                assign op_code=5'b00000; //ADD, if the 1 needs to be percolated up
                        while (clk==0) begin
                                #3;
                        end
                        while (clk==1) begin
                                #3;
                        end
                est[31:16]=register;
                $display("The root of 0=%d + -%dx + %dx^2 + %dx^3 is -%d.%d", a0, -a1, a2, a3, est/10000, est%10000);

		#60; 

		$finish;
	end //end initial begin  
 

 
endmodule
