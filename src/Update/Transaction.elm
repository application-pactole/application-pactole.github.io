module Update.Transaction exposing (confirm, confirmDelete, update)

import Database
import Ledger
import Log
import Model exposing (Model)
import Money
import Msg exposing (Msg)


update : Msg.TransactionMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.ChangeTransactionAmount amount ->
            case model.dialog of
                Just (Model.TransactionDialog dialog) ->
                    ( { model
                        | dialog = Just <| Model.TransactionDialog { dialog | amount = ( amount, Nothing ) }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none ) |> Log.error "unexpected DialogChangeAmount message"

        Msg.ChangeTransactionDescription string ->
            case model.dialog of
                Just (Model.TransactionDialog dialog) ->
                    ( { model
                        | dialog =
                            Just <|
                                Model.TransactionDialog
                                    { dialog
                                        | description =
                                            String.filter (\c -> c /= Char.fromCode 13 && c /= Char.fromCode 10) string
                                    }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none ) |> Log.error "unexpected DialogChangeDescription message"

        Msg.ChangeTransactionCategory id ->
            case model.dialog of
                Just (Model.TransactionDialog dialog) ->
                    ( { model
                        | dialog =
                            Just <|
                                Model.TransactionDialog
                                    { dialog | category = id }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none ) |> Log.error "unexpected DialogChangeCategory message"


confirmDelete : Model -> Int -> ( Model, Cmd Msg )
confirmDelete model data =
    ( { model | dialog = Nothing }
    , Database.deleteTransaction data
    )


confirm : Model -> Model.TransactionData -> ( Model, Cmd Msg )
confirm model data =
    case
        ( data.id
        , Money.fromInput data.isExpense (Tuple.first data.amount)
        )
    of
        ( Just id, Ok amount ) ->
            let
                checked =
                    Ledger.getTransaction id model.ledger
                        |> Maybe.map .checked
                        |> Maybe.withDefault False
            in
            ( { model | dialog = Nothing }
            , Database.replaceTransaction
                { id = id
                , account = model.account
                , date = data.date
                , amount = amount
                , description = data.description
                , category = data.category
                , checked = checked
                }
            )

        ( Nothing, Ok amount ) ->
            ( { model | dialog = Nothing }
            , Database.createTransaction
                { account = model.account
                , date = data.date
                , amount = amount
                , description = data.description
                , category = data.category
                , checked = False
                }
            )

        ( _, Err amountError ) ->
            let
                newDialog =
                    { data | amount = ( Tuple.first data.amount, Just amountError ) }
            in
            ( { model
                | dialog = Just <| Model.TransactionDialog newDialog
              }
            , Cmd.none
            )
