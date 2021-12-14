//Evan Nibbe, Srivatsan Srirangam, Eddie C.
//October 10, 2021
//Part2.v
//This code is derived from the code given by Dr. Eric Becker
//
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
	HalfAdder ha1(A ,B,c0,s0);
	HalfAdder ha2(s0,C,c1,s1);
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
	#6
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

	
 end //end of always block
	assign sum=result;
	assign carry=c4;
	assign overflow=c4^c3;
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
	end
	assign divZero=dZ;
	assign resMod=res;
endmodule



module Dec4x16(binary,onehot);
	input [31:0] binary;
	output [15:0]onehot;
	
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
input      [15:0] select;
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


module BreadBoard(inputA,inputB,op_code,R,error,display);
input [15:0]inputA;
input [15:0]inputB;
input [3:0] op_code;
output [31:0]R;
output error;
output [6:0] display;
wire [15:0]inputA;
wire [15:0]inputB;
wire [3:0] op_code;
reg [31:0]R;
reg error;
reg [6:0] display;


//Local Variables
//Full Adder
reg mode;
wire [31:0] sum;
wire [31:0] resMod;
wire [31:0] resDiv;
wire divZero;
wire divZero2; //a dummy variable since only one of these two needs to discover that inputB is 0
wire [31:0] res; //multiplication
wire carry;
wire overflow;

//Multiplexer
wire [15:0][31:0] channels ;
wire [15:0] onehotMux;
wire [31:0] b;

//Seven Segment Display
wire [15:0] D;
wire [31:0] replace_op_code; //need 32 bits to maintain consistency with other changes
assign replace_op_code=op_code;
 

Dec4x16 DecBeta(b,D);
Dec4x16 DecAlpha(replace_op_code,onehotMux);
AddSub nept(inputA,inputB,mode,sum,carry,overflow);
multiply Mult3(inputA, inputB, res);
divide div3(inputA, inputB, resDiv, divZero);
modulo mod3(inputA, inputB, resMod, divZero2);
//Mux16x4a uran(channels,op_code,b);
Mux16x4b satu(channels,onehotMux,b);



assign channels[ 0]=sum;//Addition
assign channels[ 1]=resMod;//Modulo
assign channels[ 2]=resDiv;//Divide
assign channels[ 3]=0;//GROUND=0
assign channels[ 4]=res;//Multiplication
assign channels[ 5]=0;//Ground=0
assign channels[ 6]=0;//GROUND=0
assign channels[ 7]=0;//GROUND=0
assign channels[ 8]=sum;//Subtraction
assign channels[ 9]=0;//GROUND=0
assign channels[10]=0;//GROUND=0
assign channels[11]=0;//GROUND=0
assign channels[12]=0;//GROUND=0
assign channels[13]=0;//GROUND=0
assign channels[14]=0;//GROUND=0
assign channels[15]=0;//GROUND=0

always @(*)  
begin
//-------------------------------------------------------------
 mode=op_code[3];
 R=b;
 error=overflow;
//------------------------------------------------------------- 
//-------------------------------------------------------------	   
end

endmodule


module TestBench();
 
  reg [15:0] inputA;
  reg [15:0] inputB;
  reg [3:0] op_code;
  wire [31:0] result;
	wire [31:0]result2;
	wire [31:0]result3;
	wire [31:0]result4;
	wire [31:0]R;
  wire error;
	reg [1:0] E; //the output error
	wire divZero;
  wire [6:0] display;
  BreadBoard BB8(inputA,inputB,op_code,result,error,display);
   
	multiply Mult2(inputA, inputB, result2);
	divide Div2(inputA, inputB, result3, divZero);
	modulo Mod2(inputA, inputB, result4, divZero);
  reg k1,k2,k3,k4,k5;
  reg segA,segB,segC,segD,segE,segF,segG;
  reg [7:0] charA;
  
  initial begin
	//ASSIGN VALUES TO INPUTS A AND B
    assign inputA  = 4'b1001;
	assign inputB  = 4'b0110;
	assign op_code = 4'b0001;
	
	E=((!(inputB || inputB)) && (op_code[1] || op_code[0]))<<1 |  ((!(op_code || op_code) || op_code[3])); //divideZero
	//(!(op_code || op_code) || op_code[3]) && error; //addOverflow
	
	$display();

   	assign op_code=4'b0000;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Add: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));

   	assign op_code=4'b1000;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Sub: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));
   	
	assign op_code=4'b0100;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Mult:%b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));

	assign op_code=4'b0010;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Div: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));

	assign op_code=4'b0001;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Mod: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));


	//SECOND SET OF VALUES FOR INPUT A AND B
	assign inputA  = 0111110100000000;
	assign inputB  = 0000001110000100;

	assign op_code=4'b0000;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Add: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));

   	assign op_code=4'b1000;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Sub: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));
   	
	assign op_code=4'b0100;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Mult:%b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));

	assign op_code=4'b0010;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Div: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));

	assign op_code=4'b0001;
	#10;
	$display("[Input A: %2d:%b, Input B: %2d:%b, Mod: %b, Output: %2d:%b, Error: %b]",inputA,inputA,inputB,inputB,op_code,result,result, E & ~(!error));



	$display();

	#60; 
	$finish;
  end  
 

 
endmodule
