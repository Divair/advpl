#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

Static __cCRLF    := CRLF

/*/
    Funcao:        U_Wally()
    Autor:        Marinaldo de Jesus (Sharing the Experience)
    Data:        27/09/2011
    Descricao:    Demonstrar o uso de RPCSetEnv com Troca de Empresa e/ou Filial
    Sintaxe:    <vide parametros formais>
/*/
User Function Wally()
    EvalPrg( { || Wally() } , "01" , "01" , "SIGAESP" )
Return( NIL )

/*/
    Funcao:        Wally()
    Autor:        Marinaldo de Jesus (Sharing the Experience)
    Data:        27/09/2011
    Descricao:    Wally foi dar uma volta, visitar suas filiais e nos mostrar por onde andou
    Sintaxe:    <vide parametros formais>
/*/
Static Function Wally()

    Local aMsg    := {}
    Local cMsg    := "Quem Fui Eu? " + __cCRLF

    //Estando no Ambiente Atual
    MsgInfo( "Quem Sou Eu? "  + "Empresa: " + cEmpAnt + " Filial: " + cFilAnt , ProcName() + " : " + AllTrim(Str(ProcLine()) ) )

    //Agora testado o novo ambiente 01/02
    aSize( aMsg    , 0 )
    MsgRun( "Aguarde..." , "Dando Uma Volta" , { || ChangeWEF( @aMsg , "01" , "02" , .T. ) } )
    //Carrego as Msg por Onde Passei
    aEval( aMsg , { |cMessage| cMsg += ( cMessage + __cCRLF    ) } )

    //Agora testado o novo ambiente 01/03
    aSize( aMsg    , 0 )
    MsgRun(  "Aguarde..." , "Dando ++Uma Volta" , { || ChangeWEF( @aMsg , "01" , "03" , .T. ) }  )
    //Carrego as Msg por Onde Passei
    aEval( aMsg , { |cMessage| cMsg += ( cMessage + __cCRLF    ) } )

    //Agora testado o novo ambiente 01/01
    aSize( aMsg    , 0 )
    MsgRun(  "Aguarde..." , "Dando Uma Volta++" , { || ChangeWEF( @aMsg , "01" , "01" , .T. ) }  )
    //Carrego as Msg por Onde Passei
    aEval( aMsg , { |cMessage| cMsg += ( cMessage + __cCRLF    ) } )

    //Verifica por Onde Passei
    MsgInfo( cMsg , ProcName() + " : " + AllTrim(Str(ProcLine())) + " :: " + "Caminhos de Wally" )

    //Retesta o ambiente atual
    MsgInfo( "Quem Sou Eu? "  + "Empresa: " + cEmpAnt + " Filial: " + cFilAnt , ProcName() + " : " + AllTrim(Str(ProcLine())) )

Return( NIL )

/*/
    Funcao:        Wally()
    Autor:        Marinaldo de Jesus (Sharing the Experience)
    Data:        27/09/2011
    Descricao:    Transporte de Wally
    Sintaxe:    <vide parametros formais>
/*/
Static Function ChangeWEF( aMsg , cEmp , cFil , lRecursa )

    Local cMsg    := ""

    Local lRpcSet := !( cEmpAnt == cEmp .and. cFil == cFilAnt )

    IF !( lRpcSet )
        cMsg    := u_GetMsg( @aMsg , @cEmp , @cFil , @lRpcSet , @lRecursa )
    Else
        cMsg    := StartJob( "u_GetMsg" , GetEnvServer() , .T. , @aMsg , @cEmp , @cFil , @lRpcSet , @lRecursa )
    EndIF

    aAdd( aMsg , cMsg )

Return( NIL )

/*/
    Funcao:        GetMsg()
    Autor:        Marinaldo de Jesus (Sharing the Experience)
    Data:        27/09/2011
    Descricao:    Caminhos do Wally
    Sintaxe:    <vide parametros formais>
/*/
User Function GetMsg( aMsg , cEmp , cFil , lRpcSet , lRecursa )

    Local cMsg    := ""

    IF ( lRpcSet )
        RpcSetType( 3 )
        RpcSetEnv( cEmp , cFil )
    EndIF

    DEFAULT lRecursa    := .F.
    IF ( lRecursa )

        lRecursa        := .F.

        //Agora testado o novo ambiente
        ChangeWEF( @aMsg , "01" , "03" , @lRecursa )
        ChangeWEF( @aMsg , "01" , "02" , @lRecursa )
        ChangeWEF( @aMsg , "01" , "01" , @lRecursa )
        ChangeWEF( @aMsg , cEmp , cFil , @lRecursa )

        aEval( aMsg , { |cMessage| cMsg += ( cMessage + __cCRLF    ) } )

    Else

        cMsg := "Quem Sou Eu? "  + "Empresa: " + cEmpAnt + " Filial: " + cFilAnt +  " " + ProcName() + " : " + AllTrim(Str(ProcLine()))

    EndIF

Return( cMsg )

/*/
    Funcao:        EvalPrg()
    Autor:        Marinaldo de Jesus (Sharing the Experience)
    Data:        27/09/2011
    Descricao:    Start de Wally
    Sintaxe:    <vide parametros formais>
/*/
Static Function EvalPrg( bExec , cEmp , cFil , cModulo )

    Local bWindowInit    := { || Eval( bExec ) }
    Local lPrepEnv        := ( IsBlind() .or. ( Select( "SM0" ) == 0 ) )
    Local uRet

    BEGIN SEQUENCE

        IF ( lPrepEnv )
            RpcSetType( 3 )
            PREPARE ENVIRONMENT EMPRESA( cEmp ) FILIAL ( cFil ) MODULO ( cModulo )
            InitPublic()
            SetsDefault()
            SetModulo( "SIGAESP2" , "ESP2" )
        EndIF

            IF ( Type(  "oMainWnd" ) == "O" )
                uRet := Eval( bExec )
                BREAK
            EndIF

            bWindowInit    := { || uRet := Eval( bExec ) }
            DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )
              ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )
        IF ( lPrepEnv )
            RESET ENVIRONMENT
        EndIF   

    END SEQUENCE

Return( uRet )
