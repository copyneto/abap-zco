class ZCLCO_CL_SI_GRAVAR_VALORES_COM definition
  public
  create public .

public section.

  interfaces ZCLCO_II_SI_GRAVAR_VALORES_COM .
protected section.
private section.
ENDCLASS.



CLASS ZCLCO_CL_SI_GRAVAR_VALORES_COM IMPLEMENTATION.


  METHOD zclco_ii_si_gravar_valores_com~si_gravar_valores_comissao_in.

    DATA: lt_valr TYPE STANDARD TABLE OF zsco_post_copa.

    DATA: ls_valr TYPE zsco_post_copa.

*    CHECK 1 = 2.

    DATA(lo_copa) = NEW zclco_mercanet_copa( ).

    LOOP AT input-mt_valores_comissao-rows ASSIGNING FIELD-SYMBOL(<fs_rows>).

      ls_valr-budat = <fs_rows>-budat.
      ls_valr-werks = <fs_rows>-werks.
      ls_valr-wwmt1 = <fs_rows>-wwmt1.
      ls_valr-wwrps = <fs_rows>-wwrps.
      ls_valr-vtweg = <fs_rows>-vtweg.
      ls_valr-bzirk = <fs_rows>-bzirk.
      ls_valr-wwrep = <fs_rows>-wwrep.
      ls_valr-vv004 = <fs_rows>-vv004.
      APPEND ls_valr TO lt_valr.
      CLEAR ls_valr.

    ENDLOOP.

    IF lt_valr[] IS NOT INITIAL.
      lo_copa->create_copa( EXPORTING it_lanc_copa = lt_valr ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
