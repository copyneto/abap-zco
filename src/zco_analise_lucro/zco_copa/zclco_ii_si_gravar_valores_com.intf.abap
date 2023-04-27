interface ZCLCO_II_SI_GRAVAR_VALORES_COM
  public .


  methods SI_GRAVAR_VALORES_COMISSAO_IN
    importing
      !INPUT type ZCLCO_MT_VALORES_COMISSAO
    raising
      ZCLCO_CX_FMT_VALORES_COMISSAO .
endinterface.
