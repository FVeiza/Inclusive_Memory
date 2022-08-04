/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 11/11/2021
	Aluno: Fernando Veizaga
	Matricula: 20203001902
*/

module cachel1(writein, datain, dataout, addin, addout, clock, in, out, missin, missout, wback, wbackdata, dadoalterado, VLRUD, tag, dado);
	input clock, writein, missin;
	input [10:0] datain, in;
	input [2:0] addin;
	output reg [2:0] addout, out, VLRUD, dado;
	output reg [7:0] tag;
	output reg [10:0] dataout;
	output reg [13:0] wbackdata, dadoalterado;
	output reg missout, wback;
	
	integer control;
	
	reg [13:0] via[0:1][0:1];
	
	initial begin								//inicializacao da cache e de alguns sinais
		via[0][0] = 14'b10001100100111; 	//1 0 0 01100100 111
		via[0][1] = 14'b11001111000100; 	//1 1 0 01111000 100
		via[1][0] = 14'b11001110110011; 	//1 1 0 01110110 011
		via[1][1] = 14'b00001101100101; 	//0 0 0 01101100 101
		
		missout = 1'b0;
		wback = 1'b0;
		out = 3'b000;
		addout = 3'b000;
		dataout = 11'b00000000000;
		wbackdata = 14'b00000000000000;
	end

	always@(posedge clock)
	begin
		addout = addin;
		dataout = datain;
		wback = 1'b0;
		dadoalterado = 14'b00000000000000;
		VLRUD = 3'b000;
		tag = 8'b00000000;
		dado = 3'b000;
		
		//miss 
		if(missout == 1'b1 && missin == 1'b0 && in != 11'b00000000000)			//verificacao de hit na cache L2
		begin
		
			if(via[addin[0]][0][12] == 1'b0)					//verificacao do bit LRU
			begin
				if(via[addin[0]][0][11] == 1'b1)				//verificacao do bit dirty
				begin
					wback = 1'b1;
					wbackdata[13:11] = addin[2:0];
					wbackdata[10:0] = via[addin[0]][0][10:0];
				end
				if(writein == 1'b1)								//verificacao da ativacao da escrita
				begin
					via[addin[0]][0][2:0] = datain[2:0];
					via[addin[0]][0][11] = 1'b1;
				end
				else begin
					via[addin[0]][0][2:0] = in[2:0];
					via[addin[0]][0][11] = 1'b0;
				end
				via[addin[0]][0][10:3] = in[10:3];			//atualizacao da tag da via
				via[addin[0]][0][13] = 1'b1;					//atualizacao do bit de validade
				out[2:0] = via[addin[0]][0][2:0];			//definicao dos dados do sinal de saida
				via[addin[0]][0][12] = 1'b1;					//atualizacao do LRU
				via[addin[0]][1][12] = 1'b0;					//atualizacao do LRU
				dadoalterado = via[addin[0]][0][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
			
			else if(via[addin[0]][1][12] == 1'b0)			//verificacao do bit LRU
			begin
				if(via[addin[0]][1][11] == 1'b1)				//verificacao do bit dirty
				begin
					wback = 1'b1;
					wbackdata[13:11] = addin[2:0];
					wbackdata[10:0] = via[addin[0]][0][10:0];
				end
				if(writein == 1'b1)								//verificacao da ativacao da escrita
				begin
					via[addin[0]][1][2:0] = datain[2:0];
					via[addin[0]][1][11] = 1'b1;
				end
				else begin
					via[addin[0]][1][2:0] = in[2:0];
					via[addin[0]][1][11] = 1'b0;
				end
				via[addin[0]][1][10:3] = in[10:3];			//atualizacao da tag da via
				via[addin[0]][1][13] = 1'b1;					//atualizacao do bit de validade
				out[2:0] = via[addin[0]][1][2:0];			//definicao dos dados do sinal de saida
				via[addin[0]][0][12] = 1'b0;					//atualizacao do LRU
				via[addin[0]][1][12] = 1'b1;					//atualizacao do LRU
				dadoalterado = via[addin[0]][1][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
			
			missout = 1'b0;
		end
	
		//hit
		else if(missout == 1'b0)							//verificacao de miss
		begin
			if(via[addin[0]][0][13] == 1'b1 && datain[10:3] == via[addin[0]][0][10:3])			//verificacao do bit de validade e da tag
			begin
				if(writein == 1'b1)							//verificacao da ativacao da escrita
				begin
					via[addin[0]][0][2:0] = datain[2:0];
					via[addin[0]][0][11] = 1'b1;
				end
				out[2:0] = via[addin[0]][0][2:0];		//definicao dos dados do sinal de saida	
				missout = 1'b0;								//confirmacao de um hit
				via[addin[0]][0][12] = 1'b1;				//atualizacao do LRU
				via[addin[0]][1][12] = 1'b0;				//atualizacao do LRU
				dadoalterado = via[addin[0]][0][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
				
			else if(via[addin[0]][1][13] == 1'b1 && datain[10:3] == via[addin[0]][1][10:3])		//verificacao do bit de validade e da tag
			begin
				if(writein == 1'b1)							//verificacao da ativacao da escrita
				begin
					via[addin[0]][1][2:0] = datain[2:0];
					via[addin[0]][1][11] = 1'b1;
				end
				out[2:0] = via[addin[0]][1][2:0];		//definicao dos dados do sinal de saida
				missout = 1'b0;								//confirmacao de um hit
				via[addin[0]][0][12] = 1'b0;				//atualizacao do LRU
				via[addin[0]][1][12] = 1'b1;				//atualizacao do LRU
				dadoalterado = via[addin[0]][1][13:0];
				VLRUD = dadoalterado[13:11];
				tag = dadoalterado[10:3];
				dado = dadoalterado[2:0];
			end
				
			else begin											//ocorrencia de miss
				if(via[addin[0]][0][12] == 1'b0)
				begin
					dadoalterado = via[addin[0]][0][13:0];
					VLRUD = dadoalterado[13:11];
					tag = dadoalterado[10:3];
					dado = dadoalterado[2:0];
				end
				else if(via[addin[0]][1][12] == 1'b0)
				begin
					dadoalterado = via[addin[0]][1][13:0];
					VLRUD = dadoalterado[13:11];
					tag = dadoalterado[10:3];
					dado = dadoalterado[2:0];
				end
				missout = 1'b1;
				out = 3'b000;	
			end
		end
			
	end

endmodule
