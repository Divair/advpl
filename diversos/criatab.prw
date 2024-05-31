#include 'protheus.ch'

User function CriaTabela(_param) //u_CriaTabela()
Default _param := "ZEC"
RpcClearEnv()
RPCSetType(3)
RpcSetEnv("02","01",,,"",GetEnvServer())

X31UPDTABLE(_param)
CHKFILE(_param)
X31UPDTABLE(_param)
CHKFILE(_param)
DbSelectArea(_param)

return .T.
