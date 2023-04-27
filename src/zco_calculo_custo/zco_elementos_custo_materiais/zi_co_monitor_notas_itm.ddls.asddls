@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Monitor NF CO - Lanç MR22 FB50-Item'
//Interface
define view entity ZI_CO_MONITOR_NOTAS_ITM
  as select from ztco_notas_itm as NFItem
  //Itens da nota
  association        to parent ZI_CO_MONITOR_NOTAS_CAB as _NFHeader on $projection.NFDocument = _NFHeader.NFDocument
  //Nota Fiscal
  association [1..1] to I_BR_NFDocument                as _Doc      on $projection.NFDocument = _Doc.BR_NotaFiscal
{
  key docnum   as NFDocument,
  key itmnum   as NFItem,
  key taxgrp   as NFTaxGrp,
  key taxtyp   as NFTaxTyp,
      werks    as Center,
      matnr    as Material,
      bwtar    as ValuationType,
      @Semantics.amount.currencyCode : 'SalesDocumentCurrency'
      taxval   as TaxValue,
      refkey   as ReferenceKey,
      mwskz    as TaxCode,
      xped     as PurchaseOrder,
      nitemped as PurchaseOrderItem,
      xblnr    as ReferenceKeyDoc,
      bln_c_fb as AccountingDocument,
      gjr_c_fb as AccountingYear,
      bln_c_mr as MrDocument,
      gjr_c_mr as MrYear,
      bln_s_fb as ReversalDocument,
      gjr_s_fb as ReversalYear,
      bln_s_mr as MrRevDocument,
      gjr_s_mr as MrRevYear,
      user_mod as LastUserChange,  
      date_mod as LastDateChange,  
      time_mod as LastTimeChange,  
      text_msg as MessageTextInfor, 
      _Doc.SalesDocumentCurrency,

      //*Associations*//
      _NFHeader,
      _Doc
}
