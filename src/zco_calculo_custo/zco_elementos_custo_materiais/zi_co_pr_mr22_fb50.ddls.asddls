@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados para processamento MR22 e FB50'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CO_PR_MR22_FB50

  //*Cabeçalho da nota*//
  as select from    j_1bnfdoc        as _doc

  //*Itens da nota*//
    inner join      j_1bnflin        as _fln   on _doc.docnum = _fln.docnum
    inner join      j_1bnfstx        as _stx   on  _fln.docnum = _stx.docnum
                                               and _fln.itmnum = _stx.itmnum

  //*Configurações*//
    inner join      ztco_cfg_elmcust as _cfg   on  _fln.mwskz  = _cfg.mwskz
                                               and _stx.taxgrp = _cfg.taxgrp
                                               and _stx.taxtyp = _cfg.taxtyp

  //*Verificação para período de custo permitido*//
    inner join      marv             as _mrv   on _doc.bukrs = _mrv.bukrs

  //*Informação se parceiro é coligada*//
    left outer join lfb1             as _fb1   on  _doc.parid = _fb1.lifnr
                                               and _doc.bukrs = _fb1.bukrs

  //*Dados dos processos já executados*//
    left outer join ztco_notas_cab   as _cab   on _doc.docnum = _cab.docnum
    left outer join ztco_notas_itm   as _itm   on  _stx.docnum = _itm.docnum
                                               and _stx.itmnum = _itm.itmnum
                                               and _stx.taxgrp = _itm.taxgrp
                                               and _stx.taxtyp = _itm.taxtyp

  //Dados do centro para notas de transferência
    left outer join ekpo             as _POitm on  _POitm.ebeln = _fln.xped
                                               and _POitm.ebelp = _fln.nitemped
{
      //*Notas Fiscal*//
  key _doc.docnum                    as NFDocument,
  key _stx.itmnum                    as NFItem,
  key _stx.taxgrp                    as NFTaxGrp,
  key _stx.taxtyp                    as NFTaxTyp,
      @Semantics.amount.currencyCode : 'Currency'
      _stx.taxval                    as TaxValue,
      _doc.bukrs                     as CompanyCode,
      _doc.pstdat                    as ReleaseDate,
      substring( _doc.pstdat, 5, 2 ) as PeriodMonth,
      left( _doc.pstdat, 4 )         as PeriodYear,
      _doc.parid                     as PartnerID,
      _doc.nfenum                    as NFENumber,
      _doc.waerk                     as Currency,
      _doc.direct                    as Direction,
      _doc.cancel                    as Canceled,
      _fln.werks                     as Center,
      _fln.matnr                     as Material,
      _fln.meins                     as Quantity,
      _fln.bwtar                     as ValuationType,
      _fln.bwkey                     as EvaluationArea,
      _fln.refkey                    as ReferenceKey,
      _fln.mwskz                     as TaxCode,
      _fln.xped                      as PurchaseOrder,
      _fln.nitemped                  as PurchaseOrderItem,

      //*Informação sobre o fornecedor*//
      case when _fb1.fdgrv = 'A27'
        then 'X'
      else ' ' end                   as IsAffiliated,

      //*Configuração*//
      _cfg.elemento                  as ReferenceKeyDoc,
      _cfg.mr22                      as ExecMr22,
      _cfg.sinal                     as Sign,
      _cfg.fb50                      as ExecFb50,
      _cfg.hkont_d                   as DebitAccount,
      _cfg.hkont_c                   as CreditAccount,
      _cfg.blart                     as TypeDoc,

      //*Lançamentos*//
      _cab.status                    as Status,
      _itm.bln_c_fb                  as AccountingDocument,
      _itm.gjr_c_fb                  as AccountingYear,
      _itm.bln_c_mr                  as MrDocument,
      _itm.gjr_c_mr                  as MrYear,
      _itm.bln_s_fb                  as ReversalDocument,
      _itm.gjr_s_fb                  as ReversalYear,
      _itm.bln_s_mr                  as MrRevDocument,
      _itm.gjr_s_mr                  as MrRevYear,
      _itm.user_mod                  as LastUserChange,
      _itm.date_mod                  as LastDateChange,
      _itm.time_mod                  as LastTimeChange,
      _itm.text_msg                  as MessageTextInfor,
      
      //*Pedido Transferência
      _POitm.werks                   as TransferCenter

}
where
  //*Verificação para período de custo permitido*//
  (
        left( _doc.pstdat, 4 )         = _mrv.lfgja
    and substring( _doc.pstdat, 5, 2 ) = _mrv.lfmon
  )
  or(
        left( _doc.pstdat, 4 )         = _mrv.vmgja
    and substring( _doc.pstdat, 5, 2 ) = _mrv.vmmon
    and _mrv.xruem                     = 'X'
  )
