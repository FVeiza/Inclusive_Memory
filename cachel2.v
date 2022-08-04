/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 11/11/2021
	Aluno: Fernando Veizaga
	Matricula: 20203001902
*/

module cachel2(datain, dataout, addin, addout, clock, in, out, missin, missout, missen, wbackin, wbackout, wbackdatain, wbackdataout, dadoalterado, VLRUD, tag, dado);
	input clock, missin, wbackin;
	input [10:0] datain, in;
	input [13:0] wbackdatain;
	input [2:0] addin;
	output reg [2:0] addout, VLRUD, dado;
	output reg [7:0] tag;
	output reg [10:0] dataout, out, wbackdataout;
	output reg [13:0] dadoalterado;
	output reg missout, wbackout, missen;
	
	reg [13:0] via[0:3][0:1];
	
	initial begin							  //inicializacao da cache e de alguns sinais 
		via[0][0] = 14'b10001100100111; //1 0 0 01100100 111
		via[0][1] = 14'b11001111000100; //1 1 0 01111000 100
		via[1][0] = 14'b10001101100011; //1 0 0 01101100 011
		via[1][1] = 14'b11010000000011; //1 1 0 10000000 011
		via[2][0] = 14'b00000000000000; //0 0 0 00000000 000
		via[2][1] = 14'b00000000000000; //0 0 0 00000000 000
		via[3][0] = 14'b11001110110011; //1 1 0 01110110 011
		via[3][1] = 14'b00000000000000; //0 0 0 00000000 000
		
		missout = 1'b0;
		missen = 1'b0;
		out = 11'b00000000000;
		wbackout = 1'b0;
		addout = 3'b000;
		dataout = 11'b00000000000;
		wbackdataout = 11'b00000000000;
	end
	
	always@(posedge clock)
	begin
		addout = addin;
		dataout = datain;
		wbackout = 1'b0;
		dadoalterado = 14'b00000000000000;
		VLRUD = 3'b000;
		tag = 8'b00000000;
		dado = 3'b000;
		
		if(wbackin == 1'b1)						//verificacao da necessidade de write-back
		begin
			wbackout = 1'b1;
			wbackdataout[10:0] = wbackdatain[10:0];
			if(wbackdatain[10:3] == via[wbackdatain[12:11]][0][10:3])
			begin
				dadoalterado = via[wbackdatain[12:11]][0][13:0];
				via[wbackdatain[12:11]][0][2:0] = wbackdatain[2:0];
			end
		
			else if(wbackdatain[10:3] == via[wbackdatain[12:11]][1][10:3])
			begin
				dadoalterado = via[wbackdatain[12:11]][1][13:0];
				via[wbackdatain[12:11]][1][2:0] = wbackdatain[2:0];
			end
		end
	
		if(missen == 1'b1)						//em caso de miss na L2, um delay ocorre para utilizarmos o dado correto da memoria principal
		begin
			missout = 1'b1;
			missen = 1'b0;
		end
		
		else if(missout == 1'b1 && missin == 1'b1 && in != 11'b00000000000)			//verificacao de miss na cache L1 e L2
		begin
			if(via[addin[1:0]][0][12] == 1'b0)				//verificacao do bit LRU
			begin
				via[addin[1:0]][0][2:0] = in[2:0];			//atualizacao dos dados da via
				via[addin[1:0]][0][11] = 1'b0;				//atualizacao do bit dirty
				via[addin[1:0]][0][10:3] = in[10:3];		//atualizacao da tag da via
				via[addin[1:0]][0][13] = 1'b1;				//atualizacao do bit de validade
				out[10:0] = via[addin[1:0]][0][10:0];		//definicao do sinal de saida
				via[addin[1:0]][0][12] = 1'b1;				//atualizacao do LRU
				via[addin[1:0]][1][12] = 1'b0;				//atualizacao do LRU
				dadoalterado = via[addin[1:0]][0][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
			
			else if(via[addin[1:0]][1][12] == 1'b0)		//verificacao do bit LRU
			begin
				via[addin[1:0]][1][2:0] = in[2:0];			//atualizacao dos dados da via
				via[addin[1:0]][1][11] = 1'b0;				//atualizacao do bit dirty
				via[addin[1:0]][1][10:3] = in[10:3];		//atualizacao da tag da via
				via[addin[1:0]][1][13] = 1'b1;				//atualizacao do bit de validade
				out[10:0] = via[addin[1:0]][1][10:0];		//definicao do sinal de saida
				via[addin[1:0]][0][12] = 1'b0;				//atualizacao do LRU
				via[addin[1:0]][1][12] = 1'b1;				//atualizacao do LRU
				dadoalterado = via[addin[1:0]][1][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end

			missout = 1'b0;
		end
		
		else if(missin == 1'b1 && missout == 1'b0)			//verificacao de miss na cache L1
		begin
		
			//hit
			if(via[addin[1:0]][0][13] == 1'b1 && datain[10:3] == via[addin[1:0]][0][10:3])			//verificacao do bit de validade e da tag
			begin
				out[2:0] = via[addin[1:0]][0][2:0];			//definicao dos dados do sinal de saida
				out[10:3] = datain[10:3];						//definicao da tag do sinal de saida
				missen = 1'b0;										//confirmacao do hit
				via[addin[1:0]][0][12] = 1'b1;				//atualizacao do LRU
				via[addin[1:0]][1][12] = 1'b0;				//atualizacao do LRU
				dadoalterado = via[addin[1:0]][0][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
					
			else if(via[addin[1:0]][1][13] == 1'b1 && datain[10:3] == via[addin[1:0]][1][10:3])		//verificacao do bit de validade e da tag
			begin
				out[2:0] = via[addin[1:0]][1][2:0];			//definicao dos dados do sinal de saida
				out[10:3] = datain[10:3];						//definicao da tag do sinal de saida
				missen = 1'b0;										//confirmacao do hit
				via[addin[1:0]][0][12] = 1'b0;				//atualizacao do LRU
				via[addin[1:0]][1][12] = 1'b1;				//atualizacao do LRU
				dadoalterado = via[addin[1:0]][1][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
					
			else begin												//ocorrencia de miss
				if(via[addin[1:0]][0][12] == 1'b0)
				begin
					dadoalterado = via[addin[1:0]][0][13:0];
					VLRUD = dadoalterado[13:11];
					tag = dadoalterado[10:3];
					dado = dadoalterado[2:0];
				end
				else if(via[addin[1:0]][1][12] == 1'b0)
				begin
					dadoalterado = via[addin[1:0]][1][13:0];
					VLRUD = dadoalterado[13:11];
					tag = dadoalterado[10:3];
					dado = dadoalterado[2:0];
				end
				missen = 1'b1;
				out = 11'b00000000000;
			end

		end
		else begin
			out = 11'b00000000000;
		end
	end
	
endmodule
