#include "protheus.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "FILEIO.CH"
#include "colors.ch"
#include "sigawin.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "JPEG.CH"
#Include "Totvs.ch"
#include "dbtree.ch"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*---------------------------------------------------------------------------||
|| Programa  | MFZINTPRD| Autor | Felipe Zimmermann      | Data | 18/09/2023 ||
||---------------------------------------------------------------------------||
|| Descricao | Envia O.Ps para o M.E.S e faz apontamento das O.Ps do M.E.S	 ||
||---------------------------------------------------------------------------||
|| Programador  |  Data  | Motivo da Alteracao                               ||
||---------------------------------------------------------------------------||
||              |        |                                                   ||
||              |        |                                                   ||
||---------------------------------------------------------------------------*/

User Function APORKM(_nQual)
	Local nAux 			:= 1
	Local _nx 			:= 1
	Private lMsErroAuto :=.F.
	Private lMsHelpAuto :=.T.
	Private _nProtheus
	Private _nMes
	Private _lAuto		:= .F.
	Private _lRet		:= .F.
	Private _lMes 		:= .T.
	Public _cMes 		:= ""
	DEFAULT _nQual 		:= "1"
	If _nQual == "1"
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SM0","SX5", "SX6", "SX7","SB1","SB2", "SB8","SC2", "SD3", "SD4", "SD5", "SF5"
	EndIf
	_lRet := U__conectar(.F.)
	If _lRet
		_lRet := .T.
		_cQuery := " SELECT H6_FILIAL, H6_OP, H6_DATAINI FROM "+GetMv("FZ_INTSH6")//+GetMv("FZ_INTSH6")
		_cQuery += " WHERE H6_STATUSIMPORTACAO = 'P' "
		//_cQuery += " AND H6_OP = '20273901001' "
		_cQuery += " GROUP BY H6_FILIAL, H6_OP, H6_DATAINI "
		_nMes:NewAlias( _cQuery, "_SH6RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query _ZERAEMPna conexão remota do objeto
		If _nMes:HasError()
			cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
			FWAlertWarning(cMsg)
		EndIf
		Do While !_SH6RK->(EOF())
			_cQuery := " SELECT * FROM "+GetMv("FZ_INTSD3")//+GetMv("FZ_INTSD3")
			_cQuery += " WHERE D3_STATUSIMPORTACAO IN ('E','I') "
			_cQuery += " AND D3_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
			_cQuery += " AND D3_OP = '"+_SH6RK->H6_OP+"' "
			_nMes:NewAlias( _cQuery, "_SD3XRK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
			If _nMes:HasError()
				cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
				FWAlertWarning(cMsg)
			EndIf
			If _SD3XRK->(EOF())
				_cQuery := " SELECT * FROM "+GetMv("FZ_INTSD3")//+GetMv("FZ_INTSD3")
				_cQuery += " WHERE D3_STATUSIMPORTACAO = 'P' "
				_cQuery += " AND D3_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
				_cQuery += " AND D3_OP = '"+_SH6RK->H6_OP+"' "
				_nMes:NewAlias( _cQuery, "_SD3RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
				If _nMes:HasError()
					cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
					FWAlertWarning(cMsg)
				EndIf
				Do While !_SD3RK->(EOF())// .And. 1 == 2
					dbSelectArea("SD4")
					dbGoTop()
					dbSetOrder(2)
					dbSeek(xFilial("SD4")+_SH6RK->H6_OP)
					if Found()
						do while !eof() .and.  Alltrim(_SH6RK->H6_OP) == Alltrim(SD4->D4_OP)
							aLine := {}
							_cOp := SD4->D4_OP
							If (SD4->D4_QUANT > 0 .Or. SD4->D4_QTDEORI > 0) .And. Alltrim(_SD3RK->D3_COD) == Alltrim(SD4->D4_COD)
								/*For nX := 1 To SD4->(FCount())
									aAdd(aLine,{SD4->(Field(nX)),SD4->(FieldGet(nX)),Nil})
								Next nX
								aAdd(aLine,{"LINPOS","D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
									SD4->D4_COD,;
									SD4->D4_TRT,;
									SD4->D4_LOTECTL,;
									SD4->D4_NUMLOTE,;
									SD4->D4_LOCAL,;
									SD4->D4_OPORIG,;
									SD4->D4_SEQ})

								nX := aScan(aLine,{|x| x[1] == "D4_QUANT"})
								If nX > 0
									aLine[nX,2] := 0
								EndIf
								nX := aScan(aLine,{|x| x[1] == "D4_QTDEORI"})
								If nX > 0
									aLine[nX,2] := 0
								EndIf
								aAdd(aItens,aLine)*/
								//If SD4->D4_QUANT <= 0
								If _SD3RK->D3_QUANT == 0
									If SD4->D4_QUANT == SD4->D4_QTDEORI
										DbSelectArea("SD4")
										RecLock("SD4",.F.)
										SD4->D4_QUANT   := 0
										SD4->D4_QTDEORI := 0
										MsUnLock()
									Else
										DbSelectArea("SD4")
										RecLock("SD4",.F.)
										SD4->D4_QTDEORI -= SD4->D4_QUANT
										SD4->D4_QUANT   := 0
										MsUnLock()
									EndIf
									_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'F' "
									_cQuery += " WHERE ID = "+Alltrim(STR(_SD3RK->ID))+" "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
								Else
									If SD4->D4_QUANT == SD4->D4_QTDEORI
										DbSelectArea("SD4")
										RecLock("SD4",.F.)
										SD4->D4_QUANT   := 0
										SD4->D4_QTDEORI := 0
										MsUnLock()
									Else
										DbSelectArea("SD4")
										RecLock("SD4",.F.)
										SD4->D4_QTDEORI -= SD4->D4_QUANT
										SD4->D4_QUANT   := 0
										MsUnLock()
									EndIf
								EndIf
							endif
							dbSetOrder(2)
							SD4->(DBSKIP())
						enddo
					EndIf
					DbSelectArea("_SD3RK")
					_SD3RK->(DbSkip())
				EndDo
				DbSelectArea("_SD3RK")
				_SD3RK->(DBCloseArea())
				DbSelectArea("_SH6RK")
				If _lRet
					_cRecno := "0"
					_cRecCB := "0"
					_aCab 		:= {}
					_aItem		:= {}
					_aTotItem 	:= {}
					_cDoc 		:= NextNumero("SD3",2,"D3_DOC",.T.)
					ddatabase 	:= _SH6RK->H6_DATAINI
					aAdd(_aCab, {"D3_DOC" 			, _cDoc				,NIL})
					aAdd(_aCab, {"D3_TM" 			, "555" 			,NIL})
					aAdd(_aCab, {"D3_EMISSAO" 		, ddatabase			,NIL})

					_nx := 1
					_cQuery := " SELECT * FROM "+GetMv("FZ_INTSD3")//+GetMv("FZ_INTSD3")
					_cQuery += " WHERE D3_STATUSIMPORTACAO = 'P' "
					_cQuery += " AND D3_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
					_cQuery += " AND D3_OP = '"+_SH6RK->H6_OP+"' "
					_cQuery += " AND D3_QUANT > 0 "
					_nMes:NewAlias( _cQuery, "_SD3RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
					If _nMes:HasError()
						cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
						FWAlertWarning(cMsg)
					EndIf
					Do While !_SD3RK->(EOF())
						DbSelectArea("SBZ")
						DbSeek(xFilial("SBZ")+_SD3RK->D3_COD)
						If Found()
							If SBZ->BZ_LOCALIZ == "S"
								_lEndereco := .T.
							Else
								_lEndereco := .F.
							EndIf
						Else
							_lEndereco := .F.
						EndIF
						_cRecno := "0"
						//_cRecCB := "0"
						_aItem := {}
						_nQtdM := _SD3RK->D3_QUANT
						_nQtdT := 0
						_cQuery := " SELECT CB8.R_E_C_N_O_ AS RECNO,CB8_LCALIZ, CB8_LOTECT, CB8_QTDORI FROM CB8010 CB8"
						_cQuery += " WHERE CB8.D_E_L_E_T_ <> '*' "
						_cQuery += " AND CB8_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
						_cQuery += " AND CB8_OP = '"+_SH6RK->H6_OP+"' "
						_cQuery += " AND CB8_PROD = '"+_SD3RK->D3_COD+"' "
						_cQuery += " AND CB8_LOCAL = '"+_SD3RK->D3_LOCAL+"' "
						//_cQuery += " AND CB8.R_E_C_N_O_ NOT IN ("+_cRecCB+")"
						TCQuery ChangeQuery(_cQuery) New Alias _CB8
						If !_CB8->(EOF())
							_nQtdT := _CB8->CB8_QTDORI
						EndIf
						If _nQtdT <= _nQtdM
							DbSelectArea("_CB8")
							_CB8->(DBCloseArea())
							For _nx:=1 To 500
								If _nQtdT < _nQtdM
									_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'I' "
									_cQuery += " WHERE ID = "+Alltrim(STR(_SD3RK->ID))+" "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()

									_nQtdA := 0 //_SD3RK->D3_QUANT
									_cEnd  := " "//_SD3RK->D3_LOCALIZ
									_cLot  := " "//_SD3RK->D3_LOTECTL
									_cDat  := " "//_SD3RK->D3_DTVALID
									If Empty(_cLot)
										If _lEndereco
											_cQuery := " SELECT SBF.R_E_C_N_O_ AS RECNO, BF_LOCALIZ, BF_LOTECTL, B8_DTVALID, BF_EMPENHO, BF_QUANT, B8_SALDO FROM SBF010 SBF, SB8010 SB8"
											_cQuery += " WHERE SBF.D_E_L_E_T_ <> '*' "
											_cQuery += " AND BF_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
											_cQuery += " AND BF_PRODUTO = '"+_SD3RK->D3_COD+"' "
											_cQuery += " AND BF_LOCAL = '"+_SD3RK->D3_LOCAL+"' "
											_cQuery += " AND BF_QUANT-BF_EMPENHO >  0 "
											//_cQuery += " AND B8_SALDO >=  "+Alltrim(STR(_SD3RK->D3_QUANT))+" "
											_cQuery += " AND B8_SALDO >=  0 "
											_cQuery += " AND BF_PRODUTO = B8_PRODUTO
											_cQuery += " AND BF_LOCAL = B8_LOCAL
											_cQuery += " AND BF_FILIAL = B8_FILIAL
											_cQuery += " AND BF_LOTECTL = B8_LOTECTL
											_cQuery += " AND SBF.R_E_C_N_O_ NOT IN ("+_cRecno+")"
											_cQuery += " ORDER BY B8_DTVALID
											TCQuery ChangeQuery(_cQuery) New Alias _SBF
											If !_SBF->(EOF())
												_cEnd := _SBF->BF_LOCALIZ
												_cLot := _SBF->BF_LOTECTL
												_cDat := stod(_SBF->B8_DTVALID)
												_nQtdA:= _SBF->BF_QUANT-_SBF->BF_EMPENHO
												_cRecno += ","+Alltrim(STR(_SBF->RECNO))
											EndIf
											DbSelectArea("_SBF")
											_SBF->(DBCloseArea())
										Else
											_cQuery := " SELECT SB8.R_E_C_N_O_ AS RECNO, B8_LOTECTL, B8_DTVALID, B8_SALDO FROM SB8010 SB8"
											_cQuery += " WHERE SB8.D_E_L_E_T_ <> '*' "
											_cQuery += " AND B8_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
											_cQuery += " AND B8_PRODUTO = '"+_SD3RK->D3_COD+"' "
											_cQuery += " AND B8_LOCAL = '"+_SD3RK->D3_LOCAL+"' "
											_cQuery += " AND B8_SALDO >=  0 "
											_cQuery += " AND SB8.R_E_C_N_O_ NOT IN ("+_cRecno+")"
											_cQuery += " ORDER BY B8_DTVALID
											TCQuery ChangeQuery(_cQuery) New Alias _SBF
											If !_SBF->(EOF())
												_cLot := _SBF->B8_LOTECTL
												_cDat := stod(_SBF->B8_DTVALID)
												_nQtdA:= _SBF->B8_SALDO
												_cRecno += ","+Alltrim(STR(_SBF->RECNO))
											EndIf
											DbSelectArea("_SBF")
											_SBF->(DBCloseArea())
										EndIf
									Else
										_nQtdA := _nQtdM
									EndIf
									If Empty(_cEnd) .And. _lEndereco
										_cQuery := " SELECT SBF.R_E_C_N_O_ AS RECNO, BF_LOCALIZ, BF_LOTECTL, B8_DTVALID, BF_EMPENHO, BF_QUANT, B8_SALDO FROM SBF010 SBF, SB8010 SB8"
										_cQuery += " WHERE SBF.D_E_L_E_T_ <> '*' "
										_cQuery += " AND BF_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
										_cQuery += " AND BF_PRODUTO = '"+_SD3RK->D3_COD+"' "
										_cQuery += " AND BF_LOCAL = '"+_SD3RK->D3_LOCAL+"' "
										_cQuery += " AND BF_QUANT-BF_EMPENHO >  0 "
										//_cQuery += " AND B8_SALDO >=  "+Alltrim(STR(_SD3RK->D3_QUANT))+" "
										_cQuery += " AND B8_SALDO >=  0 "
										_cQuery += " AND B8_LOTECTL = '"+_cLot+"'"
										_cQuery += " AND BF_PRODUTO = B8_PRODUTO
										_cQuery += " AND BF_LOCAL = B8_LOCAL
										_cQuery += " AND BF_FILIAL = B8_FILIAL
										_cQuery += " AND BF_LOTECTL = B8_LOTECTL
										_cQuery += " AND SBF.R_E_C_N_O_ NOT IN ("+_cRecno+")"
										_cQuery += " ORDER BY B8_DTVALID
										TCQuery ChangeQuery(_cQuery) New Alias _SBF
										If !_SBF->(EOF())
											_cEnd := _SBF->BF_LOCALIZ
											_cDat := stod(_SBF->B8_DTVALID)
											If _nQtdA == 0
												_nQtdA:= _SBF->BF_QUANT-_SBF->BF_EMPENHO
											EndIF
											//_cRecno += ","+Alltrim(STR(_SBF->RECNO))
										EndIf
										DbSelectArea("_SBF")
										_SBF->(DBCloseArea())
									EndIf
									If Empty(_cDat)
										If _lEndereco
											_cQuery := " SELECT SBF.R_E_C_N_O_ AS RECNO, BF_LOCALIZ, BF_LOTECTL, B8_DTVALID, BF_EMPENHO, BF_QUANT, B8_SALDO FROM SBF010 SBF, SB8010 SB8"
											_cQuery += " WHERE SBF.D_E_L_E_T_ <> '*' "
											_cQuery += " AND BF_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
											_cQuery += " AND BF_PRODUTO = '"+_SD3RK->D3_COD+"' "
											_cQuery += " AND BF_LOCAL = '"+_SD3RK->D3_LOCAL+"' "
											_cQuery += " AND BF_QUANT-BF_EMPENHO >  0 "
											//_cQuery += " AND B8_SALDO >=  "+Alltrim(STR(_SD3RK->D3_QUANT))+" "
											_cQuery += " AND B8_SALDO >=  0 "
											_cQuery += " AND B8_LOTECTL = '"+_cLot+"'"
											_cQuery += " AND BF_LOCALIZ = '"+_cEnd+"'"
											_cQuery += " AND BF_PRODUTO = B8_PRODUTO
											_cQuery += " AND BF_LOCAL = B8_LOCAL
											_cQuery += " AND BF_FILIAL = B8_FILIAL
											_cQuery += " AND BF_LOTECTL = B8_LOTECTL
											_cQuery += " AND SBF.R_E_C_N_O_ NOT IN ("+_cRecno+")"
											_cQuery += " ORDER BY B8_DTVALID
											TCQuery ChangeQuery(_cQuery) New Alias _SBF
											If !_SBF->(EOF())
												_cDat := stod(_SBF->B8_DTVALID)
												//_nQtdA:= _SBF->B8_SALDO
												//_cRecno += ","+Alltrim(STR(_SBF->RECNO))
											EndIf
											DbSelectArea("_SBF")
											_SBF->(DBCloseArea())
										Else
											_cQuery := " SELECT SB8.R_E_C_N_O_ AS RECNO, B8_LOTECTL, B8_DTVALID, B8_SALDO FROM SB8010 SB8"
											_cQuery += " WHERE SB8.D_E_L_E_T_ <> '*' "
											_cQuery += " AND B8_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
											_cQuery += " AND B8_PRODUTO = '"+_SD3RK->D3_COD+"' "
											_cQuery += " AND B8_LOCAL = '"+_SD3RK->D3_LOCAL+"' "
											_cQuery += " AND B8_SALDO >=  0 "
											_cQuery += " AND SB8.R_E_C_N_O_ NOT IN ("+_cRecno+")"
											_cQuery += " ORDER BY B8_DTVALID
											TCQuery ChangeQuery(_cQuery) New Alias _SBF
											If !_SBF->(EOF())
												_cLot := _SBF->B8_LOTECTL
												_cDat := stod(_SBF->B8_DTVALID)
												_nQtdA:= _SBF->B8_SALDO
												_cRecno += ","+Alltrim(STR(_SBF->RECNO))
											EndIf
											DbSelectArea("_SBF")
											_SBF->(DBCloseArea())
										EndIf
									EndIf
									If _nQtdA > _nQtdM-_nQtdT
										_nQtdA := _nQtdM-_nQtdT
									EndIf
									_nQtdT += _nQtdA
									If ValType(_cDat) == "C"
										_cDat := ddatabase
									EndIf
									If !Empty(_cDat) .And. !Empty(_cLot) .And. (!Empty(_cEnd) .Or. !_lEndereco) .And. _nQtdA > 0
										DbSelectArea("_SD3RK")
										aAdd(_aItem,{"D3_COD"    	 	, UPPER(_SD3RK->D3_COD)	,NIL})
										aAdd(_aItem,{"D3_LOCAL"  	 	, _SD3RK->D3_LOCAL	,NIL})
										aAdd(_aItem,{"D3_OP"  	 		, _SD3RK->D3_OP	    ,NIL})
										aAdd(_aItem,{"D3_LOTECTL" 		, _cLot				,NIL})
										aAdd(_aItem,{"D3_DTVALID" 		, _cDat				,NIL})
										If _lEndereco
											aAdd(_aItem,{"D3_LOCALIZ" 		, _cEnd				,NIL})
										EndIf
										aAdd(_aItem,{"D3_QUANT"  	 	, _nQtdA			,NIL})
										aAdd(_aItem,{"D3_IDENT" 		, _SD3RK->D3_IDENT	,NIL})
										If !Empty(_SD3RK->D3_USUARIO)
											aAdd(_aItem,{"D3_USUARIO" 		, _SD3RK->D3_USUARIO,NIL})
										Else
											aAdd(_aItem,{"D3_USUARIO" 		, "MES",NIL})
										EndIf
										_aItem := FWVetByDic(_aItem, "SD3")
										aadd(_aTotItem,_aItem)
										_aItem := {}
									Else
										If Empty(_cDat) .And. Empty(_cLot) .And. (Empty(_cEnd) .Or. _lEndereco) .And. _nQtdA <= 0
											_nx := 500
											Exit
										EndIf
									EndIf
								Else
									_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'F' "
									_cQuery += " WHERE ID = "+Alltrim(STR(_SD3RK->ID))+" "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
									_nx := 500
									Exit
								EndIf
							Next
							If Len(_aTotItem) > 0 .And. _nQtdT == _nQtdM
								lMsHelpAuto := .T.
								lMSErroAuto := .F.
								lAutoErrNoFile:= .T.
								MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,_aTotItem,3)
								If lMsErroAuto
									_aItens 	:= JsonObject():New()
									cLogTxt := ""
									_cTexto := _cMes+chr(13)+chr(10)
									_cMes := ""
									nAux    := 1
									aLogAuto := GetAutoGRLog()
									For nAux := 1 To Len(aLogAuto)
										If mlcount(aLogAuto[nAux]) > 1
											_nx 	:= 1
											cLogTxt := _cMes+chr(13)+chr(10)
											_cMes := " "
											For _nx:=1 To mlcount(aLogAuto[nAux])
												cLogTxt += " "+Alltrim(MemoLine(aLogAuto[nAux], 150, _nx, 2, .f.))
											Next
										Else
											cLogTxt := aLogAuto[nAux]
										EndIf
										If !Empty(Alltrim(cLogTxt))
											_aCod 		:= JsonObject():New()
											_aCod["OBS"] 		:= Alltrim(cLogTxt)
											_aItens["OBS"+Alltrim(STR(nAux))] := _aCod
											_cTexto += Alltrim(cLogTxt)+chr(13)+chr(10)
										EndIf
									Next
									_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'E' "
									_cQuery += " WHERE D3_STATUSIMPORTACAO = 'I' "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
									_nx := 999
									//U_STTOP("/v1/OrdemProducao/StatusApontamento",_cTexto,_SH6R->H6_OP)
									
									_cQuery := " UPDATE OrdemProducao set DescricaoFalhaApontamento = '"+_cTexto+"', FalhaApontamento = 1"
									_cQuery += " WHERE Codigo = '"+_SH6RK->H6_OP+"' "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag  - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()

									Exit
								Else
									_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'F' "
									_cQuery += " WHERE D3_STATUSIMPORTACAO = 'I' "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
								EndIf
							ElseIf _nQtdT <> _nQtdM
								_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'E' "
								_cQuery += " WHERE D3_STATUSIMPORTACAO = 'I' "
								_nMes:TransBegin()
								If !_nMes:SQLExec(_cQuery)
									cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
									FWAlertWarning(cMsg)
									_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
								EndIf
								_nMes:TransEnd()
								_aCod 		:= JsonObject():New()
								_aCod["OBS"] 		:= Alltrim("Sem Saldo")
								_cTexto := "Sem Saldo"
								//U_STTOP("/v1/OrdemProducao/StatusApontamento","Sem lote/Endereco",_SH6R->H6_OP)
								_cQuery := " UPDATE OrdemProducao set DescricaoFalhaApontamento = 'Sem lote/Endereco. Produto:"+UPPER(_SD3RK->D3_COD)+"', FalhaApontamento = 1"
								_cQuery += " WHERE Codigo = '"+_SH6RK->H6_OP+"' "
								_nMes:TransBegin()
								If !_nMes:SQLExec(_cQuery)
									cMsg := "Erro ao atualizar flag  - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
									FWAlertWarning(cMsg)
									_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
								EndIf
								_nMes:TransEnd()
							EndIf
							_aTotItem := {}
							DbSelectArea("_SD3RK")
							_SD3RK->(DbSkip())
						Else
							_cQuery := " UPDATE "+GetMv("FZ_INTSD3")+" SET D3_STATUSIMPORTACAO = 'E' "
							_cQuery += " WHERE D3_COD = '"+_SD3RK->D3_COD+"' "
							_cQuery += " AND D3_OP = '"+_SH6RK->H6_OP+"' "
							_nMes:TransBegin()
							If !_nMes:SQLExec(_cQuery)
								cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
								FWAlertWarning(cMsg)
								_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
							EndIf
							_nMes:TransEnd()
							_cQuery := " UPDATE OrdemProducao set DescricaoFalhaApontamento = 'Ordem de separacao maior que a requisicao do M.E.S. Produto:"+UPPER(_SD3RK->D3_COD)+"', FalhaApontamento = 1"
							_cQuery += " WHERE Codigo = '"+_SH6RK->H6_OP+"' "
							_nMes:TransBegin()
							If !_nMes:SQLExec(_cQuery)
								cMsg := "Erro ao atualizar flag  - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
								FWAlertWarning(cMsg)
								_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
							EndIf
							_nMes:TransEnd()
							Exit
						EndIf
					EndDo
					DbSelectArea("_SD3RK")
					_SD3RK->(DBCloseArea())
					DbSelectArea("_SH6RK")

					ddatabase := Date()

					_cQuery := " SELECT H6_TEMPO, ID, H6_OP, H6_PRODUTO, H6_SEQ, H6_RECURSO, CONVERT(varchar, H6_DATAINI, 103) AS H6_DATAINI, H6_HORAINI, CONVERT(varchar, H6_DATAFIN, 103) AS H6_DATAFIN, H6_HORAFIN, H6_PT, H6_LOCAL, H6_QTDPROD FROM "+GetMv("FZ_INTSH6")
					_cQuery += " WHERE H6_STATUSIMPORTACAO IN ('E','I') "
					_cQuery += " AND H6_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
					_cQuery += " AND H6_OP = '"+_SH6RK->H6_OP+"' "
					_cQuery += " ORDER BY H6_SEQ "
					_nMes:NewAlias( _cQuery, "_SH6XRK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
					If _nMes:HasError()
						cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
						FWAlertWarning(cMsg)
					EndIf
					If _SH6XRK->(EOF())
						_cQuery := " SELECT * FROM "+GetMv("FZ_INTSD3")//+GetMv("FZ_INTSD3")
						_cQuery += " WHERE D3_STATUSIMPORTACAO IN ('E','I') "
						_cQuery += " AND D3_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
						_cQuery += " AND D3_OP = '"+_SH6RK->H6_OP+"' "
						_nMes:NewAlias( _cQuery, "_SD3RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
						If _nMes:HasError()
							cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
							FWAlertWarning(cMsg)
						EndIf
						If _SD3RK->(EOF())
							Private l240       := .f.
							Private l241       := .T.
							Private l242       := .f.
							Private l261       := .f.
							_cQuery := " SELECT H6_TEMPO, ID, H6_OP, H6_PRODUTO, H6_SEQ, H6_RECURSO, CONVERT(varchar, H6_DATAINI, 103) AS H6_DATAINI, H6_HORAINI, CONVERT(varchar, H6_DATAFIN, 103) AS H6_DATAFIN, H6_HORAFIN, H6_PT, H6_LOCAL, H6_QTDPROD FROM "+GetMv("FZ_INTSH6")
							_cQuery += " WHERE H6_STATUSIMPORTACAO = 'P' "
							_cQuery += " AND H6_FILIAL = '"+_SH6RK->H6_FILIAL+"' "
							_cQuery += " AND H6_OP = '"+_SH6RK->H6_OP+"' "
							_cQuery += " ORDER BY H6_SEQ "
							_nMes:NewAlias( _cQuery, "_SH6R" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
							If _nMes:HasError()
								cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
								FWAlertWarning(cMsg)
							EndIf
							Do While !_SH6R->(EOF())
								_nQtd := 0
								_cLoteOP := ""
								DbSelectArea("SC2")
								DbSeek(xFilial("SC2")+_SH6R->H6_OP)
								If Found()
									_nQtd := SC2->C2_QUANT
									If Empty(_cLoteOP) //.And. !Empty(SC2->C2_LOTECTL)
										_cLoteOP := _SH6R->H6_OP
									EndIf
								EndIf
								Pergunte("MTA680",.F.)
								l680:=.T.
								cTpHr	   := Nil
								cTime      :=""
								nTempoCen  :=0
								lUsaCalend := GetMV("MV_USACALE",, .T.)
								cForHora   := If(mv_par03 == 1, "N", "C")
								nZeros     := At(":", PesqPict("SH6", "H6_TEMPO")) - 1
								lApsInUse  := SuperGetMv("MV_APS",.F.,"") $ "DRUMMER*TOTVS"
								cTimeIni   := ""
								cTimeFim   := ""

								If cTpHr == Nil
									cTpHr := GetMv("MV_TPHR")
								EndIf

								cTimeIni := IIF(cForHora == "N", A680ConvHora(_SH6R->H6_HORAINI, cForHora),_SH6R->H6_HORAINI)
								cTimeFim := IIF(cForHora == "N", A680ConvHora(_SH6R->H6_HORAFIN, cForHora),_SH6R->H6_HORAFIN)
								nTempoCen := A680Tempo(ctod(_SH6R->H6_DATAINI), cTimeIni,ctod(_SH6R->H6_DATAFIN), cTimeFim )

								cTime := If(A780RetInt(nTempoCen),StrZero(nTempoCen, nZeros),StrZero(Int(nTempoCen), nZeros)) + ":" + StrZero(Mod(nTempoCen, 1) * 100, 2)
								If l680
									cTime := A680ConvHora(cTime, cTpHr, cForHora)
								Else
									cTime := A680ConvHora(cTime, "C", cForHora)
								EndIf
								aVetor := {}
								//ddatabase := ctod(_SH6R->H6_DATAFIN)
								aSH6:= {}
								AADD(aSH6, {"H6_FILIAL" , cFilAnt      									, NIL})
								AADD(aSH6, {"H6_OP"     , _SH6R->H6_OP       							, NIL})
								AADD(aSH6, {"H6_PRODUTO", _SH6R->H6_PRODUTO								, NIL})
								AADD(aSH6, {"H6_OPERAC" , _SH6R->H6_SEQ		           					, NIL})
								AADD(aSH6, {"H6_RECURSO", _SH6R->H6_RECURSO					            , NIL})
								AADD(aSH6, {"H6_DATAINI", ddatabase						, NIL})
								AADD(aSH6, {"H6_HORAINI", "10:00"								, NIL})//Left(DecTime(Time(),,05),5)
								AADD(aSH6, {"H6_DATAFIN", ddatabase						, NIL})
								AADD(aSH6, {"H6_HORAFIN", "10:05"								, NIL})//Left(Time(),5)
								AADD(aSH6, {"H6_QTDPROD", Round(_nQtd,4)								, NIL})
								AADD(aSH6, {"H6_QTDPERD", 0												, NIL})
								AADD(aSH6, {"H6_PT"  	, _SH6R->H6_PT									, NIL})
								//AADD(aSH6, {"H6_DTAPONT", ctod(_SH6R->H6_DATAFIN)						, NIL})
								AADD(aSH6, {"H6_DESDOBR", "000"											, NIL})
								AADD(aSH6, {"H6_TEMPO"  , cTime											, NIL})
								If !Empty(_cLoteOP)
									AADD(aSH6, {"H6_LOTECTL", _SH6R->H6_OP       																			, NIL})
									AADD(aSH6, {"H6_DTVALID", U__PrValid(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD, SC2->C2_PRODUTO)[2]      	, NIL})
									AADD(aSH6, {"H6_CODETI"	, _cLoteOP																						,NIL})
								EndIf
								AADD(aSH6, {"H6_TIPO" 	, "P"										, NIL})
								//AADD(aSH6, {"H6_DTPROD" , ctod(_SH6R->H6_DATAINI)					, NIL})
								AADD(aSH6, {"H6_TIPOTEM", 1											, NIL})
								AADD(aSH6, {"H6_LOCAL"  , _SH6R->H6_LOCAL							, NIL})

								Private _AbreErro := .T.
								lMSErroAuto:= .F.
								lMsHelpAuto:= .F.
								lAutoErrNoFile:= .T.

								dbselectarea ("SH6")
								RegToMemory("SH6", .T.)
								MSExecAuto({|x, y| MATA681(x, y)}, aSH6, 3)

								If lMsErroAuto
									cLogTxt := _cMes+chr(13)+chr(10)
									_cMes := " "
									nAux    := 1
									aLogAuto := GetAutoGRLog()
									For nAux := 1 To Len(aLogAuto)
										If mlcount(aLogAuto[nAux]) > 1
											_nx := 1
											For _nx:=1 To mlcount(aLogAuto[nAux])
												cLogTxt += Alltrim(MemoLine(aLogAuto[nAux], 150, _nx, 2, .f.))+chr(13)+chr(10)
											Next
										Else
											cLogTxt += aLogAuto[nAux]+chr(13)+chr(10)
										EndIf
										//cLogTxt += aLogAuto[nAux]+" &&& "
									Next
									_cQuery := " UPDATE "+GetMv("FZ_INTSH6")+" SET H6_STATUSIMPORTACAO = 'E' "
									_cQuery += " WHERE ID = "+Alltrim(STR(_SH6R->ID))+" "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
									//U_STTOP("/v1/OrdemProducao/StatusApontamento",cLogTxt,_SH6R->H6_OP)
									_cQuery := " UPDATE OrdemProducao set DescricaoFalhaApontamento = '"+cLogTxt+"', FalhaApontamento = 1"
									_cQuery += " WHERE Codigo = '"+_SH6RK->H6_OP+"' "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag  - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
								Else
									_cQuery := " UPDATE "+GetMv("FZ_INTSH6")+" SET H6_STATUSIMPORTACAO = 'F' "
									_cQuery += " WHERE ID = "+Alltrim(STR(_SH6R->ID))+" "
									_nMes:TransBegin()
									If !_nMes:SQLExec(_cQuery)
										cMsg := "Erro ao atualizar flag "+cTabela+" - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										FWAlertWarning(cMsg)
										_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
									EndIf
									_nMes:TransEnd()
								EndIf
								ddatabase := date()
								DbSelectArea("_SH6R")
								_SH6R->(DbSkip())
							EndDo
						EndIf
						DbSelectArea("_SD3RK")
						_SD3RK->(DBCloseArea())
					EndIf
					DbSelectArea("_SH6XRK")
					_SH6XRK->(DBCloseArea())
				EndIf
			EndIf
			DbSelectArea("_SD3XRK")
			_SD3XRK->(DBCloseArea())
			DbSelectArea("_SH6RK")
			_lRet 		:= .T.
			DbSelectArea("_SH6RK")
			_SH6RK->(DbSkip())
		EndDo
		DbSelectArea("_SH6RK")
		_SH6RK->(DBCloseArea())
	EndIf
Return

user function _ZERAEMP(_cOrdem,_nRec)
	Local aItens   := {}
	Local aLine    := {}
	Local nX       := 0
	Local _cOp     := ""
	Local nAux     := 0
	Local aRet     := {.F., "OP nao encontrada"}
	Local cLogTxt := ""
	PRIVATE lMsErroAuto := .F.

	RpcSetEnv('01','0101',,,"EST")

	dbSelectArea("SD4")
	dbGoTop()
	dbSetOrder(2)
	dbSeek(xFilial("SD4")+_cOrdem)
	if Found()
		do while !eof() .and.  Alltrim(_cOrdem) == Alltrim(SD4->D4_OP)
			aLine := {}
			_cOp := SD4->D4_OP
			If (SD4->D4_QUANT > 0 .Or. SD4->D4_QTDEORI > 0) .And. _nRec == SD4->(Recno())
				For nX := 1 To SD4->(FCount())
					aAdd(aLine,{SD4->(Field(nX)),SD4->(FieldGet(nX)),Nil})
				Next nX
				aAdd(aLine,{"LINPOS","D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
					SD4->D4_COD,;
					SD4->D4_TRT,;
					SD4->D4_LOTECTL,;
					SD4->D4_NUMLOTE,;
					SD4->D4_LOCAL,;
					SD4->D4_OPORIG,;
					SD4->D4_SEQ})

				nX := aScan(aLine,{|x| x[1] == "D4_QUANT"})
				If nX > 0
					aLine[nX,2] := 0
				EndIf
				nX := aScan(aLine,{|x| x[1] == "D4_QTDEORI"})
				If nX > 0
					aLine[nX,2] := 0
				EndIf
				aAdd(aItens,aLine)
			endif
			dbSetOrder(2)
			SD4->(DBSKIP())
			_nRecno := SD4->(RECNO())
			dbSetOrder(2)
			SD4->(DBGoTo(_nRecno))
		enddo
		if len(aItens) > 0
			aCab := {{"D4_OP",_cOp,NIL},;
				{"INDEX",2,Nil}}
			_cMen := " "
			MSExecAuto({|x,y,z| mata381(x,y,z)}, aCab, aItens, 4)
			If lMsErroAuto
				//MostraErro()
				_lErro2 := .T.
				aLogAuto := GetAutoGRLog()
				For nAux := 1 To Len(aLogAuto)
					cLogTxt += aLogAuto[nAux]+" &&& "
				Next
				aRet[1] := .F.
				aRet[2] := Iif(ValType(cLogTxt)=="C",cLogTxt,"")
			Else
				aRet[1] := .T.
				aRet[2] := "Empenhos ajustados com sucesso!"
			EndIf
			aItens := {}
			aLine  := {}
		endif
	endif
	RpcClearEnv()
return(aRet)

User Function _conectar(_lProd)
	Local _aArea	:= GetArea()
	Default _lAuto := .T.
	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SX6"

	Private _cErros := ""
	Private _cMail 	:= GetMv("FZ_MAILRKM")+";mario.zimmermann@gmail.com"

	//_nProd := FWDBAccess():New( "oracle/protheus", "10.100.8.187", 7890 )
	If _lProd
		_nProd := FWDBAccess():New( "oracle/protheus", "10.100.8.187", 7890 )
		_nProd:SetConsoleError(.T.)  //Habilita exibição dos erros no console do Protheus
		If !_nProd:OpenConnection()
			If _lAuto
				_cErros += "Não foi possivel conectar ao Banco SQL"+chr(13)+chr(10)
			Else
				_cErros += "Não foi possivel conectar ao Banco SQL"+chr(13)+chr(10)
				msgbox("Não foi possivel conectar ao Banco SQL","ERROR","ERROR")
			EndIf
			RETURN(.F.)
		EndIf
	EndIf
	_nMes := FWDBAccess():New( GetMv("FZ_SERVSQL"), GetMv("FZ_IPSQL"), GetMv("FZ_PORTSQL") )
	_nMes:SetConsoleError(.T.)  //Habilita exibição dos erros no console do Protheus
	If !_nMes:OpenConnection()
		If _lAuto
			_cErros += "Não foi possivel conectar ao Banco SQL"+chr(13)+chr(10)
		Else
			_cErros += "Não foi possivel conectar ao Banco SQL"+chr(13)+chr(10)
			msgbox("Não foi possivel conectar ao Banco SQL","ERROR","ERROR")
		EndIf
		RETURN(.F.)
	EndIf
	RestArea(_aArea)
Return(.T.)

User Function _PrValid(_cOp, _cProd)
	Local _nDias 	:= 0
	Local _dDtValid := dDataBase
	_nDias    := fBuscaCpo("SB1",1,xFilial("SB1")+_cProd,"B1_PRVALID")
	_dDtValid := dDataBase + _nDias
Return({_nDias,_dDtValid})

User Function INTRKMES(_OP,_nQual,_lReint)
	Local _nx 			:=1
	Private _nProtheus
	Private _nMes
	Private _lAuto		:= .F.
	Private _lRet 		:= .F.
	DEFAULT _nQual 		:= "2"
	DEFAULT _lReint 	:= .F.
	DEFAULT _lMes 		:= .F.
	If _nQual == "1"
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SM0","SX5", "SX6", "SX7","SB1","SB2", "SB8","SC2", "SD3", "SD4", "SD5", "SF5"
	EndIf
	If _lMes
		Return()
	EndIf
	If cFilAnt <> '0101'
		Return()
	EndIf 
	_lRet := U__conectar(.F.)
	If _lRet .And. !Empty(_OP)
		_cQuery := " DELETE FROM "+GetMv("FZ_INTSD4")
		_cQuery += " WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
		_cQuery += " AND D4_OP = '"+Alltrim(_OP)+"' "
		_nMes:TransBegin()
		If !_nMes:SQLExec(_cQuery)
			cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
			FWAlertWarning(cMsg)
			_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
		EndIf
		_nMes:TransEnd()
		_cQuery := " SELECT * FROM "+RetSqlName("SD4")+" SD4 "
		_cQuery += " WHERE SD4.D_E_L_E_T_ <> '*'
		_cQuery += " AND SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
		_cQuery += " AND SUBSTR(SD4.D4_OP,1,6) = '"+Left(_OP,6)+"'
		TCQuery ChangeQuery(_cQuery) New Alias _qry2
		_qry2->(dbgotop())
		Do While !_qry2->(eof())
			_cQuery := " SELECT * FROM "+RetSqlName("SB1")+" SB1 "
			_cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
			_cQuery += " AND SB1.B1_COD = '"+_qry2->D4_COD+"' "
			TCQuery ChangeQuery(_cQuery) New Alias _SB1
			_SB1->(dbgotop())
			_cUM := ""
			If !_SB1->(eof())
				_cUM := _SB1->B1_UM
			EndIF
			_SB1->(DBCloseArea())
			_cQuery := " SELECT * FROM "+GetMv("FZ_INTSD4")//Int_SBM_Grupo"
			_cQuery += " WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
			_cQuery += " AND D4_COD = '"+Alltrim(_qry2->D4_COD)+"' "
			_cQuery += " AND D4_LOCAL = '"+Alltrim(_qry2->D4_LOCAL)+"' "
			_cQuery += " AND D4_OP = '"+Alltrim(_qry2->D4_OP)+"' "
			_cQuery += " AND D4_TRT = '"+Alltrim(_qry2->D4_TRT)+"' "
			_cQuery += " AND D4_LOTECTL = '"+Alltrim(_qry2->D4_LOTECTL)+"' "
			_nMes:NewAlias( _cQuery, "_SD4RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
			If _nMes:HasError()
				cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
				cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nMes:SqlError() ) ) + "]"
				_lSegue := .F.
				FWAlertWarning(cMsg)
			Else
				DbSelectArea("_qry2")
				_cOper := _qry2->D4_OPERAC
				If Empty(_cOper)
					_cQuery := " SELECT MAX(G2_OPERAC) AS MAX FROM "+RetSqlName("SG2")+" SG2 "
					_cQuery += " WHERE SG2.D_E_L_E_T_ <> '*'
					_cQuery += " AND SG2.G2_FILIAL = '"+xFilial("SG2")+"' "
					_cQuery += " AND G2_PRODUTO = '"+Alltrim(_qry2->D4_PRODUTO)+"' "
					_cQuery += " AND G2_CODIGO = '"+Alltrim(_qry2->D4_ROTEIRO)+"' "
					TCQuery ChangeQuery(_cQuery) New Alias _qry3
					_qry3->(dbgotop())
					If !_qry3->(eof())
						_cOper := _qry3->MAX
					EndIf
					_qry3->(DbCloseArea())
				EndIf
				_cQuery := " INSERT INTO "+GetMv("FZ_INTSD4") //Int_SD4_Empenho"
				_cQuery += " (D4_FILIAL, D4_COD, D4_LOCAL, D4_OP, D4_DATA, D4_QSUSP, D4_SITUACA, D4_QTDEORI, D4_QUANT, D4_TRT, D4_LOTECTL, D4_DTVALID, D4_OPORIG, "
				_cQuery += " D4_SEQ, D4_SLDEMP, D4_CBTM, D4_PRODUTO, D4_ROTEIRO, D4_OPERAC, D4_UM) "
				_cQuery += " VALUES ('"+xFilial("SD4")+"', '"+_qry2->D4_COD+"', '"+_qry2->D4_LOCAL+"', '"+_qry2->D4_OP+"', '"+_qry2->D4_DATA+"', "+Alltrim(STR(_qry2->D4_QSUSP))+", '"+_qry2->D4_SITUACA+"', "+Alltrim(STR(_qry2->D4_QTDEORI))+", "+Alltrim(STR(_qry2->D4_QUANT))+", '"+_qry2->D4_TRT+"', '"+_qry2->D4_LOTECTL+"', '"+_qry2->D4_DTVALID+"', '"+_qry2->D4_OPORIG+"', "
				_cQuery += " '"+_qry2->D4_SEQ+"', "+Alltrim(STR(_qry2->D4_SLDEMP))+", '"+_qry2->D4_CBTM+"', '"+_qry2->D4_PRODUTO+"', '"+_qry2->D4_ROTEIRO+"', '"+_cOper+"', '"+_cUM+"') "
				_nMes:TransBegin()
				If !_nMes:SQLExec(_cQuery)
					cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
					FWAlertWarning(cMsg)
					_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
				EndIf
				_nMes:TransEnd()
			EndIf
			_SD4RK->(DBCloseArea())
			_qry2->(dbskip())
		Enddo
		_qry2->(DBCloseArea())
		_cQuery := " SELECT * FROM "+RetSqlName("SC2")+" SC2 "
		_cQuery += " WHERE SC2.D_E_L_E_T_ <> '*' "
		_cQuery += " AND C2_FILIAL = '"+xFilial("SC2")+"' "
		_cQuery += " AND C2_NUM = '"+Left(_OP,6)+"' "
		TCQuery ChangeQuery(_cQuery) New Alias _SC2
		_SC2->(dbgotop())
		Do While !_SC2->(EOF())
			_cGrupo := ""
			_cTipo  := ""
			_cLinha := ""
			_cQuery := " SELECT * FROM "+RetSqlName("SB1")+" SB1 "
			_cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
			_cQuery += " AND SB1.B1_COD = '"+_SC2->C2_PRODUTO+"' "
			TCQuery ChangeQuery(_cQuery) New Alias _SB1
			_SB1->(dbgotop())
			If !_SB1->(EOF())
				_cGrupo := _SB1->B1_GRUPO
				_cTipo  := _SB1->B1_TIPO
				_cLinha := _SB1->B1_LINHA
				If !Empty(_cGrupo)
					_cQuery := " SELECT * FROM "+RetSqlName("SBM")+" SBM "
					_cQuery += " WHERE SBM.D_E_L_E_T_ <> '*' "
					_cQuery += " AND SBM.BM_GRUPO = '"+_cGrupo+"' "
					TCQuery ChangeQuery(_cQuery) New Alias _SBM
					_SBM->(dbgotop())
					If !_SBM->(EOF())
						_cQuery := " SELECT * FROM "+GetMv("FZ_INTSBM") //Int_SBM_Grupo"
						_cQuery += " WHERE BM_FILIAL = '"+_SBM->BM_FILIAL+"' "
						_cQuery += " AND BM_GRUPO = '"+_SBM->BM_GRUPO+"' "
						_nMes:NewAlias( _cQuery, "_SBMRK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
						If _nMes:HasError()
							cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
							cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nMes:SqlError() ) ) + "]"
							_lSegue := .F.
							FWAlertWarning(cMsg)
						Else
							If _SBMRK->(eof())
								_cQuery := " INSERT INTO "+GetMv("FZ_INTSBM") //Int_SBM_Grupo"
								_cQuery += " (BM_FILIAL, BM_GRUPO, BM_DESC) "
								_cQuery += " VALUES ('"+_SBM->BM_FILIAL+"','"+_SBM->BM_GRUPO+"','"+_SBM->BM_DESC+"') "
								_nMes:TransBegin()
								If !_nMes:SQLExec(_cQuery)
									cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
									FWAlertWarning(cMsg)
									_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
								EndIf
								_nMes:TransEnd()
							EndIf
						EndIf
						_SBMRK->(DBCloseArea())
					EndIf
					_SBM->(DBCloseArea())
					DbSelectArea("SG2")
				EndIf
			EndIf
			_SB1->(DBCloseArea())
			_cQuery := " SELECT * FROM "+GetMv("FZ_INTSC2") //Int_SC2_OrdemProducao"
			_cQuery += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
			_cQuery += " AND C2_NUM = '"+Left(_OP,6)+"' "
			_cQuery += " AND C2_ITEM = '"+_SC2->C2_ITEM+"' "
			_cQuery += " AND C2_SEQUEN = '"+_SC2->C2_SEQUEN+"' "
			_nMes:NewAlias( _cQuery, "_SC2RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
			If _nMes:HasError()
				cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
				cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nMes:SqlError() ) ) + "]"
				FWAlertWarning(cMsg)
				_lSegue := .F.
			EndIf
			If _SC2RK->(eof())
				_nx := 1
				_ny := 1
				_cQuery := " SELECT SG2.R_E_C_N_O_ AS RECNO, SG2.* FROM "+RetSqlName("SG2")+" SG2 "
				_cQuery += " WHERE SG2.D_E_L_E_T_ <> '*' "
				_cQuery += " AND G2_FILIAL = '"+_SC2->C2_FILIAL+"' "
				_cQuery += " AND G2_PRODUTO = '"+_SC2->C2_PRODUTO+"' "
				_cQuery += " AND G2_CODIGO = '"+_SC2->C2_ROTEIRO+"' "
				TCQuery ChangeQuery(_cQuery) New Alias _SG2
				_SG2->(dbgotop())
				Do While !_SG2->(EOF())
					If _ny == 1
						_ny := 2
						_cQuery := " DELETE FROM "+GetMv("FZ_INTSG2")
						_cQuery += " WHERE G2_FILIAL = '"+_SG2->G2_FILIAL+"' "
						_cQuery += " AND G2_PRODUTO = '"+Alltrim(_SG2->G2_PRODUTO)+"' "
						_cQuery += " AND G2_CODIGO = '"+Alltrim(_SG2->G2_CODIGO)+"' "
						_nMes:TransBegin()
						If !_nMes:SQLExec(_cQuery)
							cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
							_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
						EndIf
						_nMes:TransEnd()
					EndIf
					DbSelectArea("SG2")
					DbGoTo(_SG2->RECNO)
					_cMemo := ""
					_nx := 1
					For _nx:=1 To mlcount(SG2->G2_KOBS)
						_cMemo += MemoLine(SG2->G2_KOBS, 150, _nx, 2, .f.)
					Next
					_cQuery := " INSERT INTO "+GetMv("FZ_INTSG2") //Int_SG2_Recurso
					_cQuery += " (G2_FILIAL, G2_CODIGO, G2_PRODUTO, G2_OPERAC, G2_OPERACMES, G2_RECURSO, G2_LINHAPR, G2_DESCRI, G2_SETUP, G2_FORMSTP, G2_TEMPAD, G2_LOCAL, G2_KOBS, G2_ETAPA) "
					_cQuery += " VALUES ('"+xFilial("SG2")+"', '"+_SG2->G2_CODIGO+"', '"+_SG2->G2_PRODUTO+"', '"+_SG2->G2_OPERAC+"', '"+_SG2->G2_OPERMES+"', '"+_SG2->G2_RECURSO+"', '"+_SG2->G2_LINHAPR+"', '"+_SG2->G2_DESCRI+"', '"+Alltrim(STR(_SG2->G2_SETUP))+"', '"+_SG2->G2_FORMSTP+"', '"+Alltrim(STR(_SG2->G2_TEMPAD))+"', '', '"+_cMemo+"', "+Alltrim(Str(_SG2->G2_ETAPA))+")"
					_nMes:TransBegin()
					If !_nMes:SQLExec(_cQuery)
						cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
						FWAlertWarning(cMsg)
						_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
					EndIf
					_nMes:TransEnd()
					DbSelectArea("_SG2")
					_SG2->(DbSkip())
				EndDo
				_SG2->(DBCloseArea())
				DbSelectArea("SBZ")
				DbSeek(xFilial("SBZ")+_SC2->C2_PRODUTO)
				If Found()
					_BZPE := SBz->BZ_PE
				EndIf
				DbSelectArea("_SC2")
				_cQuery := " INSERT INTO "+GetMv("FZ_INTSC2") //Int_SC2_OrdemProducao"
				_cQuery += " (C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_LOCAL, C2_QUANT, C2_UM, C2_DATPRI, C2_DATPRF, C2_OBS, C2_EMISSAO, C2_PRIOR, C2_STATUS,
				_cQuery += " C2_ROTEIRO, C2_TPOP, C2_OP, C2_ORDSEP, C2_IDAPS, C2_StatusCancelamento, C2_StatusImportacao, C2_B1GRUPO, C2_REVISAO, C2_BZPE, C2_B1TIPO, C2_B1LINHA) "
				_cQuery += " VALUES ('"+xFilial("SC2")+"', '"+Left(_OP,6)+"', '"+_SC2->C2_ITEM+"', '"+_SC2->C2_SEQUEN+"', '"+_SC2->C2_PRODUTO+"', '"+_SC2->C2_LOCAL+"', "+Alltrim(STR(_SC2->C2_QUANT))+", '"+_SC2->C2_UM+"', '"+_SC2->C2_DATPRI+"', '"+_SC2->C2_DATPRF+"', '"+_SC2->C2_OBS+"', '"+_SC2->C2_EMISSAO+"', '"+_SC2->C2_PRIOR+"', '"+_SC2->C2_STATUS+"', "
				_cQuery += " '"+_SC2->C2_ROTEIRO+"', '"+_SC2->C2_TPOP+"', '"+_OP+"', '"+_SC2->C2_ORDSEP+"', '"+_SC2->C2_IDAPS+"', '', '0','"+_cGrupo+"','"+_SC2->C2_REVISAO+"', "+Alltrim(Str(_BZPE))+",'"+_cTipo+"', '"+_cLinha+"') "
				_nMes:TransBegin()
				If !_nMes:SQLExec(_cQuery)
					cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
					FWAlertWarning(cMsg)
					_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
				EndIf
				_nMes:TransEnd()
			EndIf
			_SC2RK->(DBCloseArea())
			DbSelectArea("SG2")
			DbSelectArea("_SC2")
			U_REINOP("/v1/OrdemProducao/ReintegrarOP","codigoOP="+Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD))
			DbSelectArea("_SC2")
			_SC2->(DbSkip())
		EndDo
		_SC2->(DBCloseArea())
		DbSelectArea("SC2")
		_nMes:CloseConnection()
		_nMes:Finish()
	Else
		FWAlertWarning("Erro ao integrar a OP")
	EndIf
Return
/*
User Function MEIABOCA(_OP,_nQual)
	Local _nx 			:=1
	Private _nProtheus
	Private _nMes
	Private _nProd
	Private _lAuto		:= .F.
	Private _lRet 		:= .F.
	DEFAULT _nQual 		:= "2"
	If _nQual == "1"
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SM0","SX5", "SX6", "SX7","SB1","SB2", "SB8","SC2", "SD3", "SD4", "SD5", "SF5"
	EndIf
	DbSelectArea("SC2")
	DbSetOrder(1)
	DbSeek(xFilial("SC2")+Alltrim(cOp))
	If Found()
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)
		If Found()
			//If (SB1->B1_LINHA $ GetMv("FZ_INTLIN"))
			DbSelectArea("SBZ")
			DbSetOrder(1)
			DbSeek(xFilial("SBZ")+SB1->B1_COD)
			If Found()
				DbSelectArea("ZKP")
				DbSetOrder(1)
				DbSeek(xFilial("ZKP")+SBZ->BZ_KPLANEJ)
				If Found() .And. ZKP->ZKP_MES<>"S"
					Return()
				EndIf
			EndIf
			//Else
			//	_lRet := .F.
			//EndIf
		EndIf
	EndIf
	_nOpProd := FWInputBox("OP MIGRA: "+Alltrim(_OP)+" Op de producao?", Alltrim(_nOpProd))
	_lRet := U__conectar(.T.)
	If _lRet .And. !Empty(_OP) .And. !Empty(_nOpProd)
		_cQuery := " SELECT * FROM "+RetSqlName("SD4")+" SD4 "
		_cQuery += " WHERE SD4.D_E_L_E_T_ <> '*'
		_cQuery += " AND SD4.D4_OP = '"+_nOpProd+"'
		_nProd:NewAlias( _cQuery, "_qry2" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
		If _nProd:HasError()
			cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nProd:ErrorMessage() ) + "]"
			cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nProd:SqlError() ) ) + "]"
			_lSegue := .F.
			FWAlertWarning(cMsg)
		Else
			_qry2->(dbgotop())
			Do While !_qry2->(eof())
				_cQuery := " SELECT * FROM "+RetSqlName("SB1")+" SB1 "
				_cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
				_cQuery += " AND SB1.B1_COD = '"+_qry2->D4_COD+"' "
				_nProd:NewAlias( _cQuery, "_SB1" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
				If _nProd:HasError()
					cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nProd:ErrorMessage() ) + "]"
					cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nProd:SqlError() ) ) + "]"
					_lSegue := .F.
					FWAlertWarning(cMsg)
				Else
					_SB1->(dbgotop())
					_cUM := ""
					If !_SB1->(eof())
						_cUM := _SB1->B1_UM
					EndIF
					_SB1->(DBCloseArea())
					DbSelectArea("_qry2")
					_cQuery := " INSERT INTO "+GetMv("FZ_INTSD4") //Int_SD4_Empenho"
					_cQuery += " (D4_FILIAL, D4_COD, D4_LOCAL, D4_OP, D4_DATA, D4_QSUSP, D4_SITUACA, D4_QTDEORI, D4_QUANT, D4_TRT, D4_LOTECTL, D4_DTVALID, D4_OPORIG, "
					_cQuery += " D4_SEQ, D4_SLDEMP, D4_CBTM, D4_PRODUTO, D4_ROTEIRO, D4_OPERAC, D4_UM) "
					_cQuery += " VALUES ('"+xFilial("SD4")+"', '"+_qry2->D4_COD+"', '"+_qry2->D4_LOCAL+"', '"+_OP+"', '"+_qry2->D4_DATA+"', "+Alltrim(STR(_qry2->D4_QSUSP))+", '"+_qry2->D4_SITUACA+"', "+Alltrim(STR(_qry2->D4_QTDEORI))+", "+Alltrim(STR(_qry2->D4_QUANT))+", '"+_qry2->D4_TRT+"', '"+_qry2->D4_LOTECTL+"', '"+_qry2->D4_DTVALID+"', '"+_qry2->D4_OPORIG+"', "
					_cQuery += " '"+_qry2->D4_SEQ+"', "+Alltrim(STR(_qry2->D4_SLDEMP))+", '"+_qry2->D4_CBTM+"', '"+_qry2->D4_PRODUTO+"', '"+_qry2->D4_ROTEIRO+"', '"+_qry2->D4_OPERAC+"', '"+_cUM+"') "
					_nMes:TransBegin()
					If !_nMes:SQLExec(_cQuery)
						cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
						FWAlertWarning(cMsg)
						_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
					EndIf
					_nMes:TransEnd()
				EndIf
				_qry2->(dbskip())
			Enddo
			_qry2->(DBCloseArea())
		EndIf
		_cQuery := " SELECT * FROM "+RetSqlName("SC2")+" SC2 "
		_cQuery += " WHERE SC2.D_E_L_E_T_ <> '*' "
		_cQuery += " AND C2_NUM = '"+Left(_nOpProd,6)+"' "
		_nProd:NewAlias( _cQuery, "_SC2" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
		If _nProd:HasError()
			cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nProd:ErrorMessage() ) + "]"
			cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nProd:SqlError() ) ) + "]"
			_lSegue := .F.
			FWAlertWarning(cMsg)
		Else
			_SC2->(dbgotop())
			Do While !_SC2->(EOF())
				_cGrupo := ""
				_cTipo  := ""
				_cLinha := ""
				_cQuery := " SELECT * FROM "+RetSqlName("SB1")+" SB1 "
				_cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
				_cQuery += " AND SB1.B1_COD = '"+_SC2->C2_PRODUTO+"' "
				_nProd:NewAlias( _cQuery, "_SB1" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
				If _nProd:HasError()
					cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nProd:ErrorMessage() ) + "]"
					cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nProd:SqlError() ) ) + "]"
					_lSegue := .F.
					FWAlertWarning(cMsg)
				Else
					_SB1->(dbgotop())
					If !_SB1->(EOF())
						_cGrupo := _SB1->B1_GRUPO
						_cTipo  := _SB1->B1_TIPO
						_cLinha := _SB1->B1_LINHA
						If !Empty(_cGrupo)
							_cQuery := " SELECT * FROM "+RetSqlName("SBM")+" SBM "
							_cQuery += " WHERE SBM.D_E_L_E_T_ <> '*' "
							_cQuery += " AND SBM.BM_GRUPO = '"+_cGrupo+"' "
							_nProd:NewAlias( _cQuery, "_SBM" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
							If _nProd:HasError()
								cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nProd:ErrorMessage() ) + "]"
								cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nProd:SqlError() ) ) + "]"
								_lSegue := .F.
								FWAlertWarning(cMsg)
							Else
								_SBM->(dbgotop())
								If !_SBM->(EOF())
									_cQuery := " SELECT * FROM "+GetMv("FZ_INTSBM") //Int_SBM_Grupo"
									_cQuery += " WHERE BM_FILIAL = '"+_SBM->BM_FILIAL+"' "
									_cQuery += " AND BM_GRUPO = '"+_SBM->BM_GRUPO+"' "
									_nMes:NewAlias( _cQuery, "_SBMRK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
									If _nMes:HasError()
										cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
										cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nMes:SqlError() ) ) + "]"
										_lSegue := .F.
										FWAlertWarning(cMsg)
									Else
										If _SBMRK->(eof())
											_cQuery := " INSERT INTO "+GetMv("FZ_INTSBM") //Int_SBM_Grupo"
											_cQuery += " (BM_FILIAL, BM_GRUPO, BM_DESC) "
											_cQuery += " VALUES ('"+_SBM->BM_FILIAL+"','"+_SBM->BM_GRUPO+"','"+_SBM->BM_DESC+"') "
											_nMes:TransBegin()
											If !_nMes:SQLExec(_cQuery)
												cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
												FWAlertWarning(cMsg)
												_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
											EndIf
											_nMes:TransEnd()
										EndIf
									EndIf
									_SBMRK->(DBCloseArea())
								EndIf
								DbSelectArea("SG2")
							EndIf
						EndIf
					EndIf
				EndIf
				_cQuery := " SELECT * FROM "+GetMv("FZ_INTSC2") //Int_SC2_OrdemProducao"
				_cQuery += " WHERE C2_NUM = '"+Left(_OP,6)+"' "
				_cQuery += " AND C2_ITEM = '"+_SC2->C2_ITEM+"' "
				_cQuery += " AND C2_SEQUEN = '"+_SC2->C2_SEQUEN+"' "
				_nMes:NewAlias( _cQuery, "_SC2RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
				If _nMes:HasError()
					cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
					cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nMes:SqlError() ) ) + "]"
					FWAlertWarning(cMsg)
					_lSegue := .F.
				EndIf
				If _SC2RK->(eof())
					_cQuery := " SELECT * FROM "+RetSqlName("SG2")+" SG2 "
					_cQuery += " WHERE SG2.D_E_L_E_T_ <> '*' "
					_cQuery += " AND G2_PRODUTO = '"+_SC2->C2_PRODUTO+"' "
					_cQuery += " AND G2_OPERAC = '"+_SC2->C2_ROTEIRO+"' "
					_nProd:NewAlias( _cQuery, "_SG2" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
					If _nProd:HasError()
						cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nProd:ErrorMessage() ) + "]"
						cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nProd:SqlError() ) ) + "]"
						_lSegue := .F.
						FWAlertWarning(cMsg)
					Else
						_SG2->(dbgotop())
						Do While !_SG2->(EOF())
							_cQuery := " SELECT * FROM "+GetMv("FZ_INTSG2") //Int_SG2_Recurso
							_cQuery += " WHERE G2_FILIAL = '"+_SG2->G2_FILIAL+"' "
							_cQuery += " AND G2_PRODUTO = '"+_SG2->G2_PRODUTO+"' "
							_cQuery += " AND G2_OPERAC = '"+_SG2->G2_OPERAC+"' "
							_cQuery += " AND G2_OPERACMES = '"+_SG2->G2_OPERMES+"' "
							_cQuery += " AND G2_RECURSO = '"+_SG2->G2_RECURSO+"' "
							_nMes:NewAlias( _cQuery, "_SG2RK" )  	//Cria uma Alias de trabalho temporaria baseado em uma query na conexão remota do objeto
							If _nMes:HasError()
								cMsg := "Erro na selecao dos dados - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
								cMsg1 := "Erro na selecao dos dados - Erro: [" + AllTrim( Str( _nMes:SqlError() ) ) + "]"
								FWAlertWarning(cMsg)
								_lSegue := .F.
							EndIf
							If _SG2RK->(eof())
								DbSelectArea("SG2")
								_cMemo := ""
								For _nx:=1 To mlcount(_SG2->G2_KOBS)
									_cMemo += MemoLine(_SG2->G2_KOBS, 150, _nx, 2, .f.)
								Next
								_cQuery := " INSERT INTO "+GetMv("FZ_INTSG2") //Int_SG2_Recurso
								_cQuery += " (G2_FILIAL, G2_CODIGO, G2_PRODUTO, G2_OPERAC, G2_OPERACMES, G2_RECURSO, G2_LINHAPR, G2_DESCRI, G2_SETUP, G2_FORMSTP, G2_TEMPAD, G2_LOCAL, G2_KOBS, G2_ETAPA) "
								_cQuery += " VALUES ('"+xFilial("SG2")+"', '"+_SG2->G2_CODIGO+"', '"+_SG2->G2_PRODUTO+"', '"+_SG2->G2_OPERAC+"', '"+_SG2->G2_OPERMES+"', '"+_SG2->G2_RECURSO+"', '"+_SG2->G2_LINHAPR+"', '"+_SG2->G2_DESCRI+"', '"+Alltrim(STR(_SG2->G2_SETUP))+"', '"+_SG2->G2_FORMSTP+"', '"+Alltrim(STR(_SG2->G2_TEMPAD))+"', '', '"+_cMemo+"', "+Alltrim(Str(_SG2->G2_ETAPA))+")"
								_nMes:TransBegin()
								If !_nMes:SQLExec(_cQuery)
									cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
									FWAlertWarning(cMsg)
									_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
								EndIf
								_nMes:TransEnd()
							EndIf
							_SG2RK->(DBCloseArea())
							DbSelectArea("SG2")
							SG2->(DbSkip())
						EndDo
					EndIf
					DbSelectArea("SBZ")
					DbSeek(xFilial("SBZ")+_SC2->C2_PRODUTO)
					If Found()
						_BZPE := SBz->BZ_PE
					EndIf
					DbSelectArea("_SC2")
					_cQuery := " INSERT INTO "+GetMv("FZ_INTSC2") //Int_SC2_OrdemProducao"
					_cQuery += " (C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_LOCAL, C2_QUANT, C2_UM, C2_DATPRI, C2_DATPRF, C2_OBS, C2_EMISSAO, C2_PRIOR, C2_STATUS,
					_cQuery += " C2_ROTEIRO, C2_TPOP, C2_OP, C2_ORDSEP, C2_IDAPS, C2_StatusCancelamento, C2_StatusImportacao, C2_B1GRUPO, C2_REVISAO, C2_BZPE, C2_B1TIPO, C2_B1LINHA) "
					_cQuery += " VALUES ('"+xFilial("SC2")+"', '"+Left(_OP,6)+"', '"+_SC2->C2_ITEM+"', '"+_SC2->C2_SEQUEN+"', '"+_SC2->C2_PRODUTO+"', '"+_SC2->C2_LOCAL+"', "+Alltrim(STR(_SC2->C2_QUANT))+", '"+_SC2->C2_UM+"', '"+_SC2->C2_DATPRI+"', '"+_SC2->C2_DATPRF+"', '"+_SC2->C2_OBS+"', '"+_SC2->C2_EMISSAO+"', '"+_SC2->C2_PRIOR+"', '"+_SC2->C2_STATUS+"', "
					_cQuery += " '"+_SC2->C2_ROTEIRO+"', '"+_SC2->C2_TPOP+"', '"+_OP+"', '"+_SC2->C2_ORDSEP+"', '"+_SC2->C2_IDAPS+"', '', '0','"+_cGrupo+"','"+_SC2->C2_REVISAO+"', "+Alltrim(Str(_BZPE))+",'"+_cTipo+"', '"+_cLinha+"') "
					_nMes:TransBegin()
					If !_nMes:SQLExec(_cQuery)
						cMsg := "Erro ao atualizar - Erro: [" + AllTrim( _nMes:ErrorMessage() ) + "]"
						FWAlertWarning(cMsg)
						_nMes:TransDisarm() // Faz o Disarm Transaction ( Rollback ) na base externa
					EndIf
					_nMes:TransEnd()
				EndIf
				_SC2RK->(DBCloseArea())
				DbSelectArea("SG2")
				DbSelectArea("_SC2")
				_SC2->(DbSkip())
			EndDo
		EndIf
		DbSelectArea("SC2")
		_nMes:CloseConnection()
		_nMes:Finish()
		_nProd:CloseConnection()
		_nProd:Finish()
	EndIf
Return
*/
User Function REIMPBAS()

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SM0","SX5", "SX6", "SX7","SB1","SB2", "SB8","SC2", "SD3", "SD4", "SD5", "SF5"

	aAreaSC2    := SC2->(GetArea())
	cAliasExi   := GetNextAlias()
	cQuery	  := " SELECT C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD AS OP FROM "+RetSqlName('SC2')+" SC2 "
	cQuery	  += " WHERE SC2.D_E_L_E_T_ <> '*' "
	cQuery	  += " AND C2_TPOP = 'F' "
	cQuery	  += " AND C2_DATRF = ' ' "
	cQuery	  += " AND C2_FILIAL = '"+xFilial("SC2")+"' "
	cQuery	  += " AND CASE WHEN C2_SEQUEN = '001' THEN 1 ELSE CASE WHEN C2_PRODUTO LIKE '%KFE%' THEN 1 ELSE 0 END END = 1 "
	cQuery	  += " AND (TO_CHAR(SYSDATE, 'YYYYMMDD')-C2_DATPRI) < CASE WHEN C2_DIASOCI = 0 THEN 1 ELSE C2_DIASOCI END "
	cQuery	  += " AND NOT EXISTS (SELECT D3_OP FROM "+RetSqlName('SD3')+" SD3 WHERE SD3.D_E_L_E_T_ <> '*' AND D3_FILIAL = C2_FILIAL AND D3_OP = C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD AND D3_ESTORNO = ' ') "
	cQuery	  += " AND NOT EXISTS (SELECT H6_OP FROM "+RetSqlName('SH6')+" SH6 WHERE SH6.D_E_L_E_T_ <> '*' AND H6_FILIAL = C2_FILIAL AND H6_OP = C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD) "
	cQuery	  += " GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD "
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasExi, .F., .T.)
	Do While !(cAliasExi)->(Eof())
		U_INTRKMES((cAliasExi)->OP,"2")
		(cAliasExi)->(DbSkip())
	EndDo
	(cAliasExi)->(DbCloseArea())
	RestArea(aAreaSC2)
Return
