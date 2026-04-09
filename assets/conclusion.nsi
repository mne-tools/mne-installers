# Combine
# https://github.com/conda/constructor/blob/162a5cda86e94ca27a87cd3e7d205184e90a7f19/examples/customized_welcome_conclusion/custom_welcome.nsi#L4
# https://nsis.sourceforge.io/LoadRTF

!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipPageIfUACInnerInstance

!include "nsDialogs.nsh"
!include "LoadRTF.nsh"

Page Custom muiExtraPages_Create

Var hwnd

Function muiExtraPages_Create
    Push $0

    !insertmacro MUI_HEADER_TEXT_PAGE "${PRODUCT_NAME}" "Finished"

    /* Create dialog */
    nsDialogs::Create /NOUNLOAD 1018

    /* Create control */
    nsDialogs::CreateControl "RichEdit20A" ${ES_READONLY}|${WS_VISIBLE}|${WS_CHILD}|${WS_TABSTOP}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_WANTRETURN} ${WS_EX_STATICEDGE} 0 0 100% 100% ''
    Pop $hwnd

    /* Load an RTF file into the control */
    ${LoadRTF} "$PLUGINSDIR\conclusion.rtf" $hwnd

    nsDialogs::Show

    Pop $0
FunctionEnd

!insertmacro MUI_PAGE_FINISH
