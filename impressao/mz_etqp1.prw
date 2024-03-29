#INCLUDE "Rwmake.CH"
#include "sigawin.ch"
#include "colors.ch"
#INCLUDE "topconn.ch"
#include "topdef.ch"
#INCLUDE "TBICONN.CH"
#include "ap5mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

// Etiquetas para Pallets/Caixas;
User Function MZ_ETQP1(_xOP)
	Local _lRet        := .T.
	Private _rImp      := .F.
	Do While _lRet
		_lRet := _Continua(_xOP)
	EndDo
Return

Static Function _Continua(_xOP)
	Local _nRet        := 0
	//Local _aArea 	    := GetArea()
	//Local _aAreaSc2    := SC2->(GetArea())
	//Local _aAreaSd4    := SD4->(GetArea())
	Private _lWhenOP 	 := .T.
	Private _lWhenQte  := .T.
	Private _cOp       := iif(_xOP==Nil,Space(15),_xOP)
	Private _oOP
	Private _cCodPro   := space(15)
	Private _cDesPro   := space(50)
	Private _oCodPro
	Private _oDesPro
	Private _cCodBar  := ""
	Private _oCodBar
	Private _cLote   	:= space(10)
	Private _oLote
	Private _dFabric 	:= stod("")
	Private _oFabric
	Private _dValid		:= stod("")
	Private _oValid
	Private _nQtEtiq   	:= 1
	Private _oQtEtiq
	Private _lLibProd  	:= .F.
	Private oChkPc

	If !Empty(_cOp)
		_lWhenOP := !_VldOP(_cOP,.F.)
	EndIf

	@ 050, 100 TO 300,1000 DIALOG oDlg1 TITLE "Etiquetas Termicas"

	@ 005, 005 Say "OP" Pixel Of oDlg1
	@ 005, 060 GET _cOp   Size 50, 11 picture "@!" F3 "SC2" When _lWhenOP .And. !_lLibProd Valid _VldOP(_cOP,.T.) Object _oOP

	@ 005, 300 CHECKBOX oChkPc  VAR _lLibProd  PROMPT " Ativar por Produto?"     SIZE 150, 10 Pixel Of oDlg1 PIXEL ON CLICK ( iif(_lLibProd,(_oCodPro:Enable(),_oCodPro:SetFocus(),_oOP:Disable()),(_oCodPro:Disable(),_oOP:SetFocus(),_oOP:Enable())),_oOP:Refresh(),_oCodPro:Refresh(),nRet := 0 )Pixel Of oDlg1

	@ 020, 005 Say "Produto:" Pixel Of oDlg1
	@ 020, 060 Get _cCodPro  Size  55, 11 picture "@!" F3 "SB1" Valid _VldProd() Object _oCodPro When _lLibProd
	@ 020, 120 Get _cDesPro  Size 300, 11 Object _oDesPro When .F.

	@ 035, 005 Say "Cod Barra:" Pixel Of oDlg1
	@ 035, 060 Get _cCodBar  Size  55, 11 picture "@!" Object _oCodBar When .F.

	@ 050, 005 Say "Lote:" Pixel Of oDlg1
	@ 050, 060 Get _cLote  	Size  55, 11 picture "@!"  Valid _VldLote() Object _oLote When _lLibProd
	@ 050, 120 Say "Dt Fabric:" Pixel Of oDlg1
	@ 050, 155 Get _dFabric  Size 55, 11 Object _oFabric When .F.
	@ 050, 220 Say "Dt Valid:" Pixel Of oDlg1
	@ 050, 255 Get _dValid 	 Size 55, 11 Object _oValid  When .F.

	@ 065, 005 Say "Quant. Etiquetas:"  Pixel Of oDlg1
	@ 065, 060 Get _nQtEtiq  Size  60, 11 picture "@e 999,999,999,999.99" When _lWhenQte Valid _VldQtEtiq(.T.,.F.) Object _oQtEtiq

	@ 090, 205 BUTTON "&Imprimir" 	Size 45, 15 ACTION Close(oDlg1) .and. (_nRet := 1) Pixel Of oDlg1
	@ 090, 255 BUTTON "&Sair" 		Size 45, 15 ACTION Close(oDlg1) .And. (_nRet := 2) Pixel Of oDlg1
	ACTIVATE DIALOG oDlg1 CENTERED

	If _nRet == 1
		_VImpEtq()
	EndIf

Return((_nRet <= 1))

Static Function _VldLote()
	Local _lRet := .T.
	_dFabric 	:= sTod("")
	_dValid 	:= sTod("")
	cQuery := " SELECT * FROM "+RetSqlName("SB8")+" SB8 "
	cQuery += " WHERE B8_FILIAL = '"+xFilial("SB8")+"' "
	cQuery += " AND B8_PRODUTO 	= '"+_cCodPro+"'"
	cQuery += " AND B8_LOTECTL  = '"+_cLote+"'"
	cQuery += " AND D_E_L_E_T_	<> '*' "
	cQuery += " AND B8_DFABRIC  <> ' ' "
	cQuery += " ORDER BY R_E_C_N_O_ "

	TCQuery cQuery NEW ALIAS "_SB8"
	DbSelectArea("_SB8")
	_SB8->(DbGoTop())
	If !_SB8->(EOF())
		_dFabric	:= stod(_SB8->B8_DFABRIC)
		_dValid		:= stod(_SB8->B8_DVALID)
	EndIf
	_SB8-> (DbCloseArea())
	cQuery := " "
	cQuery += " SELECT * FROM "+RetSqlName("SC2")+" SC2 "
	cQuery += " WHERE C2_FILIAL =  '"+xFilial("SC2")+"' "
	cQuery += " AND D_E_L_E_T_ 	<> '*' "
	cQuery += " AND C2_LOTE 	= '"+_cLote+"' "
	cQuery += " AND C2_PRODUTO 	= '"+_cCodPro+"' "
	cQuery += " ORDER BY C2_NUM "

	TCQuery cQuery NEW ALIAS "_SC2"

	DbSelectArea("_SC2")
	_SC2->(DbGoTop())
	If !_SC2->(EOF())
		_cOP 		:= _SC2->C2_NUM+_SC2->C2_ITEM+_SC2->C2_SEQUEN+_SC2->C2_ITEMGRD
		_dFabric 	:= IIF(!Empty(_dFabric),_dFabric,stod(_SC2->C2_EMISSAO))
		_dValid		:= IIF(!EMpty(_dValid),_dValid,_dFabric + Posicione("SB1",1,xFilial("SB1")+_SC2->C2_PRODUTO,"SB1->B1_PRVALID"))
	Else
		_cOP 		:= SPACE(15)
	EndIf
	_SC2->(DbCloseArea())
	DbSelectArea("SC2")
	_oOP:Refresh()
	_oFabric:Refresh()
	_oValid:Refresh()
Return(_lRet)

Static Function _VldProd()
	Local _lRet := .T.
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cCodPro)
	If Found()
		_cDesPro  	:= SB1->B1_DESC
		_cCodBar	:= SB1->B1_CODBAR
		_nQtEtiq  	:= 1
	Else
		_nQtEtiq  := 0
		_cCodPro  := ""
		_cDesPro  := ""
		_cCodBar  	:= ""
	Endif
	_oQtEtiq:Refresh()
	_oCodPro:Refresh()
	_oDesPro:Refresh()
	_oCodBar:Refresh()
Return(_lRet)

Static Function _VldOP(_cOP, _lRefresh)
	Local _lRet := .T.
	DbSelectArea("SC2")
	DbSetOrder(1)
	DbSeek(xFilial("SC2")+Alltrim(_cOP))
	If Found() .And. !Empty(_cOP)
		_nQtEtiq := SC2->C2_QUANT
		_cLote   := SC2->C2_LOTE
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)
		If Found()
			_cCodPro  	:= SC2->C2_PRODUTO
			_cDesPro  	:= SB1->B1_DESC
			_cCodBar	:= SB1->B1_CODBAR
		Else
			_cCodPro  	:= Space(15)
			_cDesPro  	:= ""
			_cCodBar  	:= ""
		Endif
		_dFabric 	:= sTod("")
		_dValid 	:= sTod("")
		cQuery := " SELECT * FROM "+RetSqlName("SB8")+" SB8 "
		cQuery += " WHERE B8_FILIAL = '"+xFilial("SB8")+"' "
		cQuery += " AND B8_PRODUTO 	= '"+_cCodPro+"'"
		cQuery += " AND B8_LOTECTL  = '"+_cLote+"'"
		cQuery += " AND D_E_L_E_T_	<> '*' "
		cQuery += " AND B8_DFABRIC  <> ' ' "
		cQuery += " ORDER BY R_E_C_N_O_ "

		TCQuery cQuery NEW ALIAS "_SB8"
		DbSelectArea("_SB8")
		_SB8->(DbGoTop())
		If !_SB8->(EOF())
			_dFabric	:= stod(_SB8->B8_DFABRIC)
			_dValid		:= stod(_SB8->B8_DVALID)
		EndIf
		_SB8-> (DbCloseArea())
		DbSelectArea("SC2")
		_dFabric 	:= IIF(!Empty(_dFabric),_dFabric,SC2->C2_EMISSAO)
		_dValid		:= IIF(!EMpty(_dValid),_dValid,_dFabric + Posicione("SB1",1,xFilial("SB1")+_cCodPro,"SB1->B1_PRVALID"))
	else
		MsgBox("Ordemd e Producao Invalida","ATENCAO","STOP")
		_lRet := .F.
	Endif
	If _lRefresh
		_oCodPro:Refresh()
		_oDesPro:Refresh()
		_oCodBar:Refresh()
		_oQtEtiq:Refresh()
		_oCodPro:Refresh()
		_oDesPro:Refresh()
		_oFabric:Refresh()
		_oValid:Refresh()
	EndIf
Return(_lRet)

Static Function _VldQtEtiq(_lRefresh, _lImpressao)
	Local _lRet := .T.
	If _nQtEtiq <= 0
		MsgBox("Quantidade Invalida","ATENCAO","STOP")
		_lRet := .F.
	EndIf
	If _lRefresh
		_oQtEtiq:Refresh()
	Endif
Return(_lRet)

Static Function _VImpEtq()
	Local _lRet 	:= .F.
	Local _nSeqEtq	:= 1
	local lOk := .t.

	Private _oDestino
	Private _cDestino  := ""
	Private _oImpress
	Private _cImpress  := ""
	Private _cLocImp   := sPace(6)
	Private _lLocImp   := .T.
	_cLocImp := "ETQPCP"

	If !Empty(_cLocImp)
		_cDestino := U_VldCb5(_cLocImp,.F.)
	EndIf
	@ 050, 100 TO 250,600 DIALOG oDlgImp TITLE "Local Impressao"
	@ 005, 005 say "Local Impressao:"    Pixel Of oDlgImp
	@ 020, 060 Get _cImpress  Size 150, 11 Object _oImpress When .F.
	@ 005, 060 get _cLocImp   Size 040, 11 Picture "@!" When _lLocImp F3 "CB5" Valid !Empty(U_VldCb5(_cLocImp,.T.)) Object _oLocImp
	@ 035, 060 Get _cDestino  Size 150, 11 Object _oDestino When .F.

	@ 060, 070 BUTTON "&Imprimir" 	Size 45, 15 ACTION Close(oDlgImp) .and. (_lRet := .T.) Pixel Of oDlg1
	@ 060, 105 BUTTON "&Sair" 		Size 45, 15 ACTION Close(oDlgImp) .And. (_lRet := .F.) Pixel Of oDlg1
	ACTIVATE DIALOG oDlgImp CENTERED

	_cDestino := U_VldCb5(_cLocImp)
	If _lRet
		U_CB5SetImp(_cLocImp)
		//CB5SetImp(_cLocImp)

		lOk := MsgYesNo("Usar rotina padrao", "Atenção")

		if lOk
			/*
			For _nSeqEtq := 1 To _nQtEtiq
				MSCBBegin(1,2)
				
				MSCBSAY(05, 10, _cCodPro, "B", "D", "01,01")
				MSCBSAY(10, 1, AllTrim(substr(_cDesPro,1,30)), "B", "4", "10,10")
				MSCBSAY(15, 1, AllTrim(substr(_cDesPro,31,30)), "B", "4", "20,20")

				MSCBSAYBAR(54, 3, Alltrim(_cCodBar), "B", "A", 12.00, .F., .T., .F., , 6, 2, .F., .F., "1", .T.)

				MSCBSAY(36, 20, "PART:"+Alltrim(_cLote), "B", "2", "01,01")
				MSCBSAY(48, 20, "FABR:"+SubStr(dtos(_dFabric),5,2)+"/"+SubStr(dtos(_dFabric),1,4), "B", "2", "01,01")
				MSCBSAY(54, 20, "VENC:"+SubStr(dtos(_dValid),5,2)+"/"+SubStr(dtos(_dValid),1,4), "B", "2", "01,01")

				_cBarra1 := "(01)"+Alltrim(_cCodPro)+;
					"(17)"+SubStr(dtos(_dValid),3,4)+"01"+;
					"(10)"+Alltrim(_cLote)+">8"
				//MSCBWrite("^FT700,390^BQN,2,3^FDM,"+_cBarra1+"^FS")//qrcode28,72
				MSCBWrite("^FO350,100^BXN,10,200^FD"+_cBarra1+"^FS")//Data Matrix

				MSCBEND()
				
			Next _nSeqEtq
			*/
			For _nSeqEtq := 1 To _nQtEtiq
				MSCBBegin(1,2)

				MSCBSAY(05, 10, _cCodPro, "N", "0", "029, 036")
				MSCBSAY(10, 1, AllTrim(substr(_cDesPro,1,30)), "N", "0", "029, 036")
				MSCBSAY(15, 1, AllTrim(substr(_cDesPro,31,30)), "N", "0", "029, 036")

				MSCBSAYBAR(54, 3, Alltrim(_cCodBar), "B", "A", 12.00, .F., .T., .F., , 6, 2, .F., .F., "1", .T.)

				MSCBSAY(36, 20, "PART:"+Alltrim(_cLote), "N", "0", "029, 036")
				MSCBSAY(48, 20, "FABR:"+SubStr(dtos(_dFabric),5,2)+"/"+SubStr(dtos(_dFabric),1,4), "N", "0", "029, 036")
				MSCBSAY(54, 20, "VENC:"+SubStr(dtos(_dValid),5,2)+"/"+SubStr(dtos(_dValid),1,4), "N", "0", "029, 036")

				_cBarra1 := "(01)"+Alltrim(_cCodPro)+;
					"(17)"+SubStr(dtos(_dValid),3,4)+"01"+;
					"(10)"+Alltrim(_cLote)+">8"
				//MSCBWrite("^FT700,390^BQN,2,3^FDM,"+_cBarra1+"^FS")//qrcode28,72
				MSCBWrite("^FO350,100^BXN,10,200^FD"+_cBarra1+"^FS")//Data Matrix

				MSCBEND()
			Next _nSeqEtq

		else

			lOk := MsgYesNo("Usar rotina MSCBWrite", "Atenção")

			if lOk
				For _nSeqEtq := 1 To _nQtEtiq
					MSCBBegin(1,2)

					MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ")
					MSCBWrite("^XA")
					MSCBWrite("^MMT")
					MSCBWrite("^PW831")
					MSCBWrite("^LL0599")
					MSCBWrite("^LS0")
					MSCBWrite("^FT112,150^A0N,130,201^FH\^FD"+_cCodPro+"^FS")
					MSCBWrite("^FT25,303^A0N,125,134^FH\^FD"+AllTrim(substr(_cDesPro,1,30))+"^FS")
					MSCBWrite("^FO350,379^GB239,142,1^FS")
					MSCBWrite("^FT372,425^A0N,28,28^FH\^FDLOT.:^FS")
					MSCBWrite("^FT457,425^A0N,28,28^FH\^FD"+Alltrim(_cLote)+"^FS")
					MSCBWrite("^FT372,464^A0N,28,28^FH\^FDFAB.:^FS")
					MSCBWrite("^FT457,465^A0N,28,28^FH\^FD"+SubStr(dtos(_dFabric),5,2)+"/"+SubStr(dtos(_dFabric),1,4)+"^FS")
					MSCBWrite("^FT372,504^A0N,28,28^FH\^FDVAL.:^FS")
					MSCBWrite("^FT457,503^A0N,28,28^FH\^FD"+SubStr(dtos(_dValid),5,2)+"/"+SubStr(dtos(_dValid),1,4)+"^FS")
					_cBarra1 := "(01)"+Alltrim(_cCodPro)+"(17)"+SubStr(dtos(_dValid),3,4)+"01"+"(10)"+Alltrim(_cLote)+">8"
					//MSCBWrite("^FO600,360^BXN,13,200^FD"+_cBarra1+"^FS")
					MSCBWrite("^FT610,540^BQN,2,8^FDM,"+_cBarra1+"^FS")
					MSCBWrite("^BY3,3,90^FT50,480^BEN,,Y,N")
					MSCBWrite("^FD"+_cCodBar+"^FS")
					MSCBWrite("^PQ1,0,1,Y^XZ")

					MSCBEND()
				Next _nSeqEtq
			else
				MSCBBegin(1,2)

				MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ")
				MSCBWrite("^XA")
				MSCBWrite("^MMT")
				MSCBWrite("^PW831")
				MSCBWrite("^LL0599")
				MSCBWrite("^LS0")
				MSCBWrite("^FT112,150^A0N,130,201^FH\^FD"+_cCodPro+"^FS")
				MSCBWrite("^FT25,303^A0N,125,134^FH\^FD"+AllTrim(substr(_cDesPro,1,30))+"^FS")
				MSCBWrite("^FO350,379^GB239,142,1^FS")
				MSCBWrite("^FT372,425^A0N,28,28^FH\^FDLOT.:^FS")
				MSCBWrite("^FT457,425^A0N,28,28^FH\^FD"+Alltrim(_cLote)+"^FS")
				MSCBWrite("^FT372,464^A0N,28,28^FH\^FDFAB.:^FS")
				MSCBWrite("^FT457,465^A0N,28,28^FH\^FD"+SubStr(dtos(_dFabric),5,2)+"/"+SubStr(dtos(_dFabric),1,4)+"^FS")
				MSCBWrite("^FT372,504^A0N,28,28^FH\^FDVAL.:^FS")
				MSCBWrite("^FT457,503^A0N,28,28^FH\^FD"+SubStr(dtos(_dValid),5,2)+"/"+SubStr(dtos(_dValid),1,4)+"^FS")
				_cBarra1 := "(01)"+Alltrim(_cCodPro)+"(17)"+SubStr(dtos(_dValid),3,4)+"01"+"(10)"+Alltrim(_cLote)+">8"
				//MSCBWrite("^FO600,360^BXN,13,200^FD"+_cBarra1+"^FS")
				MSCBWrite("^FT610,540^BQN,2,8^FDM,"+_cBarra1+"^FS")
				MSCBWrite("^BY3,3,90^FT50,480^BEN,,Y,N")
				MSCBWrite("^FD"+_cBarra1+"^FS")
				MSCBWrite("^PQ1,0,1,Y^XZ")

				MSCBEND()
			endif

		endif

		MSCBCLOSEPRINTER()
	Endif
Return


