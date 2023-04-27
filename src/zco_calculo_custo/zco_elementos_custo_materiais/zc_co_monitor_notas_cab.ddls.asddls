@EndUserText.label: 'Monitor NF CO - Lanç MR22 FB50-Cabeçalho'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_CO_MONITOR_NOTAS_CAB
  as projection on ZI_CO_MONITOR_NOTAS_CAB as NFHeader
{
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_BR_NFDocument', element: 'BR_NotaFiscal' } }]
  key NFDocument,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
      @ObjectModel.text.element: ['CompanyCodeName']
      CompanyCode,
      _Company.CompanyCodeName,
      @Consumption.filter.mandatory: true
      ReleaseDate,
      PartnerID,
      NFENumber,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZI_CO_VH_STATUS', element: 'Status' } }]
      @ObjectModel.text.element: ['Description']
      Status,
      _Status.Description,
      Criticality,

      /* Associations */
      _NFItem : redirected to composition child ZC_CO_MONITOR_NOTAS_ITM,
      _Status,
      _Company
      
}
