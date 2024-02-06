#include 'protheus.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

User Function dFIN07MK()

    Local aColsBrw := {}
    Local aColsSX3       := {}
    Local aSeeks         := {}
    local _lcont         := .t.
    Private aCampos      := {}
    Private aCpoData     := {}
    Private oTable       := Nil
    Private oMarkBrow    := Nil
    private cCadastro    :="Titulos em negociação"
    private cMarca       := "FG"
    private cperg        :=  padr("NEGTIT",len(SX1->X1_GRUPO)," ")
    Private cAliasBrw    := GetNextAlias()
    Private aCpoInfo     := {}
    private _cData       := ddatabase
    //tela total do dialos
    Private aSize := MsAdvSize(.F.)
    Private nJanLarg := aSize[5]
    Private nJanAltu := aSize[6]

    ValidPerg()

    if  cModulo <> "FIN"
        Pergunte(cPerg,.f.)
        _lcont:= vTela()
        mv_par01:=  SM0->M0_CODFIL
        mv_par02:=  SM0->M0_CODFIL
        mv_par03:=  _cData
    else
        _lcont := Pergunte(cPerg,.T.)
    endif

    if _lcont

        FWMsgRun(, {|oSay| CriaTemp( oSay ) }, 'Criando arquivo temporario', 'Aguarde...' )

        FWMsgRun(, {|oSay| BrwQuery( oSay ) }, 'Consultando dados', 'Aguarde...' )


        AAdd(aColsBrw,{'Filial', "TMP_FILIAL"  ,'C',20,0,,1,,.F.,,,,,,,,1})

        BuscarSX3('A1_COD'  ,,aColsSX3)
        AAdd(aColsBrw,{'Cliente', "TMP_CLIENT"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('A1_LOJA'  ,,aColsSX3)
        AAdd(aColsBrw,{'Loja', "TMP_LOJA"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('A1_NOME'  ,,aColsSX3)
        AAdd(aColsBrw,{'Nome', "TMP_NOMCLI"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_PREFIXO'  ,,aColsSX3)
        AAdd(aColsBrw,{'Prefixo', "TMP_PREFIX"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_NUM'  ,,aColsSX3)
        AAdd(aColsBrw,{'Numero', "TMP_NUMERO"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_PARCELA'  ,,aColsSX3)
        AAdd(aColsBrw,{'Parcela', "TMP_PARCEL"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_EMISSAO'  ,,aColsSX3)
        AAdd(aColsBrw,{'Emissao', "TMP_EMISSA"  ,'D',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_VENCREAL'  ,,aColsSX3)
        AAdd(aColsBrw,{'Vencimento', "TMP_VENCIM"  ,'D',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_SALDO'  ,,aColsSX3)
        AAdd(aColsBrw,{'Valor', "TMP_VALOR"  ,'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('A1_SITCLI'  ,,aColsSX3)
        AAdd(aColsBrw,{'Situação', "TMP_SITUAC"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('A3_NOME'  ,,aColsSX3)
        AAdd(aColsBrw,{'Vendedor', "TMP_VENDED"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('A1_HISTFIN'  ,,aColsSX3)
        AAdd(aColsBrw,{'Historico', "TMP_HISTOR"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        BuscarSX3('E1_TIPO'  ,,aColsSX3)
        AAdd(aColsBrw,{'Tipo', "TMP_TIPO"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})

        //d:= 11

        AAdd(aSeeks, {'Filial',{{'',aColsBrw[1][3],aColsBrw[1][4],aColsBrw[1][5],aColsBrw[1][1],Nil}}})

        /*  AAdd(aSeeks, {'Cliente + Loja',{{'',aColsBrw[2][3],aColsBrw[2][4],aColsBrw[2][5],aColsBrw[2][1],Nil},;
                {'',aColsBrw[3][3],aColsBrw[3][4],aColsBrw[3][5],aColsBrw[3][1],Nil} }})*/

        AAdd(aSeeks, {'Cliente + Loja',{{'',aColsBrw[2][3],aColsBrw[2][4],aColsBrw[2][5],aColsBrw[2][1], Nil}}})

        AAdd(aSeeks, {'Vendedor',{{'',aColsBrw[12][3],aColsBrw[12][4],aColsBrw[12][5],aColsBrw[12][1],Nil}}})

        //Campos que irão compor o combo de pesquisa na tela principal
	    //Aadd(aSeek,{"ID"   , {{"","C",06,0, "TR_ID"   ,"@!"}}, 1, .T. } )
	    //Aadd(aSeek,{"Login", {{"","C",20,0, "TR_LOGIN","@!"}}, 2, .T. } )
	    //Aadd(aSeek,{"Nome" , {{"","C",50,0, "TR_NOME" ,"@!"}}, 3, .T. } )

        	//Faz o calculo automatico de dimensoes de objetos
        oSize := FwDefSize():New(.T.)
        oSize:lLateral := .F.
        oSize:lProp	:= .T. // Proporcional
        oSize:AddObject( "BROWSE" ,75 ,100 ,.T. ,.T. ) // Totalmente dimensionavel
        oSize:Process() // Dispara os calculos
        aPosDialog:={oSize:aWindSize[1]*0.75,oSize:aWindSize[2]*0.75,oSize:aWindSize[3]*0.75,oSize:aWindSize[4]*0.75}
        aPosPanel := aPosDialog


 
 //       DEFINE MSDIALOG oDlgSelect TITLE 'cTitle' FROM aPosDialog[1],aPosDialog[2] TO aPosDialog[3],aPosDialog[4] Of oMainWnd   PIXEL
        DEFINE MSDIALOG oDlgSelect TITLE 'cTitle' FROM 0, 0 TO nJanAltu, nJanLarg  Of oMainWnd   PIXEL

    	oPanel := TPanel():New(aPosPanel[1],aPosPanel[2],'',oDlgSelect,, .T., .T.,, ,aPosPanel[3],aPosPanel[4])
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT

        //usando o FWMarkBrowse sem alinhar com o dialogo ()
        //oPanel := TPanel():New(aPosPanel[1],30,'',oDlgSelect,, .T., .T.,, ,aPosPanel[3],aPosPanel[4])
	    //oPanel:Align := CONTROL_ALIGN_ALLCLIENT


        oBrowse:= FWMarkBrowse():New()
        oBrowse:SetOwner(oPanel)
        oBrowse:SetDescription('Títulos para Cobrança')
        oBrowse:SetMenuDef("dFIN07MK")
        oBrowse:SetFields(aColsBrw)
        oBrowse:SetSeek(.T.,aSeeks)
        oBrowse:SetTemporary(.T.)
        oBrowse:SetAlias(cAliasBrw)
        if  cModulo == "FIN"
        oBrowse:SetFieldMark("TMP_OK")
        oBrowse:SetMark(cMarca,cAliasBrw,"TMP_OK")
        endif
        //oBrowse:SetValid({||!Empty((cAliasBrw)->TP_PRODUTO)})
        oBrowse:SetAllMark({||BrwAllMark()})
        //oBrowse:SetAfterMark({||Iif(oBrowse:IsMark(),nContTMP++,nContTMP--)})
        oBrowse:SetWalkThru(.F.)
        oBrowse:SetAmbiente(.F.)
        oBrowse:SetUseFilter(.T.)
        //oBrowse:SetParam({|| RecarSel()})
        //oBrowse:SetAfterMark({|| u_evf50vld() })
        oBrowse:Activate()

        oBrowse:oBrowse:SetFocus() //Seta o foco na grade
        ACTIVATE MSDIALOG oDlgSelect CENTERED

        If cModulo == "FIN"
            FWMsgRun(, {|oSay| feditData( oSay ) }, 'Atualizando registros', 'Aguarde...' )
        EndIf

        delTabTmp(cAliasBrw)
    endif
return

Static Function MenuDef
    Local aRotina := {}

    Add Option aRotina Title 'Sair'     Action 'oDlgSelect:end()'              Operation 3 Access 0
        //Add Option aRotina Title 'Marcar Todos'     Action 'U_FINA07MD(.T.)'        Operation 6 Access 0
    //Add Option aRotina Title 'Desmarcar Todos'    Action 'U_FINA07MD(.F.)'     Operation 8 Access 0
return(aRotina)

Static Function BrwQuery()
    local _cQuery:= ""
    Local cAliasQry := ""

    _cQuery:=" SELECT E1_FILORIG,E1_TITNEG,A1_COD, A1_LOJA, A1_NOME,A1_LIBCLI, A1_SITCLI, (CASE WHEN A1_MAILCOB = '' THEN A1_EMAIL ELSE A1_MAILCOB END) AS A1_MAILCOB, "
    _cQuery+=" A1_LC,A1_DTALINA,A1_CLASSE,A1_ULTCOM,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCREA, (E1_SALDO-E1_IRRF-E1_INSS-E1_PIS-E1_COFINS-E1_CSLL) AS E1_SALDO, "
    _cQuery+=" E1_SITUACA,E1_SITUAC2,E1_VEND1, A3_NOME, "
    _cQuery+=" (CONVERT(INT, CAST('"+dtos(mv_par03)+"' AS DATETIME), 3) - CONVERT(INT, CAST(E1_VENCREA AS DATETIME), 3)) AS E1_DIAS, "
    _cQuery+=" CONVERT(VARCHAR(500), CONVERT(VARBINARY(500), A1_HISTFIN)) AS A1_HISTFIN "
    _cQuery+=" FROM SA1010 AS SA1 "
    _cQuery+=" INNER JOIN SE1010 AS SE1 ON E1_FILIAL = '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND SE1.D_E_L_E_T_ = '' AND E1_TIPO IN ('NF','DP') "
    _cQuery+=" AND E1_PORTADO NOT IN ('BCC','BCD') AND E1_SITUACA NOT IN ('D','E') AND E1_FLUXO <> 'N' AND (E1_PORT2 NOT IN ('DIN') OR E1_EMISSAO <= '"+dtos(mv_par03-10)+"') "
    _cQuery+=" AND E1_NUMBCO = '' AND E1_PREFIXO NOT IN ('CHQ','CHD','SE0') "
    _cQuery+=" AND (CONVERT(INT, CAST('"+dtos(mv_par03)+"' AS DATETIME), 3) - CONVERT(INT, CAST(E1_EMISSAO AS DATETIME), 3)) <= 120 "
    _cQuery+=" AND E1_EMISSAO < '"+dtos(mv_par03-2)+"' AND E1_FILORIG BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'  AND A1_TIPSEG NOT IN ('11102','11103') "
    _cQuery+=" AND E1_SALDO > 0 "
    _cQuery+=" INNER JOIN SA3010 AS SA3 ON A3_COD = E1_VEND1  AND SA3.D_E_L_E_T_ = '' "
    _cQuery+=" WHERE SA1.D_E_L_E_T_ = ''  AND A1_FBACERT NOT IN ('1')  AND A1_TIPSEG <> ''  AND A1_TIPSEG NOT IN ('11101','11102','11103') "
    _cQuery+=" ORDER BY E1_FILORIG, A1_NOME, A1_COD, A1_LOJA, E1_EMISSAO, E1_NUM"

    _cQuery := ChangeQuery(_cQuery)
    cAliasQry := GetNextAlias()
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),cAliasQry,.F.,.T.)

    While !(cAliasQry)->(Eof())
        RecLock(cAliasBrw,.T.)

        If cModulo == "FIN"
            if Alltrim((cAliasQry)->E1_TITNEG) <> ""
                (cAliasBrw)->TMP_OK := cMarca
            else
                (cAliasBrw)->TMP_OK := (cAliasQry)->E1_TITNEG
            endif
        EndIf

        (cAliasBrw)->TMP_FILIAL  := u_VF_NOMEFIL(SM0->M0_CODIGO+(cAliasQry)->E1_FILORIG)
        (cAliasBrw)->TMP_CLIENT  := (cAliasQry)->A1_COD
        (cAliasBrw)->TMP_LOJA    := (cAliasQry)->A1_LOJA
        (cAliasBrw)->TMP_NOMCLI  := (cAliasQry)->A1_NOME
        (cAliasBrw)->TMP_PREFIX  := (cAliasQry)->E1_PREFIXO
        (cAliasBrw)->TMP_NUMERO  := (cAliasQry)->E1_NUM
        (cAliasBrw)->TMP_PARCEL  := (cAliasQry)->E1_PARCELA
        (cAliasBrw)->TMP_EMISSA  := stod((cAliasQry)->E1_EMISSAO)
        (cAliasBrw)->TMP_VENCIM  := stod((cAliasQry)->E1_VENCREAL)
        (cAliasBrw)->TMP_VALOR   := (cAliasQry)->E1_SALDO
        (cAliasBrw)->TMP_SITUAC  := (cAliasQry)->A1_SITCLI
        (cAliasBrw)->TMP_VENDED  := (cAliasQry)->A3_NOME
        (cAliasBrw)->TMP_HISTOR  := (cAliasQry)->A1_HISTFIN
        (cAliasBrw)->TMP_TIPO    := (cAliasQry)->E1_TIPO
        MsUnlock(cAliasBrw)
        (cAliasQry)->(DbSkip())
    EndDo


return


Static Function CriaTemp()

    Local aColsBrw  := {}
    local aIndex := {}

	if  cModulo == "FIN"
    aAdd(aColsBrw, {'TMP_OK'        , TamSx3('E1_TITNEG')[3]    , TamSx3('E1_TITNEG')[1]    , TamSx3('E1_TITNEG')[2]})
    endif
    aAdd(aColsBrw, {'TMP_FILIAL'    , "C"                       , 20                        , 0})
    aAdd(aColsBrw, {'TMP_CLIENT'    , TamSx3('A1_COD')[3]       , TamSx3('A1_COD')[1]       , TamSx3('A1_COD')[2]})
    aAdd(aColsBrw, {'TMP_LOJA'      , TamSx3('A1_LOJA')[3]      , TamSx3('A1_LOJA')[1]      , TamSx3('A1_LOJA')[2]})
    aAdd(aColsBrw, {'TMP_NOMCLI'    , TamSx3('A1_NOME')[3]      , TamSx3('A1_NOME')[1]      , TamSx3('A1_NOME')[2] })
    aAdd(aColsBrw, {'TMP_PREFIX'    , TamSx3('E1_PREFIXO')[3]   , TamSx3('E1_PREFIXO')[1]   , TamSx3('E1_PREFIXO')[2]})
    aAdd(aColsBrw, {'TMP_NUMERO'    , TamSx3('E1_NUM')[3]       , TamSx3('E1_NUM')[1]       , TamSx3('E1_NUM')[2]})
    aAdd(aColsBrw, {'TMP_PARCEL'    , TamSx3('E1_PARCELA')[3]   , TamSx3('E1_PARCELA')[1]   , TamSx3('E1_PARCELA')[2]})
    aAdd(aColsBrw, {'TMP_EMISSA'    , TamSx3('E1_EMISSAO')[3]   , TamSx3('E1_EMISSAO')[1]   , TamSx3('E1_EMISSAO')[2]})
    aAdd(aColsBrw, {'TMP_VENCIM'    , TamSx3('E1_VENCREAL')[3]  , TamSx3('E1_VENCREAL')[1]  , TamSx3('E1_VENCREAL')[2]})
    aAdd(aColsBrw, {'TMP_VALOR'     , TamSx3('E1_SALDO')[3]     , TamSx3('E1_SALDO')[1]     , TamSx3('E1_SALDO')[2]})
    aAdd(aColsBrw, {'TMP_SITUAC'    , TamSx3('A1_SITCLI')[3]    , TamSx3('A1_SITCLI')[1]    , TamSx3('A1_SITCLI')[2]})
    aAdd(aColsBrw, {'TMP_VENDED'    , TamSx3('A3_NOME')[3]      , TamSx3('A3_NOME')[1]      , TamSx3('A3_NOME')[2]})
    aAdd(aColsBrw, {'TMP_HISTOR'    , TamSx3('A1_HISTFIN')[3]   , TamSx3('A1_HISTFIN')[1]   , TamSx3('A1_HISTFIN')[2] })
    aAdd(aColsBrw, {'TMP_TIPO'      , TamSx3('E1_TIPO')[3]      , TamSx3('E1_TIPO')[1]      , TamSx3('E1_TIPO')[2]})

    // Cria tabelas temporárias

    oTable := FWTemporaryTable():New(cAliasBrw)
    oTable:SetFields(aColsBrw)

    aIndex	:=	{'TMP_FILIAL'}
    oTable:AddIndex("01", aIndex)

    aIndex	:=	{'TMP_CLIENT','TMP_LOJA'}
    oTable:AddIndex("02", aIndex)

    aIndex	:=	{"TMP_VENDED"}
    oTable:AddIndex("03", aIndex)

    oTable:Create()

    //criaTTmp(aColsBrw,{'TMP_FILIAL+TMP_CLIENT+TMP_LOJA'},cAliasBrw,oTable)


Return .T.



static Function criaTTmp(aStrField,aIndexTab,cAliasTab,oTempTable)
Local aCampos    := {}
Local nI         := 1
Local nJ         := 1

Default cAliasTab  := GetNextAlias() // Obtem o alias para a tabela temporária
	oTempTable := FWTemporaryTable():New(cAliasTab, aStrField)
	For nI := 1 To Len(aIndexTab)
		aCampos := StrTokArr( StrTran(aIndexTab[nI]," ",""), "+" )
		// Remove funções Advpl dos índices (forma antiga)
		For nJ := 1 To Len(aCampos)
			If At('(',aCampos[nJ]) > 0
				aCampos[nJ] := AllTrim(SubStr(aCampos[nJ],At('(',aCampos[nJ]) + 1 , Rat(')',aCampos[nJ]) - At('(',aCampos[nJ]) - 1))
			EndIf
		Next nJ
		oTempTable:AddIndex("IND"+cValToChar(nI), aCampos)
	Next nI
	oTempTable:Create()
Return cAliasTab


Static Function ValidPerg()
    local i,j
    cAlias := Alias()
    aRegs  :={}

    AADD(aRegs,{cPerg,"01","Filial De          ?","Filial De          ?","Filial De          ?","mv_chi","C",02,0,0,"G","                            ","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})
    AADD(aRegs,{cPerg,"02","Filial Ate         ?","Filial Ate         ?","Filial Ate         ?","mv_chj","C",02,0,0,"G","                            ","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})
    AADD(aRegs,{cPerg,"03","Data Referencia    ?","Data Referencia    ?","Data Referencia    ?","mv_chc","D",08,0,0,"G","                            ","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})

    DBSelectArea("SX1")
    DbSetOrder(1)
    For i:=1 To Len(aRegs)
        if !DbSeek(cPerg+aRegs[i,2])
            RecLock("SX1",.T.)
            For j:=1 To FCount()
                if j<=Len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                endif
            Next
            MsUnlock()
        Endif
    Next
    DbSelectArea(cAlias)
Return


static function feditData(oSay)


    DbSelectArea(cAliasBrw)
    (cAliasBrw)->(DbGoTop())

    While !(cAliasBrw)->(EoF())
        dbSelectArea("SE1")
        dbSetOrder(1)
        dbSeek(xFilial("SE1")+(cAliasBrw)->TMP_PREFIX + (cAliasBrw)->TMP_NUMERO + (cAliasBrw)->TMP_PARCEL + (cAliasBrw)->TMP_TIPO ,.F.)

        If Found()
            oSay:cCaption := 'Atualizando ' + (cAliasBrw)->TMP_PREFIX +' '+ (cAliasBrw)->TMP_NUMERO +' '+ (cAliasBrw)->TMP_PARCEL +' '+ (cAliasBrw)->TMP_TIPO
            ProcessMessages()
            RecLock('SE1', .F.)
            if  Alltrim((cAliasBrw)->TMP_OK)  <> ""
                E1_TITNEG := cMarca
            else
                E1_TITNEG := space(2)
            endif
            MsUnLock()
        EndIf

        DbSelectArea(cAliasBrw)
        dbskip()
    EndDo


    If(Type('oTable') <> 'U')

        oTable:Delete()
        oTable := Nil

    Endif


return



static function vTela()

local _cConf := "0"
local lret := .t.

DEFINE MSDIALOG oDlg FROM 0,0 TO 150,180 PIXEL TITLE "Parametros"

@  05, 005 say "Data referencia" of oDlg pixel

@  25, 005 GET _cData  PICTURE "@!" VALID .T.  SIZE 40,09 of oDlg pixel

@ 45,05 BUTTON "Confirmar" Size 30,10 OF oDlg PIXEL ACTION {||_cConf:= "1", oDlg:End()}
@ 45,45 BUTTON "Cancelar"    Size 30,10 OF oDlg PIXEL ACTION {||_cConf:= "0", oDlg:End()}

ACTIVATE MSDIALOG oDlg CENTERED


if _cConf == "0"
lret:=.f.
endif

RETURN lret
