module Date exposing
    ( Date
    , compare
    , decrementDay
    , decrementMonth
    , default
    , firstDayOf
    , fromInt
    , fromParts
    , getDay
    , getMonth
    , getMonthFullName
    , getMonthName
    , getWeekday
    , getWeekdayName
    , getYear
    , incrementDay
    , incrementMonth
    , incrementWeek
    , lastDayOf
    , toInt
    , toString
    )

import Array
import Calendar
import Time


type Date
    = Date Calendar.Date


default =
    Date (Calendar.fromPosix (Time.millisToPosix 0))


toString (Date date) =
    String.padLeft 2 '0' (String.fromInt (Calendar.getDay date))
        ++ "/"
        ++ String.padLeft 2 '0' (String.fromInt (getMonthNumber (Calendar.getMonth date)))
        ++ "/"
        ++ String.fromInt (Calendar.getYear date)


fromParts : { year : Int, month : Int, day : Int } -> Maybe Date
fromParts { year, month, day } =
    case Array.get month Calendar.months of
        Nothing ->
            Nothing

        Just m ->
            Maybe.map Date
                (Calendar.fromRawParts { day = day, month = m, year = year })



{-
   fromZoneAndPosix : Time.Zone -> Time.Posix -> Date
   fromZoneAndPosix zone time =
       let
           y =
               Time.toYear zone time

           m =
               Time.toMonth zone time

           d =
               Time.toDay zone time
       in
       case Calendar.fromRawParts { day = d, month = m, year = y } of
           Just date ->
               Date date

           Nothing ->
               Date (Calendar.fromPosix (Time.millisToPosix 0))
-}


fromPosix : Time.Posix -> Date
fromPosix time =
    Date (Calendar.fromPosix time)


incrementWeek (Date date) =
    Date
        (date
            |> Calendar.incrementDay
            |> Calendar.incrementDay
            |> Calendar.incrementDay
            |> Calendar.incrementDay
            |> Calendar.incrementDay
            |> Calendar.incrementDay
            |> Calendar.incrementDay
        )


getMonthNumber : Time.Month -> Int
getMonthNumber m =
    case m of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


getMonthName : Date -> String
getMonthName (Date d) =
    let
        m =
            Calendar.getMonth d
    in
    case m of
        Time.Jan ->
            "Janvier"

        Time.Feb ->
            "Février"

        Time.Mar ->
            "Mars"

        Time.Apr ->
            "Avril"

        Time.May ->
            "Mai"

        Time.Jun ->
            "Juin"

        Time.Jul ->
            "Juillet"

        Time.Aug ->
            "Août"

        Time.Sep ->
            "Septembre"

        Time.Oct ->
            "Octobre"

        Time.Nov ->
            "Novembre"

        Time.Dec ->
            "Décembre"


getWeekdayName (Date d) =
    case Calendar.getWeekday d of
        Time.Mon ->
            "Lundi"

        Time.Tue ->
            "Mardi"

        Time.Wed ->
            "Mercredi"

        Time.Thu ->
            "Jeudi"

        Time.Fri ->
            "Vendredi"

        Time.Sat ->
            "Samedi"

        Time.Sun ->
            "Dimanche"


getMonthFullName (Date today) (Date d) =
    let
        n =
            getMonthName (Date d)
    in
    {-
       if Calendar.getYear d == Calendar.getYear today then
           n

       else
    -}
    n ++ " " ++ String.fromInt (Calendar.getYear d)


toInt : Date -> Int
toInt (Date date) =
    let
        y =
            Calendar.getYear date

        m =
            Calendar.getMonth date |> Calendar.monthToInt

        d =
            Calendar.getDay date
    in
    d + 100 * m + 10000 * y


fromInt n =
    let
        y =
            n // 10000

        m =
            (n - y * 10000) // 100

        d =
            n - y * 10000 - m * 100

        mm =
            Array.get (m - 1) Calendar.months

        raw =
            case mm of
                Nothing ->
                    Nothing

                Just mmm ->
                    Calendar.fromRawParts
                        { year = y
                        , month = mmm
                        , day = d
                        }
    in
    case raw of
        Nothing ->
            --TODO: propagate error?
            fromPosix (Time.millisToPosix 0)

        Just date ->
            Date date


decrementMonth (Date date) =
    Date (Calendar.decrementMonth date)


incrementMonth (Date date) =
    Date (Calendar.incrementMonth date)


getDay (Date date) =
    Calendar.getDay date


decrementDay (Date date) =
    Date (Calendar.decrementDay date)


incrementDay (Date date) =
    Date (Calendar.incrementDay date)


lastDayOf (Date date) =
    Calendar.lastDayOf date


firstDayOf (Date date) =
    case Calendar.setDay 1 date of
        Just d ->
            Date d

        Nothing ->
            default


getWeekday (Date date) =
    Calendar.getWeekday date


compare (Date a) (Date b) =
    Calendar.compare a b


getMonth (Date date) =
    Calendar.getMonth date


getYear (Date date) =
    Calendar.getYear date
