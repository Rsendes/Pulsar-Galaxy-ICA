; ****************************************************************************************
;**************** Entrega da versão intermédia IAC 2019/2020******************************
;**************** Grupo 7                                   ******************************
;**************** José Afonso Garcia Nº96883 *********************************************
;**************** Pedro Peres        Nº96903 *********************************************
;**************** Filipe Resende     Nº96859 *********************************************
;*****************************************************************************************
Place 2000H	
cenario_selecionado EQU 600EH	; endereço de comando para definir o cenario
DISPLAY EQU 0A000H				; endereço de comando para escrever no display de numeros 
T_LINHA EQU 0C000H				; endereço de comando para selecionar a linha 
T_COLUNA EQU 0E000H				; endereço de comando para ler a coluna 
Ler_Sons EQU 06012H				; endereço de comando para reproduzir sons 
DESENHA_PIXEL    EQU 6008H      ; endereço do comando para escrever um pixel
DESENHA_LINHA    EQU 600AH      ; endereço do comando para definir a linha
DESENHA_COLUNA   EQU 600CH      ; endereço do comando para definir a coluna
LINHA EQU 8 					; linha 4

Nave: 
	STRING 0EH, 1EH 			; Ponto de referencia Linha-Coluna
	STRING 5H,5H				; Maximo de coluna e linha, no caso são os limites da nave
	STRING 0H,1H,1H,1H,0H		; Linha 1 da nave
	STRING 1H,0H,1H,0H,1H		; Linha 2 da nave
	STRING 1H,1H,1H,1H,1H		; Linha 3 da nave
	STRING 0H,1H,1H,1H,0H		; Linha 4 da nave
	STRING 0H,1H,0H,1H,0H		; Linha 5 da nave

Pulsar:
	STRING 0H, 3DH 				; Ponto de referencia Linha-Coluna
	STRING 3H,3H				; Maximo de coluna e linha, no caso são os limites da nave
	STRING 0H,1H,0H				; Linha 1 do pulsar
	STRING 1H,1H,1H				; Linha 2 do pulsar
	STRING 0H,1H,0H				; Linha 3 do pulsar
	

PLACE 0

INICIO:
	MOV SP, 2000H		; Pilha
	MOV R2, T_LINHA 	; endereço do periférico dos Linhas
	MOV R3, T_COLUNA	; endereço do periférico das colunas
	MOV R4, DISPLAY		; endereço do periférico dos displays
	MOV R9, 64H			; Inicio do valor = 100
	MOV R1, 100H		; Iniciar a 100 no contador
	MOV [R4], R1
Fundo:
	PUSH R7				
	MOV R7, cenario_selecionado 
	MOV R6, 0			; cenario 1 de fundo
	MOV [R7], R6		; Definir o cenario um no pixel screen 
	POP R7 				; Manter R7 a zero

Definir_nave:
	PUSH R4					; Guarda o valor do endereço do periferico dos displays
    MOV R4, Nave			; Definir o desenho da nave
	MOVb R1, [R4] 			; Escrever a Linha de Referencia
	CALL Definir_obejto		; Função de Desenhar 
	POP R4					; Recupera o valor do endereço do periferico dos displays

Definir_Pulsar:
	PUSH R4					; Guarda o valor do endereço do periferico dos displays
	MOV R4, Pulsar			; Definir o desenho do Pulsar
	MOVb R1, [R4] 			; Escrever a Linha de Referencia
	CALL Definir_obejto		; Função de Desenhar 
	POP R4					; Recupera o valor do endereço do periferico dos displays
	
RECOMEÇAR_O_CICLO_DE_ESPERA_DE_LINHAS: 
	MOV R1, LINHA		; Volta ou começa a procurar na linha 4
	
CICLO_DE_LINHAS:
	MOVB [R2], R1		; Escrever a linha 
	MOVB R0, [R3]		; Ler a coluna 
	CMP R0, 0			; Há tecla?
	JNZ Tem_tecla		; Passar para o display porque há tecla 
	SHR R1, 1 			; Como não há tecla nesta coluna, vamos passar a outra
	JZ RECOMEÇAR_O_CICLO_DE_ESPERA_DE_LINHAS ; Nenhuma tecla encontrada em nenhuma linha, voltar a testar
	JMP CICLO_DE_LINHAS	; Como ainda há coluna para testar, vamos testar as linhas dela

Tem_tecla:
	PUSH R1			    ; Guardar a linha 	
	PUSH R0			 	; Guardar a Coluna
	PUSH R7				; Guardar Valores 
	PUSH R6				; Guardar Valores 
	MOV R7, 0			; Contador de linha
	MOV R6, 0			; Contador de coluna
CONTADOR_DE_LINHA:
	CMP R1, 1			; É a linha 1?
	JZ CONTADO_DE_COLUNA; Sim, vai ver qual é a linha
	ADD R7, 1			; NÃO é por isso vai adicionar um ao contador
	SHR R1, 1			; Passar para o proximo byte
	JNZ CONTADOR_DE_LINHA; Testar mais um Byte até ao ultimo

CONTADO_DE_COLUNA:
	CMP R0, 1			 ; É a coluna 1?
	JZ 	Conversor_display; Sim, vai para o conversor 
	SHR R0, 1			 ; Passar para o proximo Byte
	ADD R6, 1			 ; Adicionar um ao contador 
	JMP CONTADO_DE_COLUNA; Testar mais um Byte
	
Conversor_display:
	SHL R7, 2			; Multiplica a linha por 4
	ADD R7, R6			; Adicionar a linha à coluna 
	CMP R7, 7  			; É a tecla 7?
	JZ Somar			; Sim
	CMP R7, 3			; É a tecla 3?
	JZ Subtrair			; Sim
	CMP R7, 2			; É a tecla 2?
	JZ Sons				; Sim
	JMP CICLO_DE_LINHAS ; É uma tecla sem função, por isso recomeçar 

Escrever:
	PUSH R8				; Guardar Valores
	PUSH R11			
	PUSH R9
	MOV R11, 0AH		; Definir o valor para converte um numero HEXA para Base 10
	MOV R8, R9			; Copiar para ter nibble high e nibble low
	MOD R8, R11			; nibble Low
	DIV R9, R11			; nibble high
	CMP R9, R11			; Ver se é o 100?
	JLT Nao_100_escreve	; Não é o 100 por isso escre
	DIV R9, R11			; É 100, por isso vamos dividir por A mais uma vez
	SHL R9, 8			; Colocar o 1 no oitavo byte , para aparecer 100 no display
	MOV [R4], R9		; Escreve o numero da tecla no display
	JMP Escrito2		; Já escreveu, continuar 
Nao_100_escreve:		; Não era o 100, por isso não há mais divisões 
	SHL R9, 4			; passar o valor do primeiro digito para nibble high
	OR  R9, R8			; Juntar o nibble high e nibble low
	MOV [R4], R9        ; escrever no display
	CAll temporizador	; Função para atrasar a velocidade do computador 
;**********************************************************************************************
;*************************** Repor valores na pilha salata para aqui se escreveu 100***********
;**********************************************************************************************
Escrito2:	
	POP R9				
	POP R11
	POP R8
;************************************************************************************************
;****************************** Salta diretamente para aqui se já for 100 ou 0 no contador*******
;************************************************************************************************
Escrito1:
	POP R6				; Recuperar o valor do contador
	POP R7				; Recuperar o valor do contador
	POP R0				; Recuperar o valor da Coluna
	POP R1				; Recuperar o valor da Linha

HA_TECLA:
	MOVB [R2], R1		; Escrever a linha
	MOVB R0, [R3]		; Ler a coluna	
	CMP R0,0			; Ainda Há tecla?
	JNZ Tem_tecla		; Sim
	JMP RECOMEÇAR_O_CICLO_DE_ESPERA_DE_LINHAS			; Não

;********************************************************************************************
;************************ Somar ao valor no display******************************************
;********************************************************************************************	
Somar:		
	MOV R7, 64H  		; 64h= 100, que é o valor maximo do Display 
	CMP R9, R7			; Se Já for 100 salta
	JGT  Escrito1		; Salta para não escrever e vai repor valores da pilha 
	ADD R9, 1			; se não for 100 soma
	JMP Escrever		; Vai escrever 
;********************************************************************************************
;*********************** Subtrair ao valor no display ***************************************
;********************************************************************************************
Subtrair:
	CMP R9, 0			; Compar se já é o valor zero no Display
	JLE Escrito1		; Se já for 0, não vai escrever e vai repor os valores da pilha
	SUB R9, 1			; Não era zero por isso Subtrai
	JMP Escrever		; Vai Escrever o novo valor 
;*********************************************************************************************
;************************ Tocar o Som ********************************************************
;*********************************************************************************************
Sons:
	MOV R7, Ler_Sons	; Endereço do Som
	MOV R6, 0			; Som 1 para tocar 
	MOV [R7], R6		; tocar
	POP R6				; Recuperar o valor do contador
	POP R7				; Recuperar o valor do contador
	POP R0				; Recuperar o valor da Coluna
	POP R1				; Recuperar o valor da Linha
;******* Só vai tocar uma Vez, enquanto a tecla está premida fica bloqueado aqui *******
HA_TECLA2:
	MOVB [R2], R1		; Escrever a linha
	MOVB R0, [R3]		; Ler a coluna	
	CMP R0,0			; Ainda Há tecla?
	JNZ HA_TECLA2		; Sim
	JMP RECOMEÇAR_O_CICLO_DE_ESPERA_DE_LINHAS ; Já não Há, Volta a procurar 
;*******************************************************************************************************************************************************
;*************Função para atrasar a velocidade do pepe**************************************************************************************************
;*******************************************************************************************************************************************************
temporizador:
	PUSH R1
	MOV R1, 0100H
temp_1:
	SUB R1, 1
	CMP R1, 0
	JNZ temp_1
	POP R1
	RET
;*************************************************** Desenhar ******************************************************************************************
;**************************** Função que desenha e define obejetos no Pixel Screen**********************************************************************
;****************************R0-Coluna de Referencia/R1-Linha de Referencia/R2-Maximo de Coluna/R3-Maximo de Linha/R5-Escrever ou não o Pixel***********
;*******************************************************************************************************************************************************
Definir_obejto:				; Definir os Objetos a Desenhar
	PUSH R0					; Guardar valores para não alterar nada no programa principal
	PUSH R1				
	PUSH R2
	PUSH R3
	PUSH R5
	PUSH R6
	ADD R4, 1				; Passar para o proximo valor da string
	MOVb R0, [R4]			; Coluna de Referencia R0
	ADD R4, 1				; Passar para o proximo valor da string
	MOVb R2, [R4]			; Valor maximo da Coluna R2
	ADD R4, 1				; Passar para o proximo valor da string
	MOVb R3, [R4]			; Valor Maximo da Linha  R3
	ADD R4, 1				; Passar para o proximo valor da string
	MOVB R5, [R4]			; Primeiro Pixel
	CALL Desenhar			; Função Para desenhar no pixel screen
		POP R6				; Repor valores 
		POP R5
		POP R3
		POP R2
		POP R1
		POP R0
		RET					; Voltar ao Programa 
Desenhar:				
		PUSH R0				; Guardar o Valor da Coluna 
		PUSH R2				; Guardar o Valor maximo da Coluna
	
	Desenha_Pixel:
		
		MOV  R6, DESENHA_LINHA	 
		MOV  [R6], R1           ; Escolhe a linha para desenhar 
						
    
		MOV  R6, DESENHA_COLUNA	 
		MOV  [R6], R0          	; Escolhe a Coluna para desenhar	

		MOV  R6, DESENHA_PIXEL	
		MOV  [R6], R5      		; Desenha ou não o pixel, se for 1, desenha
		
		
		ADD R0, 1				; Passar para o proximo ponto da Linha
		ADD R4, 1				; Ver se é para escrever o Proximo ponto
		MOVb R5, [R4]			
		SUB R2, 1				; Quantas colunas da linha faltam?
		CMP R2, 0				
		JNZ Desenha_Pixel		; Se ainda falta, continuar 
		
		POP R2      			; Voltar ao maximo da Coluna
		POP R0					; Volara à Coluna 1
		JMP Proxima_Linha		; Passar para a proxima linha se ainda há
		
Proxima_Linha:
		ADD R1, 1				; Proxima Linha
		SUB R3, 1				; Ainda há Linhas?
		JNZ Desenhar			
		RET						; Já não há
;********************************************************************************************************************************************************************

	