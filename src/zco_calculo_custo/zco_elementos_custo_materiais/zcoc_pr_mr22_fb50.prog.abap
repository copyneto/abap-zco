***********************************************************************
***                        © 3corações                              ***
***********************************************************************
*** DESCRIÇÃO: Processamento de MR22 e FB50 NFs
*** AUTOR : Davi Ferreira – GFX
*** FUNCIONAL: Romulo Bezerra – 3C
*** DATA : 21/12/2022d
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES
***-------------------------------------------------------------------*
*** DATA | AUTOR | DESCRIÇÃO
***-------------------------------------------------------------------*
*** | |
***********************************************************************

REPORT zcoc_pr_mr22_fb50.

***********
*&Includes*
***********
INCLUDE zcoc_pr_mr22_fb50top."Declarações globais
INCLUDE zcoc_pr_mr22_fb50scr."Telas
INCLUDE zcoc_pr_mr22_fb50cls."Implementação de classes

*********************
*&START-OF-SELECTION*
*********************
START-OF-SELECTION.

  TRY.

      lcl_main=>instance( )->start( ).

    CATCH lcx_exception INTO DATA(lo_cx).

      "----Exibindo mensagem de erro
      lcl_main=>handle_error( lo_cx ).


  ENDTRY.
