/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 11/11/2021
	Aluno: Fernando Veizaga
	Matricula: 20203001902
*/

module ramhier(control);
	input control;
	
	reg writeL1;
	reg [10:0] datainL1;
	reg [2:0] addinL1;
	reg clk;
	
	wire [10:0] dataoutL1, dataoutL2, inL1, inL2, wbdataL2tomem;
	wire [13:0]	wbdataL1toL2, dadoaltL1, dadoaltL2;
	wire [2:0] addoutL1, addoutL2, out, L1VLRUD, L2VLRUD, dadoL1, dadoL2;
	wire [7:0] tagL1, tagL2;
	wire missL1, missL2, wbackL1toL2, wbackL2tomem, missenL2;
	
	always begin
		clk = 0;
		#1 clk = 1;
		#1 clk = 0;
	end
	
	initial begin
		//caso 1
		writeL1 = 1'b0;
		datainL1 = 11'b01100100000;
		addinL1 = 3'b000;
		
		//caso 2
		#14 writeL1 = 1'b0;
		datainL1 = 11'b01101100000;
		addinL1 = 3'b001;
		
		//caso 3
		#14 writeL1 = 1'b0;
		datainL1 = 11'b10000010000;
		addinL1 = 3'b110;
		
		//caso 4
		#14 writeL1 = 1'b1;
		datainL1 = 11'b01110110101;
		addinL1 = 3'b001;
		
		//caso 5
		#14 writeL1 = 1'b1;
		datainL1 = 11'b10000000101;
		addinL1 = 3'b001;
		
		//caso 6
		#14 writeL1 = 1'b1;
		datainL1 = 11'b10001010010;
		addinL1 = 3'b111;
		
		//caso 7
		#14 writeL1 = 1'b0;
		datainL1 = 11'b01110110000;
		addinL1 = 3'b111;
	end
	
	initial begin
 		$monitor("Time=%0d || datain=%b || addin=%b || miss=%b", $time, datainL1, addinL1, missL1);
 	end
	
	cachel1 mod1(writeL1, datainL1, dataoutL1, addinL1, addoutL1, clk, inL1, out, missL2, missL1, wbackL1toL2, wbdataL1toL2, dadoaltL1, L1VLRUD, tagL1, dadoL1);		//modulo da cache L1
	
	cachel2 mod2(dataoutL1, dataoutL2, addoutL1, addoutL2, clk, inL2, inL1, missL1, missL2, missenL2, wbackL1toL2, wbackL2tomem, wbdataL1toL2, wbdataL2tomem, dadoaltL2, L2VLRUD, tagL2, dadoL2);	//modulo da cache L2
	
	memram mod3(addoutL2, clk, dataoutL2, wbackL2tomem, inL2);		//modulo da memoria principal
	
endmodule
