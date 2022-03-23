module Page.Reconcile exposing (view)

import Date
import Element as E
import Element.Background as Background
import Element.Font as Font
import Ledger
import Model
import Money
import Msg
import Page.Summary as Summary
import Ui
import Ui.Color as Color



-- VIEW


view :
    Model.Model
    ->
        { summary : E.Element Msg.Msg
        , detail : E.Element Msg.Msg
        , main : E.Element Msg.Msg
        }
view model =
    { summary = Summary.view model
    , detail = E.none
    , main =
        E.column
            [ E.width E.fill
            , E.height E.fill
            , E.clipY
            ]
            [ Ui.dateNavigationBar model Msg.SelectDate
            , viewReconciled model
            , viewTransactions model
            ]
    }


viewReconciled : Model.Model -> E.Element msg
viewReconciled shared =
    let
        prevMonth =
            Date.getMonthName (Date.decrementMonth shared.date)
    in
    E.column
        [ E.width E.fill, E.paddingXY 48 24, E.spacing 24, Font.color Color.neutral30 ]
        [ E.row
            [ E.width E.fill ]
            [ E.el [ E.width E.fill ] E.none
            , E.el [ Ui.biggerFont ] (E.text "Solde bancaire: ")
            , Ui.viewSum (Ledger.getReconciled shared.ledger shared.account)
            , E.el [ E.width E.fill ] E.none
            ]
        , if Ledger.getNotReconciledBeforeMonth shared.ledger shared.account shared.date then
            E.el
                [ E.width E.fill, Font.center ]
                (E.paragraph []
                    [ E.text "Attention: il reste des opérations à pointer en "
                    , E.el [ Font.bold ] (E.text prevMonth)
                    ]
                )

          else
            E.none
        ]


viewTransactions : Model.Model -> E.Element Msg.Msg
viewTransactions shared =
    E.column
        [ E.padding 0
        , E.spacing 0
        , E.width E.fill
        , E.height E.fill
        , E.scrollbarY
        , Font.color Color.neutral30
        ]
        (List.indexedMap
            (\idx transaction ->
                E.row
                    [ E.width E.fill
                    , E.paddingXY 12 18
                    , if Basics.remainderBy 2 idx == 0 then
                        Background.color Color.neutral95

                      else
                        Background.color Color.neutral90
                    ]
                    [ colDate transaction
                    , colReconciled transaction
                    , colAmount transaction shared.today
                    , colDescription transaction
                    ]
            )
            (Ledger.getTransactionsForMonth shared.ledger shared.account shared.date shared.today)
        )


colReconciled : Ledger.Transaction -> E.Element Msg.Msg
colReconciled transaction =
    E.el
        [ E.width (E.fillPortion 1) ]
        (Ui.checkBox
            { state = transaction.checked
            , onPress = Just (Msg.ForDatabase <| Msg.DbCheckTransaction transaction (not transaction.checked))
            }
        )


colDate : { a | date : Date.Date } -> E.Element msg
colDate transaction =
    E.el
        [ E.width (E.fillPortion 2), E.alignRight, Font.alignRight ]
        (E.text (Date.toShortString transaction.date))


colAmount : { a | date : Date.Date, amount : Money.Money } -> Date.Date -> E.Element msg
colAmount transaction today =
    let
        future =
            Date.compare transaction.date today == GT
    in
    E.el
        [ E.width (E.fillPortion 2) ]
        (Ui.viewMoney transaction.amount future)


colDescription : { a | description : String } -> E.Element msg
colDescription transaction =
    E.el
        [ E.width (E.fillPortion 8), E.clip ]
        (if transaction.description == "" then
            E.el [ Font.color Color.neutral70 ] (E.text "—")

         else
            E.text transaction.description
        )
