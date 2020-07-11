port module Ports exposing (..)

import Date
import Json.Decode as Decode
import Json.Encode as Encode
import Money
import Msg


port send : ( String, Encode.Value ) -> Cmd msg


port receive : (( String, Decode.Value ) -> msg) -> Sub msg



-- HELPERS


error : String -> Cmd Msg.Msg
error msg =
    send ( "error", Encode.string msg )


getAccountList =
    send ( "get account list", Encode.object [] )


createAccount name =
    send ( "create account", Encode.string name )


getLedger : Int -> Cmd Msg.Msg
getLedger account =
    send ( "get ledger", Encode.int account )


addTransaction : { account : Maybe Int, date : Date.Date, amount : Money.Money, description : String, category : String, checked : Bool } -> Cmd Msg.Msg
addTransaction { account, date, amount, description, category, checked } =
    case account of
        Just acc ->
            send
                ( "add transaction"
                , Encode.object
                    [ ( "account", Encode.int acc )
                    , ( "date", Encode.int (Date.toInt date) )
                    , ( "amount", Money.encoder amount )
                    , ( "description", Encode.string description )
                    , ( "category", Encode.string category )
                    , ( "checked", Encode.bool checked )
                    ]
                )

        Nothing ->
            error "add transaction: no current account"


putTransaction : { account : Maybe Int, id : Int, date : Date.Date, amount : Money.Money, description : String, category : String, checked : Bool } -> Cmd Msg.Msg
putTransaction { account, id, date, amount, description, category, checked } =
    case account of
        Just acc ->
            send
                ( "put transaction"
                , Encode.object
                    [ ( "account", Encode.int acc )
                    , ( "id", Encode.int id )
                    , ( "date", Encode.int (Date.toInt date) )
                    , ( "amount", Money.encoder amount )
                    , ( "description", Encode.string description )
                    , ( "category", Encode.string category )
                    , ( "checked", Encode.bool checked )
                    ]
                )

        Nothing ->
            error "put transaction: no current account"


deleteTransaction : { account : Maybe Int, id : Int } -> Cmd Msg.Msg
deleteTransaction { account, id } =
    case account of
        Just acc ->
            send
                ( "delete transaction"
                , Encode.object
                    [ ( "account", Encode.int acc )
                    , ( "id", Encode.int id )
                    ]
                )

        Nothing ->
            error "delete transaction: no current account"



-- Settings


renameAccount : Int -> String -> Cmd Msg.Msg
renameAccount account newName =
    send
        ( "rename account"
        , Encode.object
            [ ( "account", Encode.int account )
            , ( "newName", Encode.string newName )
            ]
        )


deleteAccount : Int -> Cmd Msg.Msg
deleteAccount account =
    send
        ( "delete account"
        , Encode.int account
        )
