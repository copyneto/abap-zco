*&---------------------------------------------------------------------*
*& Include zcoc_pr_bc_imp_copa
*&---------------------------------------------------------------------*

    "---Types
    TYPES: BEGIN OF ty_s_doc,
             belnr TYPE belnr_D,
             gjahr TYPE gjahr,
           END OF ty_s_doc.
    "---Field-Symbols
    FIELD-SYMBOLS: <fs_line> TYPE any.

    "---Estruturas
    DATA: ls_ce1ar3c TYPE ce1ar3c,
          ls_copa    TYPE ty_s_doc.

    "---Variáveis
    DATA: lv_program  TYPE char2.

    "---Recupera dados para verificar a execução
    IMPORT lv_program = lv_program FROM MEMORY ID 'ZBANC_IMP'.

    "---Checa e faz recuperação do documento gerado
    IF lv_program = |BC|.

      FREE MEMORY ID 'ZBANC_IMP'.

      ASSIGN line_item_tab TO <fs_line>.

      IF <fs_line> IS ASSIGNED.

        MOVE-CORRESPONDING <fs_line> TO ls_ce1ar3c.

        ls_copa = VALUE #( belnr = ls_ce1ar3c-belnr
                           gjahr = ls_ce1ar3c-gjahr ).

        EXPORT ls_copa = ls_copa TO MEMORY ID 'ZBANC_IMP_COPA'.

      ENDIF.

    ENDIF.
