module Page.Tabular exposing (view)

import Common
import Date
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import Ledger
import Money
import Msg
import Page.Summary as Summary
import Style
import Ui


view : Common.Model -> Element Msg.Msg
view model =
    Ui.pageWithSidePanel []
        { panel =
            [ el
                [ width fill, height (fillPortion 1) ]
                (Summary.view model)
            , el
                [ width fill, height (fillPortion 2) ]
                none
            ]
        , page =
            transactionView model
        }


transactionView : Common.Model -> List (Element Msg.Msg)
transactionView model =
    Tuple.second
        (List.foldl
            makeRow
            ( Nothing, [] )
            (Ledger.getAllTransactions model.ledger)
        )
        |> List.reverse


makeRow transaction ( prevDate, accum ) =
    let
        dateTxt =
            el
                [ paddingEach { left = 12, right = 12, top = 24, bottom = 12 }
                , Style.bigFont
                , Font.color Style.fgTitle
                ]
                (text
                    (Date.getWeekdayName transaction.date
                        ++ " "
                        ++ String.fromInt (Date.getDay transaction.date)
                        ++ " "
                        ++ Date.getMonthName transaction.date
                     --TODO: add year for previous years
                    )
                )

        parts =
            Money.toStrings transaction.amount

        txt =
            el []
                (text
                    ("transaction: "
                        ++ Date.toString transaction.date
                        ++ " amount="
                        ++ parts.units
                    )
                )
    in
    case prevDate of
        Nothing ->
            ( Just transaction.date, txt :: dateTxt :: accum )

        Just date ->
            case Date.compare date transaction.date of
                EQ ->
                    ( Just transaction.date, txt :: accum )

                _ ->
                    ( Just transaction.date, txt :: dateTxt :: accum )
