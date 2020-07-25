#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'
#include 'totvs.ch'
/*/{Protheus.doc} FA60BDE
Ponto de entrada para gravação de dados complementares na montagem do borderô, aplicando a gravação do "Nosso Número" do Banco Sicredi de acordo com a parametrização disponibilizada pelo banco.
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 20/07/2020
@version P12.1.25
@type Function	
@param nil, nulo, nenhum
@return nulo, nil  
@obs Sem observações até o momento 
@see https://allss.com.br/
@history 20/07/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Aplicação no ambiente de produção.
/*/
user function FA60BDE()
local aAreaSE1      := SE1->(GetArea())
local aAreaSE5      := SE5->(GetArea())
local aAreaSEA      := SEA->(GetArea())
local aAreaSEE      := SEE->(GetArea())
local _nQtPos       := ""
local _cNewSq       := ""
local _x            := 0
local _cNum         := ""
local _nRegCont     := 0
local _aSeq         := {4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
local _nSeq         := 0
local _nSomaTot     := 0
local NOSSONUM      := ""
if SA6->A6_COD $ '748'
    dbSelectArea("SE1")
    aAreaSE1 := SE1->(GetArea())
    dbSelectArea("SEE")
    aAreaSEE := SEE->(GetArea())
    dbSelectArea("SEE")
    dbSetOrder(1)
    if !msSeek(xFilial("SEE") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON + SA6->A6_CARTEIR)
        Aviso('TOTVS','Arquivo de parâmetros banco/CNAB incorreto. Verifique banco/agência/conta/sub-conta.',{'OK'},3,'Cancelamento de operação')
        return
        RestArea(aAreaSEE)
        RestArea(aAreaSEA)
        RestArea(aAreaSE5)
        RestArea(aAreaSE1)    
    elseif Upper(AllTrim(SEE->EE_EXTEN)) <> "REM"
        Aviso('TOTVS','Dados de parâmetros banco/CNAB não se referem a configuração de REMESSA!',{'OK'},3,'Cancelamento de operação')
        return
        RestArea(aAreaSEE)
        RestArea(aAreaSEA)
        RestArea(aAreaSE5)
        RestArea(aAreaSE1)    
    elseif Empty(AllTrim(SEE->EE_FAXATU)) .OR. Empty(AllTrim(SEE->EE_FAXINI))
        Aviso('TOTVS','Atenção! A faixa atual e/ou inicial não estão preenchidas no parâmetro de Bancos. '                                   +;
                    'Não será possível definir o "Nosso Número" para o título' + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + '. '   +;
                    'Solicite a correção da informação no cadastro de parâmetro de bancos antes de prosseguir!',{'OK'},3,'Cancelamento de operação')
        return
        RestArea(aAreaSEE)
        RestArea(aAreaSEA)
        RestArea(aAreaSE5)
        RestArea(aAreaSE1)    
    endif
    if type("_cAg") == "U"
        _cAg        := SEE->EE_AGENCIA
    endif
    if type("_cCC") == "U"
        _cCC        := SEE->EE_CONTA
    endif
    if type("_cCP") == "U"
        _cCP        := AllTrim(SEE->EE_CODEMP)
    endif
    //Verifico se já não existe nosso número no título
    if !Empty(AllTrim(SE1->E1_NUMBCO))
        NOSSONUM    := Substr(AllTrim(SE1->E1_NUMBCO),1,8)
    else
        _nQtPos     := Len(AllTrim(SEE->EE_FAXATU))
        _cNewSq     := StrZero(Val(SEE->EE_FAXATU) + 1,_nQtPos)
        if Val(_cNewSq) >= Val(SEE->EE_FAXFIM)
            Aviso('TOTVS','A sequência do "Nosso Número" atingirá a faixa máxima permitida. Portanto, ela será reiniciada para ' + SEE->EE_FAXINI + '.',{'OK'},3,'Cancelamento de operação')
            RecLock("SEE",.F.)
            SEE->EE_FAXATU  := SEE->EE_FAXINI
            SEE->(MsUnLock())
            _cNewSq     := StrZero(Val(SEE->EE_FAXATU),_nQtPos)
        EndIf
        NOSSONUM        := AllTrim(_cNewSq)
    endif
    //Realizo a verificação do nosso número.
    if Empty(Alltrim(NOSSONUM))
        Aviso('TOTVS','Atenção! Não foi possível calcular o "Nosso Número" para o título ' + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + '. Portanto, ao imprimir esse título ele estará incompleto.',{'OK'},3,'Cancelamento de operação')
        return
        RestArea(aAreaSEE)
        RestArea(aAreaSEA)
        RestArea(aAreaSE5)
        RestArea(aAreaSE1)    
    Else
        _cNum           := StrZero(Val(_cAg),4) + StrZero(Val(_cCP),2) + StrZero(Val(_cCC),5) + AllTrim(NOSSONUM)
        _nRegCont       := Len(_cNum)
        for _x := 1 To _nRegCont
            if _nSeq == Len(_aSeq)
                _nSeq   := 0
            endif
            _nSeq++
            _nSomaTot   += Val(SubStr(AllTrim(_cNum),_x,1)) * _aSeq[_nSeq]
        next _x
        if MOD(_nSomaTot,11) <> 0
            _nResto     := iif(AllTrim(Str((11 - (MOD(_nSomaTot,11))))) == 10,"0",AllTrim(Str((11 - (MOD(_nSomaTot,11))))))
        else
            _nResto     := AllTrim(Str(0))
        endif
        RecLock("SE1",.F.)
        SE1->E1_NUMBCO  := AllTrim(NOSSONUM) + _nResto
        SE1->(MsUnLock())
        RecLock("SEE",.F.)
        SEE->EE_FAXATU  := AllTrim(NOSSONUM)
        SE1->(MsUnLock())        
    endif
endif
RestArea(aAreaSEE)
RestArea(aAreaSEA)
RestArea(aAreaSE5)
RestArea(aAreaSE1)
return
