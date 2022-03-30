module Page.Summary exposing (view)

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



-- SUMMARY VIEW


view : Model -> E.Element Msg
view model =
    Keyed.el [ E.width E.fill, E.height E.fill ]
        ( "summary"
        , E.column
            [ E.width E.fill
            , E.height E.fill
            , E.centerX
            , E.paddingXY 0 24
            ]
            [ E.el [ E.height E.fill ] E.none
            , E.row
                [ E.width E.fill
                , E.paddingEach { left = 0, top = 0, bottom = 12, right = 0 }
                ]
                [ E.el [ E.width E.fill ]
                    E.none
                , case Dict.values model.accounts of
                    [ singleAccount ] ->
                        E.el [ Ui.normalFont, Font.color Color.neutral30, Ui.notSelectable, Font.center ]
                            (E.text singleAccount)

                    _ ->
                        accountsRow model
                , E.el [ E.width E.fill ] E.none
                ]
            , E.el
                [ Ui.smallFont
                , E.width E.fill
                , Font.center
                , Font.color Color.neutral50
                , Ui.notSelectable
                ]
                (E.text "Solde actuel:")
            , balanceRow model
            , E.row [ E.height E.fill ] [ E.none ]
            ]
        )


accountsRow : Model -> E.Element Msg
accountsRow model =
    Input.radioRow
        [ E.width E.shrink
        , Border.width 4
        , Border.color Color.transparent
        , Ui.focusVisibleOnly
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
                (Dict.keys model.accounts)
        }


balanceRow : Model -> E.Element msg
balanceRow model =
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
            if Money.isGreaterThan balance 0 then
                Color.neutral30

            else
                Color.warning60
    in
    E.row
        [ E.width E.fill, Font.color color, Ui.notSelectable ]
        [ E.el [ E.width E.fill ] E.none
        , if Money.isGreaterThan balance model.settings.balanceWarning then
            E.none

          else
            Ui.warningIcon
        , E.el
            [ Ui.biggestFont
            , Font.bold
            ]
            (E.text (sign ++ parts.units))
        , E.el
            [ Ui.bigFont
            , Font.bold
            , E.alignBottom
            , E.paddingEach { top = 0, bottom = 2, left = 0, right = 0 }
            ]
            (E.text ("," ++ parts.cents))
        , E.el
            [ Ui.bigFont
            , E.alignTop
            , E.paddingEach { top = 2, bottom = 0, left = 4, right = 0 }
            ]
            (E.text "€")
        , if Money.isGreaterThan balance model.settings.balanceWarning then
            E.none

          else
            Ui.warningIcon
        , E.el [ E.width E.fill ] E.none
        ]
