module View.Calendar exposing (view)

import Date
import Debug
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import Ledger
import Model
import Msg
import Time
import View.Style as Style
import View.Summary as Summary


view : Model.Model -> Element Msg.Msg
view model =
    row
        [ width fill
        , height fill
        , clipX
        , clipY
        , htmlAttribute <| Html.Attributes.style "z-index" "-1"
        , Background.color Style.bgPage
        , Style.fontFamily
        ]
        [ column
            [ width (fillPortion 25), height fill, padding 16, alignTop ]
            [ el
                [ width fill, height (fillPortion 33) ]
                (Summary.view model)
            , dayView model
            ]
        , el
            [ width (fillPortion 75), height fill ]
            (monthView model)
        ]



-- MONTH VIEW


monthView : Model.Model -> Element Msg.Msg
monthView model =
    column
        [ width fill, height fill, spacing 4 ]
        ([ row
            [ width fill, alignTop, paddingXY 0 8 ]
            [ Input.button
                [ width (fillPortion 1), height fill ]
                { label =
                    el Style.icons (text "\u{F060}")
                , onPress = Just (Msg.SelectDay (Date.decrementMonth model.date))
                }
            , el
                [ width (fillPortion 3), height fill ]
                (el Style.calendarMonthName (text (Date.getMonthFullName model.today model.date)))
            , Input.button
                [ width (fillPortion 1), height fill ]
                { label =
                    el Style.icons (text "\u{F061}")
                , onPress = Just (Msg.SelectDay (Date.incrementMonth model.date))
                }
            ]
         ]
            ++ dayGridView model
            ++ [ row
                    [ width fill, alignBottom ]
                    [ el [ width fill ] (el Style.weekDayName (text "Lundi"))
                    , el [ width fill ] (el Style.weekDayName (text "Mardi"))
                    , el [ width fill ] (el Style.weekDayName (text "Mercredi"))
                    , el [ width fill ] (el Style.weekDayName (text "Jeudi"))
                    , el [ width fill ] (el Style.weekDayName (text "Vendredi"))
                    , el [ width fill ] (el Style.weekDayName (text "Samedi"))
                    , el [ width fill ] (el Style.weekDayName (text "Dimanche"))
                    ]
               ]
        )


dayGridView : Model.Model -> List (Element Msg.Msg)
dayGridView model =
    let
        findTheFirst day =
            if Date.getDay day == 1 then
                day

            else
                findTheFirst (Date.decrementDay day)

        findTheLast day =
            if Date.getDay day == Date.lastDayOf day then
                day

            else
                findTheLast (Date.incrementDay day)

        lastDay =
            findTheLast model.date

        findMonday day =
            case Date.getWeekday day of
                Time.Mon ->
                    day

                _ ->
                    findMonday (Date.decrementDay day)

        walkWeeks day =
            case ( Date.compare day lastDay, Date.getWeekday day ) of
                ( GT, Time.Mon ) ->
                    []

                _ ->
                    row
                        [ width fill, height fill, clipY, spacing 4 ]
                        (walkDays day)
                        :: walkWeeks (Date.incrementWeek day)

        walkDays day =
            case Date.getWeekday day of
                Time.Sun ->
                    [ dayCell model day ]

                _ ->
                    dayCell model day :: walkDays (Date.incrementDay day)
    in
    walkWeeks (findMonday (findTheFirst model.date))


dayCell : Model.Model -> Date.Date -> Element Msg.Msg
dayCell model day =
    let
        sel =
            model.selected && day == model.date

        style =
            width fill
                :: height fill
                :: scrollbarY
                :: (if sel then
                        Style.dayCellSelected

                    else
                        Style.dayCell
                   )
    in
    if Date.getMonth day == Date.getMonth model.date then
        Input.button
            style
            { label =
                Element.column
                    [ width fill, height fill, scrollbarY ]
                    [ el
                        ([ width fill
                         , paddingXY 4 4
                         , Style.smallFont
                         , Font.center
                         ]
                            ++ (if sel then
                                    [ Font.color (rgb 1 1 1)
                                    , Background.color Style.bgTitle
                                    ]

                                else
                                    []
                               )
                        )
                        (text
                            (if day == model.today then
                                "Aujourd'hui"

                             else
                                String.fromInt (Date.getDay day)
                            )
                        )
                    , Element.paragraph
                        [ width fill
                        , height fill
                        , clipX
                        , scrollbarY
                        , paddingXY 4 8
                        , spacing 12
                        ]
                        (dayCellTransactions model day)
                    ]
            , onPress = Just (Msg.SelectDay day)
            }

    else
        el
            (width
                fill
                :: height fill
                :: Style.dayCellNone
            )
            none


dayCellTransactions : Model.Model -> Date.Date -> List (Element Msg.Msg)
dayCellTransactions model day =
    let
        render transaction =
            let
                parts =
                    Ledger.amountParts transaction.amount
            in
            row
                [ paddingEach { top = 4, bottom = 3, left = 6, right = 8 }
                , Style.smallFont
                , Font.color (rgb 1 1 1)
                , if Ledger.isExpense transaction then
                    Background.color (rgb 0.8 0.25 0.2)

                  else
                    Background.color (rgb 0.2 0.7 0.1)
                , Border.rounded 16
                , Border.width 0
                ]
                (el [ Style.smallFont ] (text parts.units)
                    :: (case parts.cents of
                            Nothing ->
                                []

                            Just cents ->
                                [ el
                                    [ Style.smallerFont
                                    , alignBottom
                                    , paddingXY 0 1
                                    ]
                                    (text cents)
                                ]
                       )
                )
    in
    List.map
        render
        (List.filter
            (\t -> t.date == day)
            (Ledger.transactions model.ledger)
        )
        |> List.intersperse (text " ")



-- DAY VIEW


dayView model =
    column
        [ width fill
        , height (fillPortion 66)
        , Border.rounded 16
        , clip
        , Border.shadow { offset = ( 0, 0 ), size = 4, blur = 8, color = rgba 0 0 0 0.2 }
        , Background.color (rgb 1 1 1)
        ]
        [ el
            [ width fill
            , paddingXY 4 12
            , Background.color (rgb 0.3 0.6 0.7)
            , Font.color (rgb 1 1 1)
            , Font.center
            , Font.bold
            , Style.bigFont
            ]
            (if model.date == model.today then
                text "Aujourd'hui"

             else
                text (Date.getWeekdayName model.date ++ " " ++ String.fromInt (Date.getDay model.date))
            )
        ]
