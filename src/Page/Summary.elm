module Page.Summary exposing (viewDesktop, viewMobile)

import Dict
import Element as E
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Ledger
import Model exposing (Model)
import Money
import Msg exposing (Msg)
import Ui
import Ui.Color as Color


viewDesktop : Model -> E.Element Msg
viewDesktop model =
    Keyed.el
        [ E.width E.fill
        , E.height E.fill
        ]
        ( "summary"
        , E.column
            [ E.width E.fill
            , E.height E.fill
            ]
            [ viewAccounts model
            , viewBalance model
            ]
        )


viewMobile : Model -> E.Element Msg
viewMobile model =
    Keyed.el
        [ E.width E.fill ]
        ( "summary"
        , E.row [ E.width E.fill, E.spacing <| model.context.em // 4 ]
            [ E.el [ E.width E.fill ] E.none
            , viewAccounts model
            , viewMobileBalance model
            , E.el [ E.width E.fill ] E.none
            ]
        )


viewAccounts : Model -> E.Element Msg
viewAccounts model =
    case Dict.keys model.accounts of
        [ singleAccount ] ->
            E.el [ Ui.notSelectable, Font.center, E.centerX, E.centerY ]
                (E.text <| Model.accountName singleAccount model)

        accounts ->
            Input.radioRow
                [ E.width E.shrink
                , Border.width 4
                , Border.color Color.transparent
                , Ui.focusVisibleOnly
                , E.centerX
                , E.centerY
                ]
                { onChange = Msg.SelectAccount
                , selected = Just model.account
                , label = Input.labelHidden "Compte"
                , options =
                    List.map
                        (\account ->
                            Ui.radioRowOption account
                                (E.text (Model.accountName account model))
                        )
                        accounts
                }


viewBalance : Model -> E.Element msg
viewBalance model =
    let
        balance =
            Ledger.getBalance model.ledger model.account model.today

        parts =
            Money.toStrings balance

        sign =
            if parts.sign == "+" then
                ""

            else
                "-"

        color =
            if Money.isGreaterOrEqualThan balance 0 then
                Color.neutral30

            else
                Color.warning60
    in
    E.column
        [ E.centerX
        , E.centerY
        , E.paddingXY model.context.em (model.context.em // 4)
        , Border.rounded (model.context.em // 4)
        , if Money.isGreaterOrEqualThan balance model.settings.balanceWarning then
            Border.color Color.transparent

          else
            Border.color Color.warning60
        , Border.width 2
        ]
        [ E.el
            [ Ui.smallFont model.context
            , E.centerX
            , Font.color Color.neutral40
            , Ui.notSelectable
            ]
            (E.text "Solde actuel:")
        , E.row
            [ E.centerX, Font.color color, Ui.notSelectable ]
            [ E.el
                [ Ui.biggestFont model.context
                , Font.bold
                ]
                (E.text (sign ++ parts.units))
            , E.el
                [ Ui.bigFont model.context
                , Font.bold
                , E.alignBottom
                , E.paddingEach { top = 0, bottom = 2, left = 0, right = 0 }
                ]
                (E.text ("," ++ parts.cents))
            , E.el
                [ Ui.bigFont model.context
                , E.alignTop
                , E.paddingEach { top = 2, bottom = 0, left = 4, right = 0 }
                ]
                (E.text "€")
            ]
        ]


viewMobileBalance : Model -> E.Element msg
viewMobileBalance model =
    let
        balance =
            Ledger.getBalance model.ledger model.account model.today

        parts =
            Money.toStrings balance

        sign =
            if parts.sign == "+" then
                ""

            else
                "-"

        color =
            if Money.isGreaterOrEqualThan balance 0 then
                Color.neutral30

            else
                Color.warning60
    in
    E.el
        [ E.centerX
        , E.centerY
        , E.paddingXY model.context.em (model.context.em // 4)
        , Border.rounded (model.context.em // 4)
        , if Money.isGreaterOrEqualThan balance model.settings.balanceWarning then
            Border.color Color.transparent

          else
            Border.color Color.warning60
        , Border.width 2
        , Font.color color
        , Ui.notSelectable
        ]
        (E.paragraph
            [ E.centerX, Font.color color, Ui.notSelectable ]
            [ E.el
                [ Ui.defaultFontSize model.context
                , Font.bold
                ]
                (E.text (sign ++ parts.units))
            , E.el
                [ Ui.smallFont model.context
                , Font.bold
                , E.alignBottom
                , E.paddingEach { top = 0, bottom = 2, left = 0, right = 0 }
                ]
                (E.text ("," ++ parts.cents))
            , E.el
                [ Ui.smallFont model.context
                , E.alignTop
                , E.paddingEach { top = 2, bottom = 0, left = 4, right = 0 }
                ]
                (E.text "€")
            ]
        )
