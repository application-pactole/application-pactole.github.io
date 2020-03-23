module Msg exposing (Msg(..))

import Browser
import Date
import Json.Decode as Decode
import Ledger
import Model
import Money
import Url


type Msg
    = Today Date.Date
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ToCalendar
    | ToTabular
    | DialogAmount String
    | DialogDescription String
    | ToMainPage
    | ToSettings
    | Close
    | SelectDay Date.Date
    | ChooseAccount String
    | SetAccounts Decode.Value
    | SetLedger Decode.Value
    | KeyDown String
    | KeyUp String
    | NewIncome
    | NewExpense
    | Edit Int
    | ConfirmNew (Maybe Money.Money)
    | ConfirmEdit Int (Maybe Money.Money)
    | NoOp
