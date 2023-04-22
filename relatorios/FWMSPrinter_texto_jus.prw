//Bibliotecas
#Include "TopConn.ch"
#Include "Protheus.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3 //Opção disponível somente a partir da versão 1.6.2 da TOTVS Printer
 
/*/{Protheus.doc} zTstJust
Exemplo de Texto Justificado em FWMSPrinter
@author Atilio
@since 21/11/2020
@version 1.0
@type function
@see https://tdn.totvs.com/display/public/PROT/FWMsPrinter
/*/
 
User Function zTstJust()
    Local aArea        := GetArea()
    Local cArquivo     := "zTstJust_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".pdf"
    Local cTexto       := fCriaTexto()
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 800
    Private nColIni    := 010
    Private nColFin    := 580
    Private nEspCol    := (nColFin-(nColIni+150))/13
    Private nColMeio   := (nColFin-nColIni)/2
    //Objetos de impressão e fonte
    Private oPrintPvt
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
     
    //Criando o objeto de impressao
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(0, 0, 0, 0)
    oPrintPvt:StartPage()
 
    //Primeiramente iremos imprimir o texto alinhado a esquerda
    nLinAtu := 30
    oPrintPvt:SayAlign(nLinAtu, nColIni, "Texto (Esquerda):",            oFontDetN,  (nColFin - nColIni),    015, , PAD_LEFT,  )
    nLinAtu += 15
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto,                         oFontDet,   (nColFin - nColIni),    300, , PAD_LEFT,  )
 
    //Agora iremos imprimir o texto com alinhamento justificado
    nLinAtu += 300
    oPrintPvt:SayAlign(nLinAtu, nColIni, "Texto (Justificado):",         oFontDetN,  (nColFin - nColIni),    015, , PAD_JUSTIFY,  )
    nLinAtu += 15
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto,                         oFontDet,   (nColFin - nColIni),    300, , PAD_JUSTIFY,  )
 
    //Encerrando a impressão e exibindo o pdf
    oPrintPvt:EndPage()
    oPrintPvt:Preview()
     
    RestArea(aArea)
Return
 
Static Function fCriaTexto()
    Local cTexto := ""
 
    cTexto += "O Terminal de Informação (Projeto ‘Ti’), foi criado para compartilhar ideias e informações com outros usuários, tratando de diversos assuntos, como sistemas operacionais (OpenSUSE, Windows e outras distros Linux), projetos da Mozilla, Desenvolvimento (Java, C / C++ e AdvPL), tutoriais, análises e dicas de aplicativos e produtos, dentre outros assuntos." + CRLF
    cTexto += "" + CRLF
    cTexto += "Tudo começou em 2012 (dia 08/08/2012 para ser mais preciso), e desde então o projeto não parou mais de crescer, recebendo sempre feedbacks positivos de toda a comunidade." + CRLF
    cTexto += "" + CRLF
    cTexto += "Em 2016 foi feita uma grande mudança para hospedagem própria, muita coisa no Terminal mudou, e cada vez mais focando em artigos de qualidade para os usuários." + CRLF
    cTexto += "" + CRLF
    cTexto += "Só tenho a agradecer aos amigos e aos internautas que sempre apoiam o projeto Ti." + CRLF
    cTexto += "" + CRLF
    cTexto += "Espero que gostem." + CRLF
    cTexto += "" + CRLF
    cTexto += "Sugestões, Críticas ou outras ideias, podem entrar em contato." + CRLF
 
Return cTexto
