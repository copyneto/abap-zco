@EndUserText.label: 'Unidade de Medida Gerencial'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_CO_UM_GEREN
  as projection on ZI_CO_UM_GEREN
{
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CO_FAMILIA_CL',
              element: 'Wwmt1'
          } } ]
  key Wwmt1,
      Vv030,
      Vv031,
      Vv032,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_UM',
              element: 'Unit'
          } } ]
      Vv030Me,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_UM',
              element: 'Unit'
          } } ]
      Vv031Me,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_UM',
              element: 'Unit'
          } } ]
      Vv032Me,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
