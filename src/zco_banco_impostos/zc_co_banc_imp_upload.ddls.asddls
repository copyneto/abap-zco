@EndUserText.label: 'Log de uploads Banco de Impostos'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_CO_BANC_IMP_UPLOAD
  as projection on ZI_CO_BANC_IMP_UPLOAD as BancImpUpload
{
  key Guid,
      FileDirectory,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZI_CO_VH_STATUS_BC_IMP_UP', element: 'Status' } }]
      @ObjectModel.text.element: ['Description']
      Status,
      _Status.Description,
      Criticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,

      //*Associações*//
      _BancImpProcess : redirected to composition child ZC_CO_BANC_IMP_PROCESS,
      _Status

}
