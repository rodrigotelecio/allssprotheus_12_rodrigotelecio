#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "topconn.ch"
/*/{Protheus.doc} CCEAUX
Layout para impressão de documento auxiliar da CC-e.
IMPORTANTE: não há definição legal de layout para CC-e até o momento.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 30/07/2012
@version 1.00 (P12.1.25)
@type Function	
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observações até o momento. 
@see https://allss.com.br/
@history 09/07/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilização da rotina para uso.
/*/
user function CCEAUX()
local   iw1,iw2,nLin
local   xBitMap := FisxLogo("1")
local   MMEMO1  := MMEMO2 := ""
local   xCGC    := "" 
local   aArea   := GetArea()
private cPerg   := "CCEAUX"
ValidPerg(cPerg)
if !Pergunte(cPerg,.T.)
	return
endif
if mv_par01 == 1
    dbSelectArea("SF2")
    dbSetOrder(1)
    if dbSeek(xFilial("SF2") + mv_par02 + mv_par03)
        cChvNfe  := SF2->F2_CHVNFE
        dEmissao := SF2->F2_EMISSAO
        cTipo	 := SF2->F2_TIPO
    else
        Aviso('TOTVS','A nota fiscal de saida informada nao foi encontrada. Por gentileza, revise os parametros e tente novamente.',{'&OK'},3,'Cancelamento de operacao') 
        RestArea(aArea)
        return        
    endif
	If cTipo $ "D/B"
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA)
		xDestinatario := SA2->A2_NOME
		if !Empty(SA2->A2_CGC)
			xCGC := iif(Len(SA2->A2_CGC) > 11 ,Transf(SA2->A2_CGC,"@R 99.999.999/9999-99"),Transf(SA2->A2_CGC,"@R 999.999.999-99"))
		endif
	else
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
		xDestinatario := SA1->A1_NOME
		if !Empty(SA1->A1_CGC)
			xCGC := iif(Len(SA1->A1_CGC) > 11 ,Transf(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transf(SA1->A1_CGC,"@R 999.999.999-99"))
		endif
	endif
elseif mv_par01 == 2
    dbSelectArea("SF1")
    dbSetOrder(1)
    if dbSeek(xFilial("SF1") + mv_par02 + mv_par03)
        cChvNfe  := SF1->F1_CHVNFE
        dEmissao := SF1->F1_EMISSAO
        cTipo	 := SF1->F1_TIPO
    else
        Aviso('TOTVS','A nota fiscal de entrada informada nao foi encontrada. Por gentileza, revise os parametros e tente novamente.',{'&OK'},3,'Cancelamento de operacao') 
        RestArea(aArea)
        return            
    endif
    if cTipo $ "D/B"
        dbSelectArea("SA1")
        dbSetOrder(1)
        dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA)
        xDestinatario := SA1->A1_NOME
        if !Empty(SA1->A1_CGC)
            xCGC := iif(Len(SA1->A1_CGC) > 11 ,Transf(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transf(SA1->A1_CGC,"@R 999.999.999-99"))
        endif				
    else
        dbSelectArea("SA2")
        dbSetOrder(1)
        dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA)
        xDestinatario := SA2->A2_NOME
        if !Empty(SA2->A2_CGC)
            xCGC := iif(Len(SA2->A2_CGC) > 11 ,Transf(SA2->A2_CGC,"@R 99.999.999/9999-99"),Transf(SA2->A2_CGC,"@R 999.999.999-99"))
        endif
    endif
endif
//COLETANDO DADOS DA CONEXÃO PROTHEUS
cdbServer   := GetSrvProfString("TOPServer","\undefined")
cdbName     := GetSrvProfString("TOPDataBase","\undefined")
cdbAlias    := GetSrvProfString("TOPAlias","\undefined")
ndbPort     := GetSrvProfString("TOPPort","\undefined")
//COLETANDO DADOS DA CONEXÃO TSS
cServerTSS  := GetPvProfString("TopConnect","Server","",SuperGetMv("MV_XINITSS",.T.,"appserver_tss_nfe_7066.ini"))
cNameTSS    := GetPvProfString("TopConnect","DataBase","",SuperGetMv("MV_XINITSS",.T.,"appserver_tss_nfe_7066.ini"))
cAliasTSS   := GetPvProfString("TopConnect","Alias","",SuperGetMv("MV_XINITSS",.T.,"appserver_tss_nfe_7066.ini"))
nPortTSS    := GetPvProfString("TopConnect","Port","",SuperGetMv("MV_XINITSS",.T.,"appserver_tss_nfe_7066.ini"))
if Empty(AllTrim(cdbServer)) .OR. Empty(AllTrim(cdbName)) .OR. Empty(AllTrim(cdbAlias)) .OR. Empty(AllTrim(ndbPort))
    Aviso('TOTVS','Nao existe conexao configurada do Protheus com o banco de dados.',{'&OK'},3,'Cancelamento de operacao')
    return
endif
if Empty(AllTrim(cServerTSS)) .OR. Empty(AllTrim(cNameTSS)) .OR. Empty(AllTrim(cAliasTSS)) .OR. Empty(AllTrim(nPortTSS))
    Aviso('TOTVS','Nao existe conexao configurada do TSS com o banco de dados.',{'&OK'},3,'Cancelamento de operacao')
    return
endif
lOutroBanco := .F.
if Upper(AllTrim(cdbServer)) <> Upper(AllTrim(cServerTSS)) .OR. Upper(AllTrim(cdbName)) <> Upper(AllTrim(cNameTSS)) .OR. Upper(AllTrim(cdbAlias)) <> Upper(AllTrim(cAliasTSS))
    lOutroBanco := .T.
    _nTcCon2    := ""
    TCConType("TCPIP")
    _nTcCon2    := TcLink(cNameTSS + "/ " + cAliasTSS,cServerTSS,nPortTSS)
    if _nTcCon2 < 0 
        Aviso('TOTVS','Houve algum erro de conexao com o banco de dados do TSS! Entre em contato com o administrador para solucao do problema.',{'&OK'},3,'Cancelamento de operacao')
        return
    endif 
    TcSetConn(_nTcCon2) 
endif
cQry := "SELECT TOP 1 "
cQry += "		ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
cQry += "		PROTOCOLO,NFE_CHV,ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_ERP)),'') AS TMEMO1,"
cQry += "		ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_RET)),'') AS TMEMO2 "
cQry += "FROM "
cQry += "		SPED150 "
cQry += "WHERE "
cQry += "		D_E_L_E_T_ = ' ' AND STATUS = 6 "
cQry += "		AND NFE_CHV = '" + cChvNfe + "' "
cQry += "ORDER BY 
cQry += "		LOTE DESC"
cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'TMP',.T.,.T.)
TcSetField("TMP","DATE_EVEN","D",08,0)
dbSelectArea("TMP")
TMP->(dbGoTop())
if (EOF())
    Aviso('TOTVS','Nao existe carta de correcao para a nota fiscal informada.',{'&OK'},3,'Cancelamento de operacao') 
	TMP->(dbCloseArea())
    if lOutroBanco
        TCUnlink(_nTcCon2)
        _nTcConn    := ""
        TCConType("TCPIP")
        _nTcConn    := TcLink(cdbName + "/" + cdbAlias,cdbServer,ndbPort)
        if _nTcConn < 0
            Aviso('TOTVS','Houve algum erro de conexao com o banco de dados do Protheus! Entre em contato com o administrador para solucao do problema.',{'&OK'},3,'Cancelamento de operacao')
        endif        
    	TcSetConn(_nTcConn)
	    RestArea(aArea)
    endif
    return
endif
MMEMO1      := TMP->TMEMO1
MMEMO2      := TMP->TMEMO2
MNFE_CHV    := TMP->NFE_CHV
MID_EVENTO  := TMP->ID_EVENTO
MTPEVENTO   := Str(TMP->TPEVENTO,6)
MSEQEVENTO  := Str(TMP->SEQEVENTO,1)
MAMBIENTE   := Str(TMP->AMBIENTE,1) + iif(TMP->AMBIENTE == 1," - Producao", iif(TMP->AMBIENTE == 2," - Homologacao",""))
MDATE_EVEN  := DtoC(TMP->DATE_EVEN)
MTIME_EVEN  := TMP->TIME_EVEN
MVERSAO     := Str(TMP->VERSAO,4,2)
MVEREVENTO  := Str(TMP->VEREVENTO,4,2)
MVERTPEVEN  := Str(TMP->VERTPEVEN,4,2)
MVERAPLIC   := TMP->VERAPLIC
MCORGAO     := Str(TMP->CORGAO,2) + iif(TMP->CORGAO == 42," - SANTA CATARINA", iif(TMP->CORGAO == 35, " - SAO PAULO",""))
MCSTATEVEN  := Str(TMP->CSTATEVEN,3)
MCMOTEVEN   := TMP->CMOTEVEN
MPROTOCOLO  := Str(TMP->PROTOCOLO,15)
TMP->(dbCloseArea())    
if lOutroBanco
    TCUnlink(_nTcCon2)
    _nTcConn    := ""
    TCConType("TCPIP")
    _nTcConn    := TcLink(cdbName + "/" + cdbAlias,cdbServer,ndbPort)
    if _nTcConn < 0
        Aviso('TOTVS','Houve algum erro de conexao com o banco de dados do Protheus! Entre em contato com o administrador para solucao do problema.',{'&OK'},3,'Cancelamento de operacao')
    endif        
    TcSetConn(_nTcConn)
endif
RestArea(aArea)
xFone       := RTrim(SM0->M0_TEL)
xFone       := StrTran(xFone,"(","")
xFone       := StrTran(xFone,")","")
xFone       := StrTran(xFone,"-","")
xFone       := StrTran(xFone," ","")
xFax        := RTrim(SM0->M0_FAX)
xFax        := StrTran(xFax,"(","")
xFax        := StrTran(xFax,")","")
xFax        := StrTran(xFax,"-","")
xFax        := StrTran(xFax," ","")	
xRazSoc     := RTrim(SM0->M0_NOMECOM)
xEnder      := RTrim(SM0->M0_ENDENT) + " - " + RTrim(SM0->M0_BAIRENT) + " - " + RTrim(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
xFone       := "Fone / Fax: " + Transf(xFone,"@R (99) 9999-9999") + iif(!Empty(SM0->M0_FAX)," / " + Transf(xFax,"@R (99) 9999-9999"),"")
xCnpj       := "C.N.P.J.: " 		+ Transf(SM0->M0_CGC,"@R 99.999.999/9999-99")
xIE         := "Insc. Estadual: "	+ SM0->M0_INSC
MDHEVENTO   := ""
iw1         := at("<dhRegEvento>",MMEMO2)
iw2         := at("</dhRegEvento>",MMEMO2)
if iw1 > 0
	iw3         := iw2 - iw1
	MDHEVENTO   += SubStr(MMEMO2,(iw1 + 13),(iw2 - (iw1 + 13)))
endif
MDESCEVEN   := ""
iw1         := at("<xEvento>",MMEMO2)
iw2         := at("</xEvento>",MMEMO2)
if iw1 > 0
	iw3         := iw2 - iw1
	MDESCEVEN   += SubStr(MMEMO2,(iw1 + 9),(iw2 - (iw1 + 9)))
endif
aCorrec     := {}
MCORRECAO   := ""
iw1         := at("<xCorrecao>",MMEMO1)
iw2         := at("</xCorrecao>",MMEMO1)
if iw1 > 0
	iw3         := iw2 - iw1
	MCORRECAO   += SubStr(MMEMO1,(iw1 + 11),(iw2 - (iw1 + 11))) 
	MCORRECAO   += Space(10)
	iw1 := 1
	while !Empty(SubStr(MCORRECAO,iw1,10))
		aAdd(aCorrec,SubStr(MCORRECAO,iw1,130))
		iw1     += 130
	enddo
endif
aCondic     := {}
MCONDICAO   := ""
iw1         := at("<xCondUso>",MMEMO1)
iw2         := at("</xCondUso>",MMEMO1)
if iw1 > 0
	aAdd(aCondic,"A carta de correcao e disciplinada pelo paragrafo 1-A do art. 7 do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para regularizacao de erro ocorrido na " )
	aAdd(aCondic,"emissao de documento fiscal, desde que o erro nao esteja relacionado com:"                                                                                               )
    aAdd(aCondic,"I - as variaveis que determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao;"             )
	aAdd(aCondic,"II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario;"                                                                               )
    aAdd(aCondic,"III - a data de emissao ou de saida."                                                                                                                                    )
endif
oPrint      := TMSPrinter():New("Impressão do documento auxiliar para carta de correção eletrônica - CC-e")
oFont08     := TFont():New( "Times New Roman",,08,,.f.,,,,,.f.,.f. )
oFont08b    := TFont():New( "Times New Roman",,08,,.t.,,,,,.f.,.f. )
oFont08bi   := TFont():New( "Times New Roman",,08,,.t.,,,,,.f.,.t. )
oFont09     := TFont():New( "Times New Roman",,09,,.f.,,,,,.f.,.f. )
oFont10     := TFont():New( "Times New Roman",,10,,.f.,,,,,.f.,.f. )
oFont10b    := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
oFont11     := TFont():New( "Times New Roman",,09,,.f.,,,,,.f.,.f. )
oFont11b    := TFont():New( "Times New Roman",,11,,.t.,,,,,.f.,.f. )
oFont12     := TFont():New( "Times New Roman",,12,,.f.,,,,,.f.,.f. )
oFont12b    := TFont():New( "Times New Roman",,12,,.t.,,,,,.f.,.f. )
oFont13b    := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
oFont14     := TFont():New( "Times New Roman",,14,,.f.,,,,,.f.,.f. )
oFont24b    := TFont():New( "Times New Roman",,24,,.t.,,,,,.f.,.f. )
oPrint:Setup()
oPrint:SetPortrait()
oPrint:SetPaperSize(9)       ///(DMPAPER_A4)
oPrint:StartPage()
oPrint:SetFont(oFont24b)
oPrint:SayBitMap(0050,0120,xBitMap,0600,0450)
oPrint:Say(0120,0780,xRazSoc                                                    ,oFont13b ,140)
oPrint:Say(0180,0780,xEnder                                                     ,oFont11  ,140)
oPrint:Say(0230,0780,xFone                                                      ,oFont11  ,140)
oPrint:Say(0280,0780,xCnpj                                                      ,oFont11  ,140)
oPrint:Say(0330,0780,xIE                                                        ,oFont11  ,140)
oPrint:Box(0100,1890,0390,2400)
oPrint:Line(0150,1890,0150,2400)
oPrint:Say(0104,2000,"Carta de Correcao"                                        ,oFont11b ,160)
oPrint:Say(0170,1920,"Serie: "        + mv_par03                                ,oFont11b ,100)
oPrint:Say(0240,1920,"Nota Fiscal: "  + mv_par02                                ,oFont11b ,100)
oPrint:Say(0310,1920,"Data Emissao: " + DtoC(dEmissao)                          ,oFont11b ,100)
oPrint:Box(0420,0100,3200,2400)
oPrint:Say(0440,0110,"Tipo do evento"                                           ,oFont12b ,100)
oPrint:Say(0440,0850,"Data e hora"                                              ,oFont12b ,100)
oPrint:Say(0440,1890,"Protocolo"                                                ,oFont12b ,100)
oPrint:Say(0490,0110,"Carta de Correcao NFe"                                    ,oFont11  ,100)
oPrint:Say(0490,0850,MDATE_EVEN + "  " + MTIME_EVEN                             ,oFont11  ,140)
oPrint:Say(0490,1890,MPROTOCOLO                                                 ,oFont11  ,140)
oPrint:Say(0580,0110,"Identificacao do destinatario"                            ,oFont11b ,200)
oPrint:Say(0580,1430,"CNPJ/CPF"                                                 ,oFont11b ,200)
oPrint:Say(0630,0110,xDestinatario                                              ,oFont11b ,800)
oPrint:Say(0630,1430,xCGC                                                       ,oFont11b ,260)
oPrint:Say(0740,0110,"DADOS DO EVENTO DA CARTA DE CORRECAO"                     ,oFont11b ,250)
oPrint:Say(0800,0110,"Versao do evento"                                         ,oFont11b ,100)
oPrint:Say(0800,0670,"Id evento"                                                ,oFont11b ,100)
oPrint:Say(0800,1890,"Tipo do evento"                                           ,oFont11b ,100)
oPrint:Say(0850,0110,MVERSAO                                                    ,oFont11  ,080)
oPrint:Say(0850,0670,MID_EVENTO                                                 ,oFont11  ,400)
oPrint:Say(0850,1890,MTPEVENTO                                                  ,oFont11  ,120)
oPrint:Say(0940,0110,"Identificacao do ambiente"                                ,oFont11b ,140)
oPrint:Say(0940,0670,"Codigo do orgao de recepcao do evento"                    ,oFont11b ,240)
oPrint:Say(0940,1430,"Chave de acesso da NF-e vinculada ao evento"              ,oFont11b ,250)
oPrint:Say(0990,0110,MAMBIENTE                                                  ,oFont11  ,080)
oPrint:Say(0990,0670,MCORGAO                                                    ,oFont11  ,240)
oPrint:Say(0990,1430,MNFE_CHV                                                   ,oFont11  ,880)
oPrint:Say(1050,0110,"Data e hora do recebimento do evento"                     ,oFont11b ,400)
oPrint:Say(1050,1430,"Sequencial do evento"                                     ,oFont11b ,100)
oPrint:Say(1050,1890,"Versao do tipo do evento"                                 ,oFont11b ,200)
oPrint:Say(1100,0110,MDHEVENTO                                                  ,oFont11  ,200)
oPrint:Say(1100,1430,MSEQEVENTO                                                 ,oFont11  ,020)
oPrint:Say(1100,1890,MVERTPEVEN                                                 ,oFont11  ,200)
oPrint:Say(1170,0110,"Versao do aplicativo que"                                 ,oFont11b ,100)
oPrint:Say(1210,0110,"recebeu o evento"                                         ,oFont11b ,100)
oPrint:Say(1170,0670,"Codigo de status do registro do evento"                   ,oFont11b ,300)
oPrint:Say(1170,1430,"Descricao literal do status de registro do evento"        ,oFont11b ,300)
oPrint:Say(1260,0110,MVERAPLIC                                                  ,oFont11  ,080)
oPrint:Say(1220,0670,MCSTATEVEN                                                 ,oFont11  ,060)
oPrint:Say(1220,1430,MCMOTEVEN                                                  ,oFont11  ,300)
oPrint:Say(1340,0110,"Descricao do evento"                                      ,oFont11b ,100)
oPrint:Say(1390,0110,MDESCEVEN                                                  ,oFont11  ,100)
oPrint:Say(1450,0110,"Texto da Carta de Correcao"                               ,oFont11b ,300)
nLin        := 1450
for iw1 := 1 to Len(aCorrec)
	 nLin       += 50
	 oPrint:Say(nLin,0110,aCorrec[iw1]                                          ,oFont11  ,2000)
next iw1 
nLin        := 2800
oPrint:Say(nLin,0110,"Condicoes de uso"                                         ,oFont11b ,100)
for iw2 := 1 to Len(aCondic)
	 nLin       += 50
	 oPrint:Say(nLin,0110,aCondic[iw2]                                          ,oFont11  ,2000)
next
oPrint:Say(3210,1850,"Powered by ALLSS Soluções em Sistemas"                    ,oFont08bi,300)
oPrint:EndPage()
oPrint:Preview()
Return .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPergº Autor ³ Rodrigo Telecio    º Data ³  30/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri??o ³ Valida as perguntas no SX1					              º±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal						                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function ValidPerg(_cPerg)
local _aArea := GetArea()
local _aTam  := {}
local _aRegs := {}
local i      := 0
local j      := 0 
_cAliasSX1 := "SX1"
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
_cPerg := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
_aTam  := TamSX3("F1_TIPO")
aAdd(_aRegs,{_cPerg,"01","Tp. operacao?"     ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"C","naovazio()","mv_par01","NF Saida" ,"","","","","NF Entrada"   ,"","","","","","","","","","","","","","","","","","",""      ,"",""})
_aTam  := TamSX3("F1_DOC")
aAdd(_aRegs,{_cPerg,"02","Nota Fiscal?"      ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par02",""         ,"","","","",""             ,"","","","","","","","","","","","","","","","","","",""      ,"",""})
_aTam  := TamSX3("F1_SERIE")
aAdd(_aRegs,{_cPerg,"03","Serie?"            ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par03",""         ,"","","","",""             ,"","","","","","","","","","","","","","","","","","",""      ,"",""})
for i := 1 to len(_aRegs)
    if !(_cAliasSX1)->(dbSeek(_cPerg+_aRegs[i,2]))
        while !RecLock(_cAliasSX1,.T.) ; enddo
        for j := 1 to FCount()
            if j <= Len(_aRegs[i])
                    FieldPut(j,_aRegs[i,j])
            else
                Exit
            endif
        next
        (_cAliasSX1)->(MsUnLock())
    endif
next
RestArea(_aArea)
return