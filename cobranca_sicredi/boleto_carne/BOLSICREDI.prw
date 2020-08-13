#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#define ENT CHR(13)+CHR(10)
static cDirTmp := GetTempPath()
/*/{Protheus.doc} BOLSICREDI
Impressใo do boleto do Banco Sicredi (formato carn๊) de acordo com a parametriza็ใo disponibilizada pelo banco.
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 08/08/2020
@version P12.1.25
@type Function	
    @param nil, nulo, nenhum
    @return nulo, nil  
@obs Sem observa็๕es at้ o momento 
@see https://allss.com.br/
@history 08/08/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Aplica็ใo no ambiente de produ็ใo.
/*/
user function BOLSICREDI()
private oPrn
private cTitulo		:= "Impressใo de Boleto Grแfico - Banco Sicredi"
private cPerg	    := AllTrim(FunName())
private cArqLog	    := AllTrim(FunName())
private cLogoBco    := "logo_peq_sicredi.bmp"
private NOSSONUM	:= ""
private cLinha		:= ""
private cBarra		:= ""
private MsgInstr03	:= ""
private cMensMult   := ""
private cMensJur	:= ""
private cMensDesc	:= ""
ValidPerg()
if !Pergunte(cPerg,.T.)
	Aviso('TOTVS','Parametros nใo confirmados pelo usuแrio. Rotina serแ fechada.',{'OK'},3,'Cancelamento de opera็ใo pelo operador')
    return
endif
if !Empty(mv_par04) .AND. !Empty(mv_par11) .AND. !Empty(mv_par12) .AND. !Empty(mv_par13) .AND. !Empty(mv_par14)
    Processa({ |lEnd| ImpBolIt(lEnd)},cTitulo,"Processando informa็๕es...",.T.)		
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpBolIt  บAutor  ณRodrigo Telecio       Data ณ 20/07/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento de impressใo da rotina.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ImpBolIt(lEnd)
local lRet  := .T.
if !(mv_par11) $ '748'
    Aviso('TOTVS','Este banco nใo pode ser utilizado para a impressใo deste boleto. Essa rotina estแ preparada para impressใo do boleto do BANCO SICREDI (748).',{'OK'},3,'Cancelamento de opera็ใo')
	return
else
	dbSelectArea("SEE")
	dbSetOrder(1)
	if !msSeek(xFilial("SEE") + mv_par11 + mv_par12 + mv_par13 + mv_par14)
        Aviso('TOTVS','Arquivo de parโmetros banco/CNAB incorreto. Verifique banco/ag๊ncia/conta/sub-conta.',{'OK'},3,'Cancelamento de opera็ใo')
		return
	elseif Upper(AllTrim(SEE->EE_EXTEN)) <> "REM"
        Aviso('TOTVS','Dados de parโmetros banco/CNAB nใo se referem a configura็ใo de REMESSA!',{'OK'},3,'Cancelamento de opera็ใo')
		return
	endif
endif
dbSelectArea("SE1")
_cQry       := "SELECT R_E_C_N_O_ RECSE1, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA "                   + ENT
_cQry       += "FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "                                           + ENT
_cQry       += "WHERE SE1.D_E_L_E_T_ = '' "                                                             + ENT
_cQry       += "  AND SE1.E1_FILIAL = '" + xFilial("SE1")  + "' "                                       + ENT
_cQry       += "  AND SE1.E1_PREFIXO BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "                + ENT
_cQry       += "  AND SE1.E1_NUM     BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "                + ENT
_cQry       += "  AND SE1.E1_NUMBOR  BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "                + ENT
_cQry       += "  AND SE1.E1_EMISSAO BETWEEN '" + DtoS(mv_par07)  + "' AND '" + DtoS(mv_par08) + "' "   + ENT
_cQry       += "  AND SE1.E1_VENCTO  BETWEEN '" + DtoS(mv_par09)  + "' AND '" + DtoS(mv_par10) + "' "   + ENT
_cQry       += "  AND SE1.E1_SALDO         > 0 "                                                        + ENT
_cQry       += "  AND SE1.E1_TIPO         <> 'CH'  "                                                    + ENT
_cQry       += "  AND SE1.E1_TIPO         <> 'NCC' "                                                    + ENT
_cQry       += "  AND SE1.E1_TIPO         <> 'RA' "                                                     + ENT
_cQry       += "  AND SE1.E1_PORTADO       = '" + mv_par11        + "' "                                + ENT
_cQry       += "  AND SE1.E1_AGEDEP        = '" + mv_par12        + "' "                                + ENT
_cQry       += "  AND SE1.E1_CONTA         = '" + mv_par13        + "' "                                + ENT
_cQry       += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA "                                    + ENT
MemoWrite(cDirTmp + cArqLog + ".txt", _cQry)
if ChkFile("SE1TMP")
	SE1TMP->(dbCloseArea())
endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SE1TMP",.T.,.F.)
dbSelectArea("SE1TMP")
if SE1TMP->(EOF())
	SE1TMP->(dbCloseArea())
    Aviso('TOTVS','Nใo hแ dados com os parโmetros informados para impressใo de boleto(s)!',{'OK'},3,'Cancelamento de opera็ใo')
	return
endif
ProcRegua(SE1TMP->(RecCount()))
oFont06    := TFont():New( "Arial"       ,,06,,.f.,,,,,.f.)
oFont08b   := TFont():New( "Arial"       ,,08,,.t.,,,,,.f.)
oFont10    := TFont():New( "Arial"       ,,10,,.f.,,,,,.f.)
oFont10b   := TFont():New( "Arial"       ,,10,,.t.,,,,,.f.)
oFont14    := TFont():New( "Arial"       ,,14,,.f.,,,,,.f.)
oFont18    := TFont():New( "Arial"       ,,18,,.f.,,,,,.f.)
oFont18b   := TFont():New( "Arial"       ,,18,,.t.,,,,,.f.)
oPrn       := TMSPrinter():New(cTitulo)
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetPortRait()
dbSelectArea("SE1TMP")
while !SE1TMP->(EOF())
    nCount      := 1
    cPrefixo    := SE1TMP->E1_PREFIXO
    cNumTitulo  := SE1TMP->E1_NUM
    while !SE1TMP->(EOF()) .AND. SE1TMP->E1_PREFIXO == cPrefixo .AND. SE1TMP->E1_NUM == cNumTitulo
        dbSelectArea("SE1")
        SE1->(dbSetOrder(1))
        SE1->(dbGoTo(SE1TMP->RECSE1))
        IncProc("Processando tํtulo" + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + "...")
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))
        if !SA1->(msSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.))
            Aviso('TOTVS','Problemas na localiza็ใo do cliente ' + SE1->E1_CLIENTE + '/' + SE1->E1_LOJA + ' do titulo ' + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + '. Logo, nใo conseguiremos imprimir tal(is) boleto(s).',{'OK'},3,'Cancelamento de opera็ใo')
            dbSelectArea("SE1TMP")
            SE1TMP->(dbSkip())
            loop
        endif
        //### REG.001 - Composi็ใo do Nosso N๚mero
        NOSSONUM    := SE1->E1_NUMBCO
        //### REG.002 - Composi็ใo dos valores e mensagens
        //Inํcio do c๔mputo dos valores
        _nSaldo     := SE1->E1_SALDO
        _nJuros     := SE1->E1_VALJUR
        //Coleta das informa็๕es do cliente
        _cCEPc      := AllTrim(SA1->A1_CEP)
        _cEndc      := AllTrim(FisGetEnd(SA1->A1_END,SA1->A1_EST)[1]) + ", " + AllTrim(FisGetEnd(SA1->A1_END,SA1->A1_EST)[3])
        _cBair      := AllTrim(SA1->A1_BAIRRO)
        _cMunc      := AllTrim(SA1->A1_MUN)
        _cEstc      := AllTrim(SA1->A1_EST)
        _cCompl     := AllTrim(SA1->A1_COMPLEM)
        if Len(AllTrim(SA1->A1_CGC)) == 14
            _cCnpj  := "C.N.P.J.: " + SubStr(SA1->A1_CGC,1,2) + "." + SubStr(SA1->A1_CGC,3,3) + "." + SubStr(SA1->A1_CGC,6,3) + "/" + SubStr(SA1->A1_CGC,9,4) + "-" + SubStr(SA1->A1_CGC,13,2)
        elseif Len(AllTrim(SA1->A1_CGC)) == 11
            _cCnpj  := "C.P.F.: "  + SubStr(SA1->A1_CGC,1,3) + "." + SubStr(SA1->A1_CGC,4,3) + "." + SubStr(SA1->A1_CGC,7,3) + "-" + SubStr(SA1->A1_CGC,10,2)
        else
            _cCnpj  := "C.P.F./C.N.P.J.: " + AllTrim(SA1->A1_CGC)
        endif
        //Mensagem relativa a multa
        _cMensMult  := ""
        if GetMv("MV_LJMULTA") > 0
            _cMensMult:= "Ap๓s o vencimento, cobrar multa de " + AllTrim(Transform(GetMv("MV_LJMULTA"),"@E 999,999.99")) + "%"
        endif    
        //Mensagem relativa a juros
        _cMensJur   := ""
        if _nJuros <> 0
            _cMensJur := "Ap๓s o vencimento, cobrar mora diแria de R$ " + AllTrim(Transform(_nJuros,"@E 999,999.99")) + ""
        endif
        //Mensagens adicionais s๓ para o boleto
        MsgInstr03  := ''
        if !Empty(mv_par15)
            if !Empty(MsgInstr03)
                MsgInstr03 += ENT
            endif
            MsgInstr03 += AllTrim(mv_par15)
        endif
        if !Empty(mv_par16)
            if !Empty(MsgInstr03)
                MsgInstr03 += " "
            endif
            MsgInstr03 += AllTrim(mv_par16)
        endif	
        //### REG.003 - Composi็ใo do C๓digo de Barras
        cFatVen     := SE1->E1_VENCTO - StoD("19971007")
        cBarra      := SubStr(SEE->EE_CODIGO,1,3)						//001 a 003 - C๓digo do Banco
        cBarra      += iif(SE1->E1_MOEDA == 1,'9','0')					//004 a 004 - C๓digo da Moeda
        cBarra      += "1"												//005 a 005 - DV C๓digo de Barras
        cBarra      += StrZero(cFatVen,4)           					//006 a 009 - Fator de Vencimento
        cBarra      += StrZero(Round(((Round(_nSaldo,2))*100),0),10)	//010 a 019 - Valor (arredondado com 02 decimais)
        cTempBar    := ""
        cTempBar    += "1"                                              //020 a 020 - C๓digo num้rico correspondente ao tipo de cobran็a
        cTempBar    += "1"                                              //021 a 021 - C๓digo num้rico correspondente ao tipo de carteira
        cTempBar  	+= StrZero(Val(NOSSONUM),9)						    //022 a 030 - Nosso Numero - Livre do cliente
        cTempBar    += StrZero(Val(SEE->EE_AGENCIA),4)                  //031 a 034 - Cooperativa de cr้dito/ag๊ncia beneficiแria
        cTempBar    += StrZero(Val(AllTrim(SEE->EE_CODEMP)),2)          //035 a 036 - Posto da cooperativa de cr้dito/ag๊ncia beneficiแria
        cTempBar    += StrZero(Val(SEE->EE_CONTA),5)                    //037 a 041 - C๓digo do beneficiแrio
        cTempBar  	+= iif(_nSaldo > 0,"1","0")                         //042 a 042 - "1" quando houver valor expresso / "0" quando o valor do documento for zerado
        cTempBar  	+= "0"                                              //043 a 043 - filler (zeros)
        cBarra      += cTempBar
        cBarra      += CalcDVCL(cTempBar)                               //044 a 044 - DV do campo livre
        //### REG.004 - Composi็ใo da Linha Digitแvel
        cLinha      := CalcLinDig()
        //### IMPRESSรO DO BOLETO
        if nCount > 3
            nCount  := 1
            oPrn:EndPage()
        endif
        if nCount == 1
            nCount++
            oPrn:StartPage()
            oPrn:Line(0010      ,0050       ,0110       ,0050       )
            oPrn:SayBitmap(0010     ,0055       ,cLogoBco       ,0240       ,0100       )
            oPrn:Line(0010      ,0310       ,0110       ,0310       )
            oPrn:Say(0020       ,0320       ,SubStr(cBarra,1,3) + "-" + "X"     ,oFont18b,100)
            oPrn:SayBitmap(0010     ,0535       ,cLogoBco       ,0240       ,0100       )
            oPrn:Line(0010      ,0795       ,0110       ,0795       )
            oPrn:Say(0020       ,0810       ,SubStr(cBarra,1,3) + "-" + "X"     ,oFont18b,100)
            oPrn:Line(0010      ,0995       ,0110       ,0995       )
            oPrn:Say(0032       ,1005       ,cLinha                             ,oFont14 ,150)

            oPrn:Line(0110      ,0050       ,0110       ,0500       )
            oPrn:Say(0112       ,0052           ,"Parcela/Plano"                ,oFont06 ,100)
            oPrn:Say(0137       ,0062           ,AllTrim(SE1->E1_PARCELA)                                                                                                   ,oFont10b,100)    
            oPrn:Line(0110      ,0225       ,0190       ,0225       )
            oPrn:Say(0112       ,0227           ,"Vencimento"                   ,oFont06 ,100)
            oPrn:Say(0137       ,0237           ,DtoC(SE1->E1_VENCTO)                                                                                                       ,oFont10b,100)
            oPrn:Line(0110      ,0535       ,0110       ,2430       )
            oPrn:Say(0112       ,0537           ,"Local de Pagamento"           ,oFont06 ,100)
            oPrn:Say(0137       ,0547           ,"PAGมVEL PREFERENCIALMENTE EM CANAIS DA SUA INSTITUIวรO FINANCEIRA"                                                        ,oFont10b,100)    
            oPrn:Line(0110      ,2000       ,0190       ,2000       )
            oPrn:Say(0112       ,2002           ,"Vencimento"                   ,oFont06 ,100)
            oPrn:Say(0137       ,2402           ,DtoC(SE1->E1_VENCTO)                                                                                                       ,oFont10b,100,,,1)

            oPrn:Line(0190      ,0050       ,0190       ,0500       )
            oPrn:Say(0192       ,0052           ,"Agencia/C๓d. do Beneficiแrio" ,oFont06 ,100)
            oPrn:Say(0217       ,0062           ,AllTrim(SEE->EE_AGENCIA) + "." + AllTrim(SEE->EE_CODEMP) +  "." + AllTrim(SEE->EE_CONTA)                                   ,oFont10b,100)
            oPrn:Line(0190      ,0535       ,0190       ,2430       )
            oPrn:Say(0192       ,0537           ,"Beneficiแrio"                 ,oFont06 ,100)
            oPrn:Say(0217       ,0547           ,SubStr(AllTrim(SM0->M0_NOMECOM),1,40) + " - C.N.P.J. " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                    ,oFont10b,100)
            oPrn:Line(0190      ,2000       ,0270       ,2000       )
            oPrn:Say(0192       ,2002           ,"Agencia/C๓d. do Beneficiแrio" ,oFont06 ,100)
            oPrn:Say(0217       ,2402           ,AllTrim(SEE->EE_AGENCIA) + "." + AllTrim(SEE->EE_CODEMP) +  "." + AllTrim(SEE->EE_CONTA)                                   ,oFont10b,100,,,1)    

            oPrn:Line(0270      ,0050       ,0270       ,0500       )
            oPrn:Say(0272       ,0052           ,"Especie Moeda"                ,oFont06 ,100)
            oPrn:Say(0297       ,0062           ,iif(SE1->E1_MOEDA == 1,"REAL","")                                                                                          ,oFont10b,100)
            oPrn:Line(0270      ,0225       ,0350       ,0225       )
            oPrn:Say(0272       ,0227           ,"Quantidade Moeda"             ,oFont06 ,100)
            oPrn:Line(0270      ,0535       ,0270       ,2430       )
            oPrn:Say(0272       ,0537           ,"Data Documento"               ,oFont06 ,100)
            oPrn:Say(0297       ,0547           ,DtoC(SE1->E1_EMISSAO)                                                                                                      ,oFont10b,100)
            oPrn:Line(0270      ,0850       ,0350       ,0850       )
            oPrn:Say(0272       ,0852           ,"Numero Documento"             ,oFont06 ,100)
            oPrn:Say(0297       ,0862           ,AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM)                                                                            ,oFont10b,100)
            oPrn:Line(0270      ,1200       ,0350       ,1200       )
            oPrn:Say(0272       ,1202           ,"Especie Documento"            ,oFont06 ,100)
            oPrn:Say(0297       ,1212           ,"DMI"                                                                                                                      ,oFont10b,100)
            oPrn:Line(0270      ,1420       ,0350       ,1420       )
            oPrn:Say(0272       ,1422           ,"Aceite"                       ,oFont06 ,100)
            oPrn:Say(0297       ,1432           ,"A"                                                                                                                        ,oFont10b,100)    
            oPrn:Line(0270      ,1570       ,0350       ,1570       )
            oPrn:Say(0272       ,1572           ,"Data Processamento"           ,oFont06 ,100)
            oPrn:Say(0297       ,1582           ,DtoC(SE1->E1_EMISSAO)                                                                                                      ,oFont10b,100)
            oPrn:Line(0270      ,2000       ,0350       ,2000       )
            oPrn:Say(0272       ,2002           ,"Nosso N๚mero"                 ,oFont06 ,100)
            oPrn:Say(0297       ,2402           ,Transform(SE1->E1_NUMBCO,"@R 99/999999-9")                                                                                 ,oFont10b,100,,,1)

            oPrn:Line(0350      ,0050       ,0350       ,0500       )
            oPrn:Say(0352       ,0052           ,"1 (=) Valor do documento"     ,oFont06 ,100)
            oPrn:Say(0377       ,0500           ,iif(SE1->E1_MOEDA == 1,"R$","") + Transform(_nSaldo,"@E 999,999.99")                                                       ,oFont10b,100,,,1)
            oPrn:Line(0350      ,0535       ,0350       ,2430       )
            oPrn:Say(0352       ,0537           ,"Parcela/Plano"                ,oFont06 ,100)
            oPrn:Say(0377       ,0547           ,AllTrim(SE1->E1_PARCELA)                                                                                                   ,oFont10b,100)
            oPrn:Line(0350      ,0950       ,0430       ,0950       )
            oPrn:Say(0352       ,0952           ,"Esp้cie Moeda"                ,oFont06 ,100)
            oPrn:Say(0377       ,0962           ,iif(SE1->E1_MOEDA == 1,"REAL","")                                                                                          ,oFont10b,100)
            oPrn:Line(0350      ,1200       ,0430       ,1200       )
            oPrn:Say(0352       ,1202           ,"Quantidade Moeda"             ,oFont06 ,100)
            oPrn:Line(0350      ,1600       ,0430       ,1600       )
            oPrn:Say(0352       ,1602           ,"Valor Moeda"                  ,oFont06 ,100)
            oPrn:Line(0350      ,2000       ,0430       ,2000       )
            oPrn:Say(0352       ,2002           ,"Valor Documento"              ,oFont06 ,100)
            oPrn:Say(0377       ,2402           ,iif(SE1->E1_MOEDA == 1,"R$","") + Transform(_nSaldo,"@E 999,999.99")                                                       ,oFont10b,100,,,1)

            oPrn:Line(0430      ,0050       ,0430       ,0500       )
            oPrn:Say(0432       ,0052           ,"2 (-) Desconto/Abatimento"    ,oFont06 ,100)
            oPrn:Line(0430      ,0535       ,0430       ,2430       )
            oPrn:Say(0432       ,0537           ,"Instru็๕es"                   ,oFont06 ,100)
            oPrn:Say(0457       ,0547           ,SubStr(AllTrim(_cMensMult),1,60)                                                                                           ,oFont10 ,100)
            oPrn:Say(0492       ,0547           ,SubStr(AllTrim(_cMensJur),1,60)                                                                                            ,oFont10 ,100)
            oPrn:Say(0527       ,0547           ,SubStr(AllTrim(MsgInstr03),1,60)                                                                                           ,oFont10 ,100)
            oPrn:Say(0562       ,0547           ,SubStr(AllTrim(MsgInstr03),61,60)                                                                                          ,oFont10 ,100)

            oPrn:Line(0430      ,2000       ,0510       ,2000       )
            oPrn:Say(0432       ,2002           ,"(-) Descontos/Abatimentos"    ,oFont06 ,100)

            oPrn:Line(0510      ,0050       ,0510       ,0500       )
            oPrn:Say(0512       ,0052           ,"3 (-) Outras dedu็๕es"        ,oFont06 ,100)
            oPrn:Line(0510      ,2000       ,0510       ,2430       )
            oPrn:Line(0510      ,2000       ,0590       ,2000       )
            oPrn:Say(0512       ,2002           ,"(-) Outras dedu็๕es"          ,oFont06 ,100)

            oPrn:Line(0590      ,0050       ,0590       ,0500       )
            oPrn:Say(0592       ,0052           ,"4 (+) Mora/Multa"             ,oFont06 ,100)
            oPrn:Line(0590      ,2000       ,0590       ,2430       )
            oPrn:Line(0590      ,2000       ,0660       ,2000       )
            oPrn:Say(0592       ,2002           ,"(+) Mora/Multa"               ,oFont06 ,100)

            oPrn:Line(0660      ,0050       ,0660       ,0500       )
            oPrn:Say(0662       ,0052           ,"5 (+) Outros acr้scimos"      ,oFont06 ,100)
            oPrn:Line(0660      ,2000       ,0660       ,2430       )
            oPrn:Line(0660      ,2000       ,0740       ,2000       )
            oPrn:Say(0662       ,2002           ,"(+) Outros acr้scimos"        ,oFont06 ,100)

            oPrn:Line(0740      ,0050       ,0740       ,0500       )
            oPrn:Say(0742       ,0052           ,"6 (=) Valor Cobrado"          ,oFont06 ,100)
            oPrn:Line(0740      ,2000       ,0740       ,2430       )
            oPrn:Line(0740      ,2000       ,0820       ,2000       )
            oPrn:Say(0742       ,2002           ,"(=) Valor Cobrado"            ,oFont06 ,100)

            oPrn:Line(0820      ,0050       ,0820       ,0500       )
            oPrn:Say(0822       ,0052           ,"Nosso N๚mero"                 ,oFont06 ,100)
            oPrn:Say(0847       ,0062           ,Transform(SE1->E1_NUMBCO,"@R 99/999999-9")                                                                                 ,oFont10b,100)
            oPrn:Line(0820      ,0535       ,0820       ,2430       )
            oPrn:Say(0822       ,0537           ,"Pagador"                      ,oFont06 ,100)
            oPrn:Say(0847       ,0547           ,SubStr(AllTrim(SA1->A1_NOME),1,40) + " - " + _cCnpj                                                                        ,oFont10b,100)
            oPrn:Say(0882       ,0547           ,SubStr(AllTrim(_cEndc),1,40) + iif(!Empty(_cCompl)," - " + SubStr(_cCompl,1,15),"") + " - " + SubStr(AllTrim(_cBair),1,20) ,oFont10b,100)
            oPrn:Say(0917       ,0547           ,SubStr(AllTrim(_cMunc),1,40) + "/" + AllTrim(_cEstc) + " - " + AllTrim(_cCEPc)                                             ,oFont10b,100)    

            oPrn:Line(0900      ,0050       ,0900       ,0500       )
            oPrn:Say(0902       ,0052           ,"N๚mero do documento"          ,oFont06 ,100)
            oPrn:Say(0927       ,0062           ,AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM)                                                                            ,oFont10b,100)

            oPrn:Line(0980      ,0050       ,0980       ,0500       )
            oPrn:Say(0982       ,0052           ,"Pagador"                      ,oFont06 ,100)
            oPrn:Say(1007       ,0062           ,SubStr(AllTrim(SE1->E1_NOMCLI),1,30)                                                                                       ,oFont10b,100)    
            oPrn:Line(0980      ,0535       ,0980       ,2430       )
            MSBAR("INT25",8.4,5.2,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.2,NIL,NIL,NIL,.F.)
            oPrn:Say(0982       ,2100           ,"Autentica็ใo Mecโnica"        ,oFont06 ,100)

            oPrn:Line(1080      ,0050       ,1080       ,0500       )
            oPrn:Say(1082       ,0227           ,"Recibo do pagador"            ,oFont08b,100)
            oPrn:Say(1092       ,2100           ,"Ficha de Compensa็ใo"         ,oFont08b,100)
            oPrn:Say(1115       ,0270           ,"Autenticar no verso"          ,oFont06 ,100)

            oPrn:Say(1140       ,0050           ,Replicate("-",440)             ,oFont06 ,100)
        elseif nCount == 2
            nCount++
            oPrn:Line(1170      ,0050       ,1270       ,0050       )
            oPrn:SayBitmap(1170     ,0055       ,cLogoBco       ,0240       ,0100       )
            oPrn:Line(1170      ,0310       ,1270       ,0310       )
            oPrn:Say(1180       ,0320       ,SubStr(cBarra,1,3) + "-" + "X"     ,oFont18b,100)
            oPrn:SayBitmap(1170     ,0535       ,cLogoBco       ,0240       ,0100       )
            oPrn:Line(1170      ,0795       ,1270       ,0795       )
            oPrn:Say(1180       ,0810       ,SubStr(cBarra,1,3) + "-" + "X"     ,oFont18b,100)
            oPrn:Line(1170      ,0995       ,1270       ,0995       )
            oPrn:Say(1192       ,1005       ,cLinha                             ,oFont14 ,150)

            oPrn:Line(1270      ,0050       ,1270       ,0500       )
            oPrn:Say(1272       ,0052           ,"Parcela/Plano"                ,oFont06 ,100)
            oPrn:Say(1297       ,0062           ,AllTrim(SE1->E1_PARCELA)                                                                                                   ,oFont10b,100)    
            oPrn:Line(1270      ,0225       ,1360       ,0225       )
            oPrn:Say(1272       ,0227           ,"Vencimento"                   ,oFont06 ,100)
            oPrn:Say(1297       ,0237           ,DtoC(SE1->E1_VENCTO)                                                                                                       ,oFont10b,100)
            oPrn:Line(1270      ,0535       ,1270       ,2430       )
            oPrn:Say(1272       ,0537           ,"Local de Pagamento"           ,oFont06 ,100)
            oPrn:Say(1297       ,0547           ,"PAGมVEL PREFERENCIALMENTE EM CANAIS DA SUA INSTITUIวรO FINANCEIRA"                                                        ,oFont10b,100)    
            oPrn:Line(1270      ,2000       ,1360       ,2000       )
            oPrn:Say(1272       ,2002           ,"Vencimento"                   ,oFont06 ,100)
            oPrn:Say(1297       ,2402           ,DtoC(SE1->E1_VENCTO)                                                                                                       ,oFont10b,100,,,1)

            oPrn:Line(1360      ,0050       ,1360       ,0500       )
            oPrn:Say(1362       ,0052           ,"Agencia/C๓d. do Beneficiแrio" ,oFont06 ,100)
            oPrn:Say(1387       ,0062           ,AllTrim(SEE->EE_AGENCIA) + "." + AllTrim(SEE->EE_CODEMP) +  "." + AllTrim(SEE->EE_CONTA)                                   ,oFont10b,100)
            oPrn:Line(1360      ,0535       ,1360       ,2430       )
            oPrn:Say(1362       ,0537           ,"Beneficiแrio"                 ,oFont06 ,100)
            oPrn:Say(1387       ,0547           ,SubStr(AllTrim(SM0->M0_NOMECOM),1,40) + " - C.N.P.J. " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                    ,oFont10b,100)
            oPrn:Line(1360      ,2000       ,1440       ,2000       )
            oPrn:Say(1362       ,2002           ,"Agencia/C๓d. do Beneficiแrio" ,oFont06 ,100)
            oPrn:Say(1387       ,2402           ,AllTrim(SEE->EE_AGENCIA) + "." + AllTrim(SEE->EE_CODEMP) +  "." + AllTrim(SEE->EE_CONTA)                                   ,oFont10b,100,,,1)                

            oPrn:Line(1440      ,0050       ,1440       ,0500       )
            oPrn:Say(1442       ,0052           ,"Especie Moeda"                ,oFont06 ,100)
            oPrn:Say(1467       ,0062           ,iif(SE1->E1_MOEDA == 1,"REAL","")                                                                                          ,oFont10b,100)
            oPrn:Line(1440      ,0225       ,1520       ,0225       )
            oPrn:Say(1442       ,0227           ,"Quantidade Moeda"             ,oFont06 ,100)
            oPrn:Line(1440      ,0535       ,1440       ,2430       )
            oPrn:Say(1442       ,0537           ,"Data Documento"               ,oFont06 ,100)
            oPrn:Say(1467       ,0547           ,DtoC(SE1->E1_EMISSAO)                                                                                                      ,oFont10b,100)
            oPrn:Line(1440      ,0850       ,1520       ,0850       )
            oPrn:Say(1442       ,0852           ,"Numero Documento"             ,oFont06 ,100)
            oPrn:Say(1467       ,0862           ,AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM)                                                                            ,oFont10b,100)
            oPrn:Line(1440      ,1200       ,1520       ,1200       )
            oPrn:Say(1442       ,1202           ,"Especie Documento"            ,oFont06 ,100)
            oPrn:Say(1467       ,1212           ,"DMI"                                                                                                                      ,oFont10b,100)
            oPrn:Line(1440      ,1420       ,1520       ,1420       )
            oPrn:Say(1442       ,1422           ,"Aceite"                       ,oFont06 ,100)
            oPrn:Say(1467       ,1432           ,"A"                                                                                                                        ,oFont10b,100)    
            oPrn:Line(1440      ,1570       ,1520       ,1570       )
            oPrn:Say(1442       ,1572           ,"Data Processamento"           ,oFont06 ,100)
            oPrn:Say(1467       ,1582           ,DtoC(SE1->E1_EMISSAO)                                                                                                      ,oFont10b,100)
            oPrn:Line(1440      ,2000       ,1520       ,2000       )
            oPrn:Say(1442       ,2002           ,"Nosso N๚mero"                 ,oFont06 ,100)
            oPrn:Say(1467       ,2402           ,Transform(SE1->E1_NUMBCO,"@R 99/999999-9")                                                                                 ,oFont10b,100,,,1)

            oPrn:Line(1520      ,0050       ,1520       ,0500       )
            oPrn:Say(1522       ,0052           ,"1 (=) Valor do documento"     ,oFont06 ,100)
            oPrn:Say(1547       ,0500           ,iif(SE1->E1_MOEDA == 1,"R$","") + Transform(_nSaldo,"@E 999,999.99")                                                       ,oFont10b,100,,,1)
            oPrn:Line(1520      ,0535       ,1520       ,2430       )
            oPrn:Say(1522       ,0537           ,"Parcela/Plano"                ,oFont06 ,100)
            oPrn:Say(1547       ,0547           ,AllTrim(SE1->E1_PARCELA)                                                                                                   ,oFont10b,100)
            oPrn:Line(1520      ,0950       ,1600       ,0950       )
            oPrn:Say(1522       ,0952           ,"Esp้cie Moeda"                ,oFont06 ,100)
            oPrn:Say(1547       ,0962           ,iif(SE1->E1_MOEDA == 1,"REAL","")                                                                                          ,oFont10b,100)
            oPrn:Line(1520      ,1200       ,1600       ,1200       )
            oPrn:Say(1522       ,1202           ,"Quantidade Moeda"             ,oFont06 ,100)
            oPrn:Line(1520      ,1600       ,1600       ,1600       )
            oPrn:Say(1522       ,1602           ,"Valor Moeda"                  ,oFont06 ,100)
            oPrn:Line(1520      ,2000       ,1600       ,2000       )
            oPrn:Say(1522       ,2002           ,"Valor Documento"              ,oFont06 ,100)
            oPrn:Say(1547       ,2402           ,iif(SE1->E1_MOEDA == 1,"R$","") + Transform(_nSaldo,"@E 999,999.99")                                                       ,oFont10b,100,,,1)

            oPrn:Line(1600      ,0050       ,1600       ,0500       )
            oPrn:Say(1602       ,0052           ,"2 (-) Desconto/Abatimento"    ,oFont06 ,100)
            oPrn:Line(1600      ,0535       ,1600       ,2430       )
            oPrn:Say(1602       ,0537           ,"Instru็๕es"                   ,oFont06 ,100)
            oPrn:Say(1627       ,0547           ,SubStr(AllTrim(_cMensMult),1,60)                                                                                           ,oFont10 ,100)
            oPrn:Say(1662       ,0547           ,SubStr(AllTrim(_cMensJur),1,60)                                                                                            ,oFont10 ,100)
            oPrn:Say(1697       ,0547           ,SubStr(AllTrim(MsgInstr03),1,60)                                                                                           ,oFont10 ,100)
            oPrn:Say(1732       ,0547           ,SubStr(AllTrim(MsgInstr03),61,60)                                                                                          ,oFont10 ,100)
            oPrn:Line(1600      ,2000       ,1680       ,2000       )
            oPrn:Say(1602       ,2002           ,"(-) Descontos/Abatimentos"    ,oFont06 ,100)

            oPrn:Line(1680      ,0050       ,1680       ,0500       )
            oPrn:Say(1682       ,0052           ,"3 (-) Outras dedu็๕es"        ,oFont06 ,100)
            oPrn:Line(1680      ,2000       ,1680       ,2430       )
            oPrn:Line(1680      ,2000       ,1760       ,2000       )
            oPrn:Say(1682       ,2002           ,"(-) Outras dedu็๕es"          ,oFont06 ,100)

            oPrn:Line(1760      ,0050       ,1760       ,0500       )
            oPrn:Say(1762       ,0052           ,"4 (+) Mora/Multa"             ,oFont06 ,100)
            oPrn:Line(1760      ,2000       ,1760       ,2430       )
            oPrn:Line(1760      ,2000       ,1840       ,2000       )
            oPrn:Say(1762       ,2002           ,"(+) Mora/Multa"               ,oFont06 ,100)

            oPrn:Line(1840      ,0050       ,1840       ,0500       )
            oPrn:Say(1842       ,0052           ,"5 (+) Outros acr้scimos"      ,oFont06 ,100)
            oPrn:Line(1840      ,2000       ,1840       ,2430       )
            oPrn:Line(1840      ,2000       ,1920       ,2000       )
            oPrn:Say(1842       ,2002           ,"(+) Outros acr้scimos"        ,oFont06 ,100)

            oPrn:Line(1920      ,0050       ,1920       ,0500       )
            oPrn:Say(1922       ,0052           ,"6 (=) Valor Cobrado"          ,oFont06 ,100)
            oPrn:Line(1920      ,2000       ,1920       ,2430       )
            oPrn:Line(1920      ,2000       ,2000       ,2000       )
            oPrn:Say(1922       ,2002           ,"(=) Valor Cobrado"            ,oFont06 ,100)

            oPrn:Line(2000      ,0050       ,2000       ,0500       )
            oPrn:Say(2002       ,0052           ,"Nosso N๚mero"                 ,oFont06 ,100)
            oPrn:Say(2027       ,0062           ,Transform(SE1->E1_NUMBCO,"@R 99/999999-9")                                                                                 ,oFont10b,100)
            oPrn:Line(2000      ,0535       ,2000       ,2430       )
            oPrn:Say(2002       ,0537           ,"Pagador"                      ,oFont06 ,100)
            oPrn:Say(2027       ,0547           ,SubStr(AllTrim(SA1->A1_NOME),1,40) + " - " + _cCnpj                                                                        ,oFont10b,100)
            oPrn:Say(2062       ,0547           ,SubStr(AllTrim(_cEndc),1,40) + iif(!Empty(_cCompl)," - " + SubStr(_cCompl,1,15),"") + " - " + SubStr(AllTrim(_cBair),1,20) ,oFont10b,100)
            oPrn:Say(2097       ,0547           ,SubStr(AllTrim(_cMunc),1,40) + "/" + AllTrim(_cEstc) + " - " + AllTrim(_cCEPc)                                             ,oFont10b,100)    

            oPrn:Line(2080      ,0050       ,2080       ,0500       )
            oPrn:Say(2082       ,0052           ,"N๚mero do documento"          ,oFont06 ,100)
            oPrn:Say(2107       ,0062           ,AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM)                                                                            ,oFont10b,100)

            oPrn:Line(2160      ,0050       ,2160       ,0500       )
            oPrn:Say(2162       ,0052           ,"Pagador"                      ,oFont06 ,100)
            oPrn:Say(2187       ,0062           ,SubStr(AllTrim(SE1->E1_NOMCLI),1,30)                                                                                       ,oFont10b,100)    
            oPrn:Line(2160      ,0535       ,2160       ,2430       )
            MSBAR("INT25",18.4,5.2,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.2,NIL,NIL,NIL,.F.)
            oPrn:Say(2162       ,2100           ,"Autentica็ใo Mecโnica"        ,oFont06 ,100)

            oPrn:Line(2260      ,0050       ,2260       ,0500       )
            oPrn:Say(2262       ,0227           ,"Recibo do pagador"            ,oFont08b,100)
            oPrn:Say(2272       ,2100           ,"Ficha de Compensa็ใo"         ,oFont08b,100)
            oPrn:Say(2295       ,0270           ,"Autenticar no verso"          ,oFont06 ,100)

            oPrn:Say(2320       ,0050           ,Replicate("-",440)             ,oFont06 ,100)
        elseif nCount == 3
            nCount++
            oPrn:Line(2350      ,0050       ,2450       ,0050       )
            oPrn:SayBitmap(2350     ,0055       ,cLogoBco       ,0240       ,0100       )
            oPrn:Line(2350      ,0310       ,2450       ,0310       )
            oPrn:Say(2360       ,0320       ,SubStr(cBarra,1,3) + "-" + "X"     ,oFont18b,100)
            oPrn:SayBitmap(2350     ,0535       ,cLogoBco       ,0240       ,0100       )
            oPrn:Line(2350      ,0795       ,2450       ,0795       )
            oPrn:Say(2360       ,0810       ,SubStr(cBarra,1,3) + "-" + "X"     ,oFont18b,100)
            oPrn:Line(2350      ,0995       ,2450       ,0995       )
            oPrn:Say(2382       ,1005       ,cLinha                             ,oFont14 ,150)            

            oPrn:Line(2450      ,0050       ,2450       ,0500       )
            oPrn:Say(2452       ,0052           ,"Parcela/Plano"                ,oFont06 ,100)
            oPrn:Say(2477       ,0062           ,AllTrim(SE1->E1_PARCELA)                                                                                                   ,oFont10b,100)    
            oPrn:Line(2450      ,0225       ,2530       ,0225       )
            oPrn:Say(2452       ,0227           ,"Vencimento"                   ,oFont06 ,100)
            oPrn:Say(2477       ,0237           ,DtoC(SE1->E1_VENCTO)                                                                                                       ,oFont10b,100)
            oPrn:Line(2450      ,0535       ,2450       ,2430       )
            oPrn:Say(2452       ,0537           ,"Local de Pagamento"           ,oFont06 ,100)
            oPrn:Say(2477       ,0547           ,"PAGมVEL PREFERENCIALMENTE EM CANAIS DA SUA INSTITUIวรO FINANCEIRA"                                                        ,oFont10b,100)    
            oPrn:Line(2450      ,2000       ,2530       ,2000       )
            oPrn:Say(2452       ,2002           ,"Vencimento"                   ,oFont06 ,100)
            oPrn:Say(2477       ,2402           ,DtoC(SE1->E1_VENCTO)                                                                                                       ,oFont10b,100,,,1)

            oPrn:Line(2530      ,0050       ,2530       ,0500       )
            oPrn:Say(2532       ,0052           ,"Agencia/C๓d. do Beneficiแrio" ,oFont06 ,100)
            oPrn:Say(2557       ,0062           ,AllTrim(SEE->EE_AGENCIA) + "." + AllTrim(SEE->EE_CODEMP) +  "." + AllTrim(SEE->EE_CONTA)                                   ,oFont10b,100)
            oPrn:Line(2530      ,0535       ,2530       ,2430       )
            oPrn:Say(2532       ,0537           ,"Beneficiแrio"                 ,oFont06 ,100)
            oPrn:Say(2557       ,0547           ,SubStr(AllTrim(SM0->M0_NOMECOM),1,40) + " - C.N.P.J. " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                    ,oFont10b,100)
            oPrn:Line(2530      ,2000       ,2610       ,2000       )
            oPrn:Say(2532       ,2002           ,"Agencia/C๓d. do Beneficiแrio" ,oFont06 ,100)
            oPrn:Say(2557       ,2402           ,AllTrim(SEE->EE_AGENCIA) + "." + AllTrim(SEE->EE_CODEMP) +  "." + AllTrim(SEE->EE_CONTA)                                   ,oFont10b,100,,,1)                

            oPrn:Line(2610      ,0050       ,2610       ,0500       )
            oPrn:Say(2612       ,0052           ,"Especie Moeda"                ,oFont06 ,100)
            oPrn:Say(2637       ,0062           ,iif(SE1->E1_MOEDA == 1,"REAL","")                                                                                          ,oFont10b,100)
            oPrn:Line(2610      ,0225       ,2690       ,0225       )
            oPrn:Say(2612       ,0227           ,"Quantidade Moeda"             ,oFont06 ,100)
            oPrn:Line(2610      ,0535       ,2610       ,2430       )
            oPrn:Say(2612       ,0537           ,"Data Documento"               ,oFont06 ,100)
            oPrn:Say(2637       ,0547           ,DtoC(SE1->E1_EMISSAO)                                                                                                      ,oFont10b,100)
            oPrn:Line(2610      ,0850       ,2690       ,0850       )
            oPrn:Say(2612       ,0852           ,"Numero Documento"             ,oFont06 ,100)
            oPrn:Say(2637       ,0862           ,AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM)                                                                            ,oFont10b,100)
            oPrn:Line(2610      ,1200       ,2690       ,1200       )
            oPrn:Say(2612       ,1202           ,"Especie Documento"            ,oFont06 ,100)
            oPrn:Say(2637       ,1212           ,"DMI"                                                                                                                      ,oFont10b,100)
            oPrn:Line(2610      ,1420       ,2690       ,1420       )
            oPrn:Say(2612       ,1422           ,"Aceite"                       ,oFont06 ,100)
            oPrn:Say(2637       ,1432           ,"A"                                                                                                                        ,oFont10b,100)    
            oPrn:Line(2610      ,1570       ,2690       ,1570       )
            oPrn:Say(2612       ,1572           ,"Data Processamento"           ,oFont06 ,100)
            oPrn:Say(2637       ,1582           ,DtoC(SE1->E1_EMISSAO)                                                                                                      ,oFont10b,100)
            oPrn:Line(2610      ,2000       ,2690       ,2000       )
            oPrn:Say(2612       ,2002           ,"Nosso N๚mero"                 ,oFont06 ,100)
            oPrn:Say(2637       ,2402           ,Transform(SE1->E1_NUMBCO,"@R 99/999999-9")                                                                                 ,oFont10b,100,,,1)

            oPrn:Line(2690      ,0050       ,2690       ,0500       )
            oPrn:Say(2692       ,0052           ,"1 (=) Valor do documento"     ,oFont06 ,100)
            oPrn:Say(2717       ,0500           ,iif(SE1->E1_MOEDA == 1,"R$","") + Transform(_nSaldo,"@E 999,999.99")                                                       ,oFont10b,100,,,1)
            oPrn:Line(2690      ,0535       ,2690       ,2430       )
            oPrn:Say(2692       ,0537           ,"Parcela/Plano"                ,oFont06 ,100)
            oPrn:Say(2717       ,0547           ,AllTrim(SE1->E1_PARCELA)                                                                                                   ,oFont10b,100)
            oPrn:Line(2690      ,0950       ,2770       ,0950       )
            oPrn:Say(2692       ,0952           ,"Esp้cie Moeda"                ,oFont06 ,100)
            oPrn:Say(2717       ,0962           ,iif(SE1->E1_MOEDA == 1,"REAL","")                                                                                          ,oFont10b,100)
            oPrn:Line(2690      ,1200       ,2770       ,1200       )
            oPrn:Say(2692       ,1202           ,"Quantidade Moeda"             ,oFont06 ,100)
            oPrn:Line(2690      ,1600       ,2770       ,1600       )
            oPrn:Say(2692       ,1602           ,"Valor Moeda"                  ,oFont06 ,100)
            oPrn:Line(2690      ,2000       ,2770       ,2000       )
            oPrn:Say(2692       ,2002           ,"Valor Documento"              ,oFont06 ,100)
            oPrn:Say(2717       ,2402           ,iif(SE1->E1_MOEDA == 1,"R$","") + Transform(_nSaldo,"@E 999,999.99")                                                       ,oFont10b,100,,,1)

            oPrn:Line(2770      ,0050       ,2770       ,0500       )
            oPrn:Say(2772       ,0052           ,"2 (-) Desconto/Abatimento"    ,oFont06 ,100)
            oPrn:Line(2770      ,0535       ,2770       ,2430       )
            oPrn:Say(2772       ,0537           ,"Instru็๕es"                   ,oFont06 ,100)
            oPrn:Say(2795       ,0547           ,SubStr(AllTrim(_cMensMult),1,60)                                                                                           ,oFont10 ,100)
            oPrn:Say(2830       ,0547           ,SubStr(AllTrim(_cMensJur),1,60)                                                                                            ,oFont10 ,100)
            oPrn:Say(2865       ,0547           ,SubStr(AllTrim(MsgInstr03),1,60)                                                                                           ,oFont10 ,100)
            oPrn:Say(2900       ,0547           ,SubStr(AllTrim(MsgInstr03),61,60)                                                                                          ,oFont10 ,100)
            oPrn:Line(2770      ,2000       ,2850       ,2000       )
            oPrn:Say(2772       ,2002           ,"(-) Descontos/Abatimentos"    ,oFont06 ,100)

            oPrn:Line(2850      ,0050       ,2850       ,0500       )
            oPrn:Say(2852       ,0052           ,"3 (-) Outras dedu็๕es"        ,oFont06 ,100)
            oPrn:Line(2850      ,2000       ,2850       ,2430       )
            oPrn:Line(2850      ,2000       ,2930       ,2000       )
            oPrn:Say(2852       ,2002           ,"(-) Outras dedu็๕es"          ,oFont06 ,100)

            oPrn:Line(2930      ,0050       ,2930       ,0500       )
            oPrn:Say(2932       ,0052           ,"4 (+) Mora/Multa"             ,oFont06 ,100)
            oPrn:Line(2930      ,2000       ,2930       ,2430       )
            oPrn:Line(2930      ,2000       ,3010       ,2000       )
            oPrn:Say(2932       ,2002           ,"(+) Mora/Multa"               ,oFont06 ,100)

            oPrn:Line(3010      ,0050       ,3010       ,0500       )
            oPrn:Say(3012       ,0052           ,"5 (+) Outros acr้scimos"      ,oFont06 ,100)
            oPrn:Line(3010      ,2000       ,3010       ,2430       )
            oPrn:Line(3010      ,2000       ,3090       ,2000       )
            oPrn:Say(3012       ,2002           ,"(+) Outros acr้scimos"        ,oFont06 ,100)

            oPrn:Line(3090      ,0050       ,3090       ,0500       )
            oPrn:Say(3092       ,0052           ,"6 (=) Valor Cobrado"          ,oFont06 ,100)
            oPrn:Line(3090      ,2000       ,3090       ,2430       )
            oPrn:Line(3090      ,2000       ,3180       ,2000       )
            oPrn:Say(3092       ,2002           ,"(=) Valor Cobrado"            ,oFont06 ,100)

            oPrn:Line(3180      ,0050       ,3180       ,0500       )
            oPrn:Say(3182       ,0052           ,"Nosso N๚mero"                 ,oFont06 ,100)
            oPrn:Say(3207       ,0062           ,Transform(SE1->E1_NUMBCO,"@R 99/999999-9")                                                                                 ,oFont10b,100)
            oPrn:Line(3180      ,0535       ,3180       ,2430       )
            oPrn:Say(3182       ,0537           ,"Pagador"                      ,oFont06 ,100)
            oPrn:Say(3207       ,0547           ,SubStr(AllTrim(SA1->A1_NOME),1,40) + " - " + _cCnpj                                                                        ,oFont10b,100)
            oPrn:Say(3242       ,0547           ,SubStr(AllTrim(_cEndc),1,40) + iif(!Empty(_cCompl)," - " + SubStr(_cCompl,1,15),"") + " - " + SubStr(AllTrim(_cBair),1,20) ,oFont10b,100)
            oPrn:Say(3277       ,0547           ,SubStr(AllTrim(_cMunc),1,40) + "/" + AllTrim(_cEstc) + " - " + AllTrim(_cCEPc)                                             ,oFont10b,100)    

            oPrn:Line(3260      ,0050       ,3260       ,0500       )
            oPrn:Say(3262       ,0052           ,"N๚mero do documento"          ,oFont06 ,100)
            oPrn:Say(3287       ,0062           ,AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM)                                                                            ,oFont10b,100)

            oPrn:Line(3340      ,0050       ,3340       ,0500       )
            oPrn:Say(3342       ,0052           ,"Pagador"                      ,oFont06 ,100)
            oPrn:Say(3367       ,0062           ,SubStr(AllTrim(SE1->E1_NOMCLI),1,30)                                                                                       ,oFont10b,100)    
            oPrn:Line(3340      ,0535       ,3340       ,2430       )
            MSBAR("INT25",28.4,5.2,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.2,NIL,NIL,NIL,.F.)
            oPrn:Say(3342       ,2100           ,"Autentica็ใo Mecโnica"        ,oFont06 ,100)

            oPrn:Line(3440      ,0050       ,3440       ,0500       )
            oPrn:Say(3442       ,0227           ,"Recibo do pagador"            ,oFont08b,100)
            oPrn:Say(3452       ,2100           ,"Ficha de Compensa็ใo"         ,oFont08b,100)
            oPrn:Say(3475       ,0270           ,"Autenticar no verso"          ,oFont06 ,100)
        endif
        cPrefixo    := SE1TMP->E1_PREFIXO
        cNumTitulo  := SE1TMP->E1_NUM
        dbSelectArea("SE1TMP")
        SE1TMP->(dbSkip())       
    enddo
    oPrn:EndPage()  
enddo
dbSelectArea("SE1TMP")
SE1TMP->(dbCloseArea())
oPrn:Preview()
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ CalcDVCL  บAutor ณ Rodrigo Telecio         Data ณ20/07/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Calculo do digito verificador do campo livre                นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Programa principal                                          นฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
static function CalcDVCL(cTempBar)
local _nX           := 0
local _nSeq			:= 0
local _aSeq         := {9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
Local _nSomaTot		:= 0
Local _cDac			:= ""
for _nX := 1 to Len(AllTrim(cTempBar))
	if _nSeq == Len(_aSeq)
		_nSeq   := 0
	endif
    _nSeq++
	_nSomaTot   += Val(SubStr(AllTrim(cTempBar),_nX,1)) * _aSeq[_nSeq]
next _nX
if MOD(_nSomaTot,11) <> 0
	_cDac := AllTrim(Str((11 - (MOD(_nSomaTot,11)))))
else
	_cDac := AllTrim(Str(0))
endif
Return(_cDac)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ CalcLinDig  บAutor ณ Rodrigo Telecio       Data ณ20/07/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Calculo do digito verificador do campo livre                นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Programa principal                                          นฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
static function CalcLinDig()
local _nX           := 0
local _nY           := 0
local _aSeq         := {2,1}
local _nSeq         := 0
local _nRegCont     := 0
local _nSomaDg      := 0
local _nSomaTot     := 0
for _nX := 1 to 3
	_nSeq      := 0
	_nRegCont  := 0
	_nSomaDg   := 0
	_nSomaTot  := 0
	if _nX == 1
		//Cแlculo do Primeiro Campo
		cLinha    := SubStr(cBarra,1,4)
		cLinha    += SubStr(cBarra,20,1) + "." + SubStr(cBarra,21,4)
		_nSeq     := 0
		_nRegCont := Len(AllTrim(cLinha))
	elseif _nX == 2
		//Cแlculo do Segundo Campo
		cLinha    := SubStr(cBarra,25,5) + "." + SubStr(cBarra,30,5)
		_nSeq     := 0
		_nRegCont := Len(AllTrim(cLinha))
	elseif _nX == 3
		//Cแlculo do Terceiro Campo
		cLinha    := SubStr(cBarra,35,5) + "." + SubStr(cBarra,40,5)
		_nSeq     := 0
		_nRegCont := Len(AllTrim(cLinha))
	endif
	for _nY := 1 to _nRegCont
		if SubStr(cLinha,((_nRegCont-_nY) + 1),1) == "."
			loop
		endif
		if _nSeq == Len(_aSeq)
			_nSeq := 0
		endif
		_nSeq++                                
		_nSomaDg  := Val(SubStr(AllTrim(cLinha),((_nRegCont-_nY) + 1),1)) * _aSeq[_nSeq]
		if _nSomaDg <= 9
			_nSomaTot += _nSomaDg
		else	
			_nSomaTot += Val(Substr(cValToChar(_nSomaDg),1,1)) + Val(Substr(cValToChar(_nSomaDg),2,1))
		endif
	next _nY
	if MOD(_nSomaTot,10) <> 0
		_cDv := (10 - (MOD(_nSomaTot,10)))
	else
		_cDv := 0
	endif
	&("cLinha" + cValToChar(_nX)) := cLinha + cValToChar(_cDv) + Space(01)
Next _nX
if Type("cLinha1") <> "U" .AND. Type("cLinha2") <> "U" .AND. Type("cLinha3") <> "U"
	cLinha := cLinha1 + cLinha2 +cLinha3 + SubStr(cBarra,5,1) + Space(01) + SubStr(cBarra,6,14)
else
    Aviso('TOTVS','Problemas na composi็ใo da linha digitแvel. Contate o administrador.',{'OK'},3,'Cancelamento de opera็ใo')
endif
Return(cLinha)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPerg  บAutor  ณRodrigo Telecio   บ Data ณ  20/07/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsavel por criar as perguntas utilizadas no    บฑฑ
ฑฑบ          ณ relat๓rio                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidPerg()
local aAlias 	:= GetArea()
local aRegs   	:= {}
local lOpen	    := .F.
local cAliasSX1 := "SX1"
local _aTam     := {}
local _x,_y
cPerg 			:= PADR(cPerg,10)
_aTam := TamSx3("E1_PREFIXO")
aAdd(aRegs,{cPerg,"01","Prefixo de?"        ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"02","Prefixo ate?"       ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_NUM"    )
aAdd(aRegs,{cPerg,"03","Numero de?"         ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"04","Numero ate?"        ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_NUMBOR" )
aAdd(aRegs,{cPerg,"05","Bordero de?"        ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"06","Bordero ate?"       ,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_EMISSAO")
aAdd(aRegs,{cPerg,"07","Emissao de?"        ,"","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par07",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"08","Emissao ate?"       ,"","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par08",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("E1_VENCTO" )
aAdd(aRegs,{cPerg,"09","Vencimento de?"     ,"","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par09",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"10","Vencimento ate?"    ,"","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par10",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("EE_CODIGO" )
aAdd(aRegs,{cPerg,"11","Banco?"             ,"","","mv_chb",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par11",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA6","",""})
_aTam := TamSx3("EE_AGENCIA")
aAdd(aRegs,{cPerg,"12","Agencia?"           ,"","","mv_chc",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par12",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("EE_CONTA"  )
aAdd(aRegs,{cPerg,"13","Conta?"             ,"","","mv_chd",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par13",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
_aTam := TamSx3("EE_SUBCTA" )
aAdd(aRegs,{cPerg,"14","Sub-Conta?"         ,"","","mv_che",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par14",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"15","Msg 01 p/ boleto?"  ,"","","mv_chf","C"      ,60       ,0        ,0,"G",""          ,"mv_par15",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{cPerg,"16","Msg 02 p/ boleto?"  ,"","","mv_chg","C"      ,60       ,0        ,0,"G",""          ,"mv_par16",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
cAliasSX1 		:= "SX1"
//OpenSXS(Nil,Nil,Nil,Nil,FWCodEmp(),cAliasSX1,"SX1",Nil,.F.)
lOpen			:= Select(cAliasSX1) > 0
//if lOpen
	for _x := 1 to Len(aRegs)
		dbSelectArea((cAliasSX1))
		(cAliasSX1)->(dbSetOrder(1))
		if !(cAliasSX1)->(MsSeek(cPerg + aRegs[_x,2],.T.,.F.))
			Reclock("SX1",.T.)
			for _y := 1 to FCount()
				if _y <= Len(aRegs[_x])
					FieldPut(_y,aRegs[_x,_y])
				else              
					exit
				endif
			next _y 
			(cAliasSX1)->(MsUnlock())
		endif
	next _x
//endif
RestArea(aAlias)
return
