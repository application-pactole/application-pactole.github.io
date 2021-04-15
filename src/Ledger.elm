module Ledger exposing
    ( Ledger
    , NewTransaction
    , Transaction
    , decode
    , decodeNewTransaction
    , empty
    , encodeNewTransaction
    , encodeTransaction
    , getBalance
    , getCategoryTotalForMonth
    , getExpenseForMonth
    , getIncomeForMonth
    , getNotReconciledBeforeMonth
    , getReconciled
    , getTotalForMonth
    , getTransaction
    , getTransactionDescription
    , getTransactionsForDate
    , getTransactionsForMonth
    , hasFutureTransactionsForMonth
    )

import Date
import Json.Decode as Decode
import Json.Encode as Encode
import Money



-- LEDGER


type Ledger
    = Ledger (List Transaction)


type alias Transaction =
    { id : Int
    , account : Int
    , date : Date.Date
    , amount : Money.Money
    , description : String
    , category : Int
    , checked : Bool
    }


type alias NewTransaction =
    { account : Int
    , date : Date.Date
    , amount : Money.Money
    , description : String
    , category : Int
    , checked : Bool
    }


empty : Ledger
empty =
    Ledger []


getBalance : Ledger -> Int -> Date.Date -> Money.Money
getBalance (Ledger transactions) account today =
    transactions
        |> List.filter (\t -> t.account == account)
        |> List.filter (\t -> Date.compare t.date today /= GT)
        |> List.foldl
            (\t accum -> Money.add accum t.amount)
            Money.zero


getReconciled : Ledger -> Int -> Money.Money
getReconciled (Ledger transactions) account =
    transactions
        |> List.filter (\t -> t.account == account)
        |> List.filter (\t -> t.checked == True)
        |> List.foldl
            (\t accum -> Money.add accum t.amount)
            Money.zero


getNotReconciledBeforeMonth : Ledger -> Int -> Date.Date -> Bool
getNotReconciledBeforeMonth (Ledger transactions) account date =
    let
        d =
            Date.firstDayOf date
    in
    transactions
        |> List.filter (\t -> t.account == account)
        |> List.filter
            (\t -> Date.compare t.date d == LT)
        |> List.any
            (\t -> not t.checked)


getTransactionsForDate : Ledger -> Int -> Date.Date -> List Transaction
getTransactionsForDate (Ledger transactions) account date =
    transactions
        |> List.filter (\t -> t.account == account)
        |> List.filter (\t -> t.date == date)


getTransactionsForMonth : Ledger -> Int -> Date.Date -> Date.Date -> List Transaction
getTransactionsForMonth (Ledger transactions) account date today =
    transactions
        --TODO
        |> List.filter (\t -> t.account == account)
        |> List.filter
            (\t ->
                (Date.compare t.date today /= GT)
                    && (Date.getYear t.date == Date.getYear date)
                    && (Date.getMonth t.date == Date.getMonth date)
            )


getTotalForMonth : Ledger -> Int -> Date.Date -> Date.Date -> Money.Money
getTotalForMonth ledger account date today =
    getTransactionsForMonth ledger account date today
        |> List.foldl
            (\t accum -> Money.add accum t.amount)
            Money.zero


hasFutureTransactionsForMonth : Ledger -> Int -> Date.Date -> Date.Date -> Bool
hasFutureTransactionsForMonth (Ledger transactions) account date today =
    transactions
        |> List.filter (\t -> t.account == account)
        |> List.any
            (\t ->
                (Date.compare t.date today == GT)
                    && (Date.getYear t.date == Date.getYear date)
                    && (Date.getMonth t.date == Date.getMonth date)
            )


getIncomeForMonth : Ledger -> Int -> Date.Date -> Date.Date -> Money.Money
getIncomeForMonth ledger account date today =
    getTransactionsForMonth ledger account date today
        |> List.filter (\t -> not (Money.isExpense t.amount))
        |> List.foldl
            (\t accum -> Money.add accum t.amount)
            Money.zero


getExpenseForMonth : Ledger -> Int -> Date.Date -> Date.Date -> Money.Money
getExpenseForMonth ledger account date today =
    getTransactionsForMonth ledger account date today
        |> List.filter (\t -> Money.isExpense t.amount)
        |> List.foldl
            (\t accum -> Money.add accum t.amount)
            Money.zero


getCategoryTotalForMonth : Ledger -> Int -> Date.Date -> Date.Date -> Int -> Money.Money
getCategoryTotalForMonth ledger account date today catID =
    getTransactionsForMonth ledger account date today
        |> List.filter (\t -> Money.isExpense t.amount)
        |> List.filter (\t -> t.category == catID)
        |> List.foldl
            (\t accum -> Money.add accum t.amount)
            Money.zero


getTransaction : Int -> Ledger -> Maybe Transaction
getTransaction id (Ledger transactions) =
    let
        matches =
            List.filter
                (\t -> t.id == id)
                transactions
    in
    case matches of
        [] ->
            Nothing

        [ t ] ->
            Just t

        _ ->
            --TODO: error: multiple transactions with the same ID
            Nothing



{-
   addTransaction : { date : Date.Date, amount : Money.Money, description : String } -> Ledger -> Ledger
   addTransaction { date, amount, description } (Ledger ledger) =
       Ledger
           { transactions =
               ledger.transactions
                   ++ [ { id = ledger.nextId
                        , date = date
                        , amount = amount
                        , description = description
                        , category = NoCategory
                        , reconciliation = NotReconciled
                        }
                      ]
           , nextId = ledger.nextId + 1
           }


   updateTransaction : { id : Int, date : Date.Date, amount : Money.Money, description : String } -> Ledger -> Ledger
   updateTransaction { id, date, amount, description } (Ledger ledger) =
       Ledger
           { transactions =
               List.map
                   (\t ->
                       if t.id == id then
                           { id = id
                           , date = date
                           , amount = amount
                           , description = description
                           , category = NoCategory
                           , reconciliation = NotReconciled
                           }

                       else
                           t
                   )
                   ledger.transactions
           , nextId = ledger.nextId + 1
           }


   deleteTransaction : Int -> Ledger -> Ledger
   deleteTransaction id (Ledger ledger) =
       Ledger
           { transactions =
               List.filter
                   (\t -> t.id /= id)
                   ledger.transactions
           , nextId = ledger.nextId
           }
-}


getTransactionDescription : { a | description : String, amount : Money.Money } -> String
getTransactionDescription transaction =
    if transaction.description == "" then
        if Money.isExpense transaction.amount then
            "Dépense"

        else
            "Entrée d'argent"

    else
        transaction.description



-- JSON ENCODERS AND DECODERS


decode : Decode.Decoder Ledger
decode =
    Decode.map Ledger (Decode.list decodeTransaction)


encodeTransaction : Transaction -> Encode.Value
encodeTransaction transaction =
    Encode.object
        [ ( "account", Encode.int transaction.account )
        , ( "id", Encode.int transaction.id )
        , ( "date", Encode.int (Date.toInt transaction.date) )
        , ( "amount", Money.encoder transaction.amount )
        , ( "description", Encode.string transaction.description )
        , ( "category", Encode.int transaction.category )
        , ( "checked", Encode.bool transaction.checked )
        ]


decodeTransaction : Decode.Decoder Transaction
decodeTransaction =
    Decode.map7 Transaction
        (Decode.field "id" Decode.int)
        (Decode.field "account" Decode.int)
        (Decode.map Date.fromInt (Decode.field "date" Decode.int))
        (Decode.field "amount" Money.decoder)
        (Decode.field "description" Decode.string)
        (Decode.field "category" Decode.int)
        (Decode.field "checked" Decode.bool)


encodeNewTransaction : NewTransaction -> Encode.Value
encodeNewTransaction transaction =
    Encode.object
        [ ( "account", Encode.int transaction.account )
        , ( "date", Encode.int (Date.toInt transaction.date) )
        , ( "amount", Money.encoder transaction.amount )
        , ( "description", Encode.string transaction.description )
        , ( "category", Encode.int transaction.category )
        , ( "checked", Encode.bool transaction.checked )
        ]


decodeNewTransaction : Decode.Decoder NewTransaction
decodeNewTransaction =
    Decode.map6 NewTransaction
        (Decode.field "account" Decode.int)
        (Decode.map Date.fromInt (Decode.field "date" Decode.int))
        (Decode.field "amount" Money.decoder)
        (Decode.field "description" Decode.string)
        (Decode.field "category" Decode.int)
        (Decode.field "checked" Decode.bool)
