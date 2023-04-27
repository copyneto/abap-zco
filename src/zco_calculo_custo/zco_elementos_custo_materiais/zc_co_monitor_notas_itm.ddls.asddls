@EndUserText.label: 'Monitor NF CO - Lanç MR22 FB50 - Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_CO_MONITOR_NOTAS_ITM
  as projection on ZI_CO_MONITOR_NOTAS_ITM as NFItem
{
  key NFDocument,
  key NFItem,
  key NFTaxGrp,
  key NFTaxTyp,
      Center,
      Material,
      ValuationType,
      TaxValue,
      ReferenceKey,
      TaxCode,
      PurchaseOrder,
      PurchaseOrderItem,
      ReferenceKeyDoc,
      AccountingDocument,
      AccountingYear,
      MrDocument,
      MrYear,
      ReversalDocument,
      ReversalYear,
      MrRevDocument,
      MrRevYear,
      LastUserChange,
      LastDateChange,
      LastTimeChange,
      MessageTextInfor,
      SalesDocumentCurrency,

      /* Associations */
      _Doc,
      _NFHeader : redirected to parent ZC_CO_MONITOR_NOTAS_CAB
}
