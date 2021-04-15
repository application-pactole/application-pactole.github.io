module Page.Summary exposing (view)

import Dict
import Element as E
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HtmlAttr
import Ledger
import Model
import Money
import Msg
import Ui



-- SUMMARY VIEW


view : Model.Model -> E.Element Msg.Msg
view model =
    E.column
        [ E.width E.fill
        , E.height E.fill
        , E.centerX
        ]
        [ E.row
            [ E.width E.fill
            ]
            [ E.el [ E.paddingXY 6 0, E.width E.fill ]
                (settingsButton model)
            , Input.radioRow
                [ E.width E.shrink
                , if model.showFocus then
                    E.focused
                        [ Border.shadow
                            { offset = ( 0, 0 )
                            , size = 4
                            , blur = 0
                            , color = Ui.fgFocus
                            }
                        ]

                  else
                    E.focused
                        [ Border.shadow
                            { offset = ( 0, 0 )
                            , size = 0
                            , blur = 0
                            , color = Ui.transparent
                            }
                        ]
                ]
                { onChange = Msg.SelectAccount
                , selected = Just model.account
                , label = Input.labelHidden "Compte"
                , options =
                    List.map
                        (\account ->
                            Input.optionWith account
                                (accountOption account model)
                        )
                        (Dict.keys model.accounts)
                }
            , E.el [ E.width E.fill ]
                E.none
            ]
        , E.row [ E.height (E.fillPortion 1) ] [ E.none ]
        , E.el
            [ Ui.smallFont
            , E.paddingEach { top = 0, bottom = 6, left = 0, right = 0 }
            , E.width E.fill
            , Font.center
            , Font.color Ui.fgDarker
            , Ui.notSelectable
            ]
            (E.text "Solde actuel:")
        , balanceRow model
        , E.row [ E.height (E.fillPortion 1) ] [ E.none ]
        , buttonRow model
        , E.row [ E.height (E.fillPortion 2) ] [ E.none ]
        ]


accountOption : Int -> Model.Model -> Input.OptionState -> E.Element msg
accountOption accountID model state =
    E.el
        ([ E.centerX
         , E.paddingXY 16 7
         , Border.rounded 3
         , Ui.bigFont
         ]
            ++ (case state of
                    Input.Idle ->
                        [ Font.color Ui.fgTitle ]

                    Input.Focused ->
                        []

                    Input.Selected ->
                        [ Font.color (E.rgb 1 1 1), Background.color Ui.bgTitle ]
               )
        )
        (E.text (Model.account accountID model))


balanceRow : Model.Model -> E.Element msg
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
                Ui.fgBlack

            else
                Ui.fgRed
    in
    E.row
        [ E.width E.fill, Font.color color, Ui.notSelectable ]
        [ E.el [ E.width E.fill ] E.none
        , if Money.isGreaterThan balance model.settings.balanceWarning then
            E.none

          else
            Ui.warningIcon []
        , E.el
            [ Ui.biggestFont
            , Font.bold
            ]
            (E.text (sign ++ parts.units))
        , E.el
            [ Ui.biggerFont
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
            Ui.warningIcon []
        , E.el [ E.width E.fill ] E.none
        ]


buttonRow : Model.Model -> E.Element Msg.Msg
buttonRow model =
    E.row
        [ E.width E.fill, E.spacing 12 ]
        [ E.el [ E.width E.fill ] E.none
        , if model.page == Model.MainPage && model.settings.summaryEnabled then
            Ui.simpleButton
                [ E.width (E.fillPortion 3)
                , E.htmlAttribute <| HtmlAttr.id "unfocus-on-page-change"
                ]
                { onPress = Just (Msg.ChangePage Model.StatsPage)
                , label = E.text "Bilan"
                }

          else
            E.none
        , if model.page == Model.MainPage && model.settings.reconciliationEnabled then
            Ui.simpleButton
                [ E.width (E.fillPortion 3)
                , E.htmlAttribute <| HtmlAttr.id "unfocus-on-page-change"
                ]
                { onPress = Just (Msg.ChangePage Model.ReconcilePage)
                , label = E.text "Pointer"
                }

          else
            E.none
        , if model.page /= Model.MainPage then
            Ui.simpleButton
                [ E.width (E.fillPortion 3)
                , E.htmlAttribute <| HtmlAttr.id "unfocus-on-page-change"
                ]
                { onPress = Just (Msg.ChangePage Model.MainPage)
                , label =
                    E.row [ Font.center, E.width E.fill ]
                        [ E.el [ E.width E.fill ] E.none
                        , Ui.backIcon []
                        , E.text "  Retour"
                        , E.el [ E.width E.fill ] E.none
                        ]
                }

          else
            E.none
        , E.el [ E.width E.fill ] E.none
        ]


settingsButton : Model.Model -> E.Element Msg.Msg
settingsButton model =
    if model.showAdvanced then
        Input.button
            [ Background.color Ui.bgPage
            , Ui.normalFont
            , Font.color Ui.fgTitle
            , Font.center
            , Ui.roundCorners
            , E.padding 2
            , E.width (E.px 36)
            , E.height (E.px 36)
            , E.alignLeft
            ]
            { onPress = Just (Msg.ChangePage Model.SettingsPage)
            , label = E.el [ Ui.iconFont, Ui.normalFont, E.centerX ] (E.text "\u{F013}")
            }

    else
        Input.button
            [ Background.color Ui.bgPage
            , Ui.normalFont
            , Font.color Ui.fgTitle
            , Font.center
            , Ui.roundCorners
            , E.padding 2
            , E.width (E.px 36)
            , E.height (E.px 36)
            , E.alignLeft
            ]
            { onPress = Just Msg.AttemptSettings
            , label =
                E.el [ Ui.iconFont, Ui.normalFont, E.centerX, Font.color Ui.bgLight ]
                    (E.text "\u{F013}")
            }
