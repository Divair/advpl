//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas
#Define COL_GRUPO   0015
#Define COL_DESCR   0095
 
/*/{Protheus.doc} zTstRel
Exemplos de FWMSPrinter
@author Atilio
@since 27/01/2019
@version 1.0
@type function
/*/
 
User Function zTstRel()
    Local aArea  := GetArea()
    Private lJob := .F.
     
    //Chamado pelo Schedule
    If Select("SX2") == 0
        //Preparando o ambiente
        lJob := .T.
        RPCSetType(3)
        RPCSetEnv("01", "01", "", "", "")
    EndIf
     
    //Se for execução automática, não mostra pergunta, executa direto
    If lJob
        Processa({|| fMontaRel()}, "Processando...")
         
    //Senão, se a pergunta for confirmada, executa o relatório
    Else
        If MsgYesNo("Deseja gerar o relatório de grupos de produtos?", "Atenção")
            Processa({|| fMontaRel()}, "Processando...")
        EndIf
    EndIf
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função que monta o relatório                                 |
 *---------------------------------------------------------------------*/
 
Static Function fMontaRel()
    Local cCaminho    := ""
    Local cArquivo    := ""
    Local cQryAux     := ""
    Local nAtual      := 0
    Local nTotal      := 0
    //Variáveis para disparo de e-Mail
    Local cPara    := ""
    Local cAssunto := ""
    Local cCorpo   := ""
    Local aAnexos  := {}
    //Linhas e colunas
    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2
    //Objeto de Impressão
    Private oPrintPvt
    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nPagAtu   := 1
    Private cNomeUsr  := UsrRetName(RetCodUsr())
    //Fontes
    Private cNomeFont := "Arial"
    Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
     
    //Se for via JOB, muda as parametrizações
    If lJob
        //Define o caminho dentro da protheus data e o nome do arquivo
        cCaminho := "\x_relatorios\"
        cArquivo := "zTstRel_job_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-') + ".pdf"
         
        //Se não existir a pasta na Protheus Data, cria ela
        If ! ExistDir(cCaminho)
            MakeDir(cCaminho)
        EndIf
         
        //Cria o objeto FWMSPrinter
        oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., '', .T., .F., , , .T., .T., , .F.)
        oPrintPvt:cPathPDF := cCaminho
         
    Else
        //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
        cCaminho  := GetTempPath()
        cArquivo  := "zTstRel_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
         
        //Criando o objeto do FMSPrinter
        oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
    EndIf
     
    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
     
    //Imprime o cabeçalho
    fImpCab()
     
    //Montando a consulta
    cQryAux := " SELECT "                                       + CRLF
    cQryAux += "     BM_GRUPO, "                                + CRLF
    cQryAux += "     BM_DESC "                                  + CRLF
    cQryAux += " FROM "                                         + CRLF
    cQryAux += "     " + RetSQLName('SBM') + " SBM "            + CRLF
    cQryAux += " WHERE "                                        + CRLF
    cQryAux += "     BM_FILIAL = '" + FWxFilial('SBM') + "' "   + CRLF
    cQryAux += "     AND SBM.D_E_L_E_T_ = ' ' "                 + CRLF
    cQryAux += " ORDER BY "                                     + CRLF
    cQryAux += "     BM_GRUPO "                                 + CRLF
    TCQuery cQryAux New Alias "QRY_SBM"
     
    //Conta o total de registros, seta o tamanho da régua, e volta pro topo
    Count To nTotal
    ProcRegua(nTotal)
    QRY_SBM->(DbGoTop())
    nAtual := 0
     
    //Enquanto houver registros
    While ! QRY_SBM->(EoF())
        nAtual++
        IncProc("Imprimindo grupo " + QRY_SBM->BM_GRUPO + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
         
        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        If nLinAtu + nTamLin > nLinFin
            fImpRod()
            fImpCab()
        EndIf
         
        //Imprimindo a linha atual
        oPrintPvt:SayAlign(nLinAtu, COL_GRUPO, QRY_SBM->BM_GRUPO, oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_DESCR, QRY_SBM->BM_DESC,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
        nLinAtu += nTamLin
         
        QRY_SBM->(DbSkip())
    EndDo
    QRY_SBM->(DbCloseArea())
     
    //Se ainda tiver linhas sobrando na página, imprime o rodapé final
    If nLinAtu <= nLinFin
        fImpRod()
    EndIf
     
    //Se for via job, imprime o arquivo para gerar corretamente o pdf
    If lJob
        oPrintPvt:Print()
         
        //Atenção! - é necessário baixar a função zEnvMail() - disponível em https://terminaldeinformacao.com/2017/10/17/funcao-dispara-e-mail-varios-anexos-em-advpl/
        cPara    := "teste@teste.com"
        cAssunto := "Assunto Teste"
        cCorpo   := "Corpo do e-Mail Teste"
        aAdd(aAnexos, cCaminho + cArquivo)
        u_zEnvMail(cPara, cAssunto, cCorpo, aAnexos)
         
    //Se for via manual, mostra o relatório
    Else
        oPrintPvt:Preview()
    EndIf
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab()
    Local cTexto   := ""
    Local nLinCab  := 030
     
    //Iniciando Página
    oPrintPvt:StartPage()
     
    //Cabeçalho
    cTexto := "Relação de Grupos de Produtos"
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cTexto, oFontTit, 240, 20, COR_CINZA, PAD_CENTER, 0)
     
    //Linha Separatória
    nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, COR_CINZA)
     
    //Cabeçalho das colunas
    nLinCab += nTamLin
    oPrintPvt:SayAlign(nLinCab, COL_GRUPO, "Grupo",     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, COL_DESCR, "Descrição", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
    nLinCab += nTamLin
     
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + 3
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
 *---------------------------------------------------------------------*/
 
Static Function fImpRod()
    Local nLinRod   := nLinFin + nTamLin
    Local cTextoEsq := ''
    Local cTextoDir := ''
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
    nLinRod += 3
     
    //Dados da Esquerda e Direita
    cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " + FunName() + "    " + cNomeUsr
    cTextoDir := "Página " + cValToChar(nPagAtu)
     
    //Imprimindo os textos
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)
     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return
