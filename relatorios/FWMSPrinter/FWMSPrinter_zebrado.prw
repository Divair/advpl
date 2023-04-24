//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)
 
/*/{Protheus.doc} zZebra
Listagem de produtos, com cor de fundo alterada (zebrada)
@author Atilio
@since 03/06/2021
@version 1.0
@type function
/*/
 
User Function zZebra()
    Local aPergs   := {}
    Private cProdDe := Space(TamSX3("B1_COD")[1])
    Private cProdAt := StrTran(cProdDe, " ", "Z")
 
    //Monta os parâmetros da tela
    aAdd(aPergs, {1, "Produto De",     cProdDe,  "@!",                  ".T.", "SB1", ".T.", 90,   .F.})
    aAdd(aPergs, {1, "Produto Até",    cProdAt,  "@!",                  ".T.", "SB1", ".T.", 90,   .T.})
     
    //Se a pergunta for confirmada
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
        cProdDe := MV_PAR01
        cProdAt := MV_PAR02
        Processa({|| fImprime()})
    EndIf
Return
 
/*/{Protheus.doc} fImprime
Funcao que gera o PDF Automaticamente
@author Atilio
@since 03/06/2021
@version 1.0
/*/
 
Static Function fImprime()
    Local aArea        := GetArea()
    Local nTotAux      := 0
    Local nAtuAux      := 0
    Local cQryAux
    Local cArquivo   := "zZebra_"+RetCodUsr()+"_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".pdf"
    Private oPrintPvt
    Private oBrushAzul     := TBRUSH():New(,nCorAzul)
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 580
    Private nColIni    := 010
    Private nColFin    := 815
    Private nEspCol    := (nColFin-(nColIni+150))/13
    Private nColMeio   := (nColFin-nColIni)/2
    //Colunas dos relatorio
    Private nColProd    := nColIni
    Private nColDesc    := nColIni + 050
    Private nColUnid    := nColFin - 425
    Private nColTipo    := nColFin - 340
    Private nColBarr    := nColFin - 200
    //Declarando as fontes
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
     
    //Monta a consulta de dados
    cQryAux := ""
    cQryAux += " SELECT " + CRLF
    cQryAux += "     B1_COD, " + CRLF
    cQryAux += "     B1_DESC, " + CRLF
    cQryAux += "     B1_UM, " + CRLF
    cQryAux += "     B1_TIPO, " + CRLF
    cQryAux += "     B1_CODBAR " + CRLF
    cQryAux += " FROM " + CRLF
    cQryAux += "     " + RetSQLName("SB1") + " SB1 " + CRLF
    cQryAux += " WHERE " + CRLF
    cQryAux += "     B1_FILIAL = '" + FWxFilial("SB1") + "' " + CRLF
    cQryAux += "     AND B1_MSBLQL != '1' " + CRLF
    cQryAux += "     AND B1_COD >= '" + cProdDe + "' " + CRLF
    cQryAux += "     AND B1_COD <= '" + cProdAt + "' " + CRLF
    cQryAux += "     AND SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQryAux += " ORDER BY " + CRLF
    cQryAux += "     B1_COD " + CRLF
    TCQuery cQryAux New Alias "QRY_AUX"
 
    //Define o tamanho da régua
    Count to nTotAux
    ProcRegua(nTotAux)
    QRY_AUX->(DbGoTop())
     
    //Somente se tiver dados
    If ! QRY_AUX->(EoF())
        //Criando o objeto de impressao
        oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetLandscape()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
 
        //Imprime os dados
        fImpCab()
        While ! QRY_AUX->(EoF())
            nAtuAux++
            IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")
 
            //Se atingiu o limite, quebra de pagina
            fQuebra()
             
            //Faz o zebrado ao fundo
            If nAtuAux % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
            EndIf
 
            //Imprime a linha atual
            oPrintPvt:SayAlign(nLinAtu, nColProd,   QRY_AUX->B1_COD,       oFontDet,  (nColDesc - nColProd),    10, , PAD_LEFT,  )
            oPrintPvt:SayAlign(nLinAtu, nColDesc,   QRY_AUX->B1_DESC,      oFontDet,  (nColUnid - nColDesc),    10, , PAD_LEFT,  )
            oPrintPvt:SayAlign(nLinAtu, nColUnid,   QRY_AUX->B1_UM,        oFontDet,  (nColTipo - nColUnid),    10, , PAD_LEFT,  )
            oPrintPvt:SayAlign(nLinAtu, nColTipo,   QRY_AUX->B1_TIPO,      oFontDet,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
            oPrintPvt:SayAlign(nLinAtu, nColBarr,   QRY_AUX->B1_CODBAR,    oFontDet,  (nColFin  - nColBarr),    10, , PAD_LEFT,  )
 
            nLinAtu += 15
            oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)
 
            //Se atingiu o limite, quebra de pagina
            fQuebra()
             
            QRY_AUX->(DbSkip())
        EndDo
        fImpRod()
         
        oPrintPvt:Preview()
    Else
        MsgStop("Não foi encontrado informações com os parâmetros informados!", "Atenção")
    EndIf
    QRY_AUX->(DbCloseArea())
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Funcao que imprime o cabecalho                               |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab()
    Local cTexto   := ""
    Local nLinCab  := 015
     
    //Iniciando Pagina
    oPrintPvt:StartPage()
     
    //Cabecalho
    cTexto := "Listagem de Produtos"
    oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
    oPrintPvt:SayAlign(nLinCab - 03, nColFin-300, "De: "  + cProdDe, oFontDetN,  300, 20, , PAD_RIGHT, )
    oPrintPvt:SayAlign(nLinCab + 07, nColFin-300, "Até: " + cProdAt, oFontDetN,  300, 20, , PAD_RIGHT, )
     
    //Linha Separatoria
    nLinCab += 020
    oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
     
    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinCab + 5
 
    oPrintPvt:SayAlign(nLinAtu+00, nColProd,   "Código",     oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColProd,   "Produto",    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+05, nColDesc,   "Descrição",  oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nColUnid,   "Unidade de", oFontMin,  (nColTipo - nColUnid),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColUnid,   "Medida",     oFontMin,  (nColTipo - nColUnid),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+05, nColTipo,   "Tipo",       oFontMin,  (nColBarr - nColTipo),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nColBarr,   "Código de",  oFontMin,  (nColFin  - nColBarr),   10, nCorCinza, PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColBarr,   "Barras",     oFontMin,  (nColFin  - nColBarr),   10, nCorCinza, PAD_LEFT,  )
    nLinAtu += 25
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Funcao que imprime o rodape                                  |
 *---------------------------------------------------------------------*/
 
Static Function fImpRod()
    Local nLinRod:= nLinFin
    Local cTexto := ''
 
    //Linha Separatoria
    oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (zZebra)     " + UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
     
    //Direita
    cTexto := "Pagina "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
     
    //Finalizando a pagina e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return
 
Static Function fQuebra()
    If nLinAtu >= nLinFin-10
        fImpRod()
        fImpCab()
    EndIf
Return
