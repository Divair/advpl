#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} BLQFINA
Permite ao usu�rio pr� selecionado via par�metros informar datas de bloqueio para movimenta��o financeira
@author Fernando Bueno (www.fbsolutions.com.br)
@since 03/05/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function BLQFINA() 

// Defini��o das vari�veis do programa. 
Local cCodUsr := RetCodUsr() 
Public _mvDATAFIN := GetMv("MV_DATAFIN") 
Public _mvBXDTFIN := GetMv("MV_BXDTFIN") 
Public _mvusuarios := GetMv("MV_X_ALFIN") //N�o esque�a de criar este par�metro
Private oPermBx
Private oMyDlg

// Verifica se o usu�rio � o Administrador do sistema ou usu�rios autorizados. 
If !Alltrim(cCodUsr) $ _mvusuarios 
     Alert("Somente o Administrador ou usu�rios autorizados podem executar esta rotina.") 
     Return 
EndIf 

// Solicita ao usu�rio informa��o 
@ 150, 1 TO 400, 635 DIALOG oMyDlg TITLE OemToAnsi("Bloqueio de movimenta��o financeira") 
@   2, 10 TO 110, 610 
@ 10, 18 Say OemToAnsi(" Movimenta��es somente a partir de ") 
@ 10,150 Get _mvDATAFIN Size 50,50 
@ 30, 18 Say OemToAnsi(" Permite baixas P/R anteriores a data do bloqueio? ") 
//@ 18,115 Get _mvBXDTFIN Size 50,50
@ 30,150 MSCOMBOBOX oPermBx VAR IIF(AllTrim(_mvBXDTFIN)=="1","Permite","Nao permite") ITEMS {OemToAnsi("Permite"),OemToAnsi("N�o permite")} SIZE 056, 010 OF oMyDlg COLORS 0, 16777215 PIXEL 

@ 110,150 BMPBUTTON TYPE 01 ACTION (RunProc(), Close(oMyDlg)) 
@ 110,180 BMPBUTTON TYPE 02 ACTION Close(oMyDlg) 
Activate Dialog oMyDlg Centered 
Return 

Static Function RunProc() 

// Faz valida��es e Altera os par�metros. 
If !Empty(_mvDATAFIN) 
     PutMv("MV_DATAFIN",_mvDATAFIN)
EndIf

If oPermBx:nAt == 1
	  PutMv("MV_BXDTFIN","1")
Else
	  PutMv("MV_BXDTFIN","2")
EndIf 

return
