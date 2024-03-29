#include "rwmake.ch"

User Function MZ_CB5()

	* Programa..: MZ_CB5.PRX
	* Autor.....: Mario
	* Data......: 18/04/2012
	* Nota......: Relacao de Etiquetas Lidas no Recebimento da NF

	Axcadastro("CB5","Tipos de Impressao")
Return

User Function VldCb5(_cLocImp,_xAtuTela)
	Local _lAtuTela := iif(_xAtuTela==NIL,.F.,_xAtuTela)
	If Type("_cDestino") <> "C"
		Private _cDestino := ""
	EndIf
	If Type("_cImpress") <> "C"
		Private _cImpress := ""
	EndIf
	DbSelectArea("CB5")
	DbSetOrder(1)
	DbSeek(xFilial("CB5")+_cLocImp)
	If !Found()
		MsgBox("Local de Impressao nao definido","ATENCAO","STOP")
	ElseIf CB5->CB5_TIPO == '0' .And. CB5->CB5_LPT <> "0"
		Do Case
		Case CB5->CB5_LPT == '1'
			_cDestino := "LPT1"
		Case CB5->CB5_LPT == '2'
			_cDestino := "LPT2"
		Case CB5->CB5_LPT == '3'
			_cDestino := "LPT3"
		Case CB5->CB5_LPT == '4'
			_cDestino := "LPT4"
		EndCase
	ElseIf CB5->CB5_TIPO == '0' .And. CB5->CB5_PORTA <> "0"
		Do Case
		Case CB5->CB5_LPT == '1'
			_cDestino := "COM1"
		Case CB5->CB5_LPT == '2'
			_cDestino := "COM2"
		Case CB5->CB5_LPT == '3'
			_cDestino := "COM3"
		Case CB5->CB5_LPT == '4'
			_cDestino := "COM4"
		EndCase
	ElseIf CB5->CB5_TIPO == '4' .And. !Empty(CB5->CB5_SERVER)
		If !Empty(CB5->CB5_MODELO)
			_cDestino := "\\"+Alltrim(CB5->CB5_SERVER)+"\"+Alltrim(CB5->CB5_MODELO)
		ElseIf !Empty(CB5->CB5_ENV)
			_cDestino := "\\"+Alltrim(CB5->CB5_SERVER)+"\"+Alltrim(CB5->CB5_ENV)
		Endif
	Else
		_cDestino := Alltrim(CB5->CB5_CODIGO)
		//MsgBox("Configuracao de impressao Invalida","ATENCAO","STOP")
	Endif
	If !Empty(_cDestino)
		_cImpress := CB5->CB5_DESCRI
	EndIf
	If _lAtuTela
		_oDestino:Refresh()
		_oImpress:Refresh()
	EndIf
Return(_cDestino)



User Function CB5SetImp(cCod,lVerServer,nDensidade,nTam,cPorta)
	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila,lDrvWin

	If Empty(cCod)
		Return .f.
	EndIf
	If ! CB5->(DbSeek(xFilial("CB5")+cCod))
		Return .f.
	EndIf
	cModelo :=Trim(CB5->CB5_MODELO)
	If cPorta ==NIL
		If CB5->CB5_TIPO == '4'
			cPorta:= "IP"
		Else
			IF CB5->CB5_PORTA $ "12345"
				cPorta  :='COM'+CB5->CB5_PORTA+':'+CB5->CB5_SETSER
			EndIf
			IF CB5->CB5_LPT $ "12345"
				cPorta  :='LPT'+CB5->CB5_LPT+':'
			EndIf
		EndIf
	EndIf

	lTipo   :=CB5->CB5_TIPO $ '12'
	nPortIP :=Val(CB5->CB5_PORTIP)
	cServer :=Trim(CB5->CB5_SERVER)
	cEnv    :=Trim(CB5->CB5_ENV)
	cFila   := NIL
	If CB5->CB5_TIPO=="3"
		cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
	EndIf
	nBuffer := CB5->CB5_BUFFER
	lDrvWin := (CB5->CB5_DRVWIN =="1")
	//MSCBPRINTER(cModelo,cPorta,nDensidade,nTam,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
	MSCBPRINTER(cModelo  ,cPorta,		   ,	,     ,nPortIP,cServer,cEnv,nBuffer,	 ,	     ,				     ,.F.)
	MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

Return .t.
/*
MSCBSayBar
Tipo: Impressão
Imprime Código de Barras

Sintaxe
Exemplo
MSCBSAYBAR(20,22,AllTrim(SB1->B1_CODBAR),"N","C",13)

MSCBSAYBAR(<nXmm>,<nYmm>,<cConteudo>,<cRotacao>,<cTypePrt>,<nAltura>, ;
<lDigVer>,<lLinha>,<lLinBaixo>,<cSubSetIni>,<nLargura>,<nRelacao>, ;
<lCompacta>,<lSerial>,<cIncr>,<lZerosL>)

Parâmetros
nXmm             = Posição X em Milímetros
nYmm             = Posição Y em Milímetros
cConteudo         = String a ser impressa
cRotação          = String com o tipo de Rotação
cTypePrt          = String com o Modelo de Código de Barras
Zebra:
2 - Interleaved 2 of 5
3 - Code 39
8 - EAN 8
E - EAN 13
U - UPC A
9 - UPC E
C - CODE 128
Allegro:
D - Interleaved 2 of 5
A - Code 39
G - EAN 8
F - EAN 13
B - UPC A
C - UPC E
E - CODE 128
Eltron:
2   - Interleaved 2 of 5
3   - Code 39
E80 - EAN 8
E30 - EAN 13
UA0 - UPC A
UE0 - UPC E
1   - CODE 128

[nAltura]        = Altura do código de Barras em Milímetros
*[ lDigver]      = Imprime dígito de verificação
[lLinha]         = Imprime a linha de código
*[lLinBaixo]     = Imprime a linha de código acima das barras
[cSubSetIni]     = Utilizado no code128
[nLargura]      = Largura da barra mais fina em pontos default 3
[nRelacao]      = Relação entre as barras finas e grossas em pontos default 2
[lCompacta]     = Compacta o código de barra
[lSerial]     = Serializa o código
[cIncr]        = Incrementa quando for serial positivo ou negativo
*[lZerosL]      = Coloca zeros a esquerda no numero serial

Exemplo
MSCBSAYBAR(20,22,AllTrim(SB1->B1_CODBAR),"N","C",13)
*/
