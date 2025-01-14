module Ui exposing
    ( ButtonColor(..)
    , Context
    , Density(..)
    , DeviceClass(..)
    , backIcon
    , bigFont
    , bigWarningIcon
    , biggestFont
    , boldText
    , borderWidth
    , checkIcon
    , classifyContext
    , closeIcon
    , contentWidth
    , decodeDeviceClass
    , defaultFontSize
    , defaultShadow
    , deleteIcon
    , dialog
    , dialogSection
    , dialogSectionRow
    , editIcon
    , encodeDeviceClass
    , errorIcon
    , expenseButton
    , expenseIcon
    , flatButton
    , focusVisibleOnly
    , fontFamily
    , helpImage
    , helpList
    , helpListItem
    , helpNumberedList
    , iconButton
    , iconFont
    , incomeButton
    , incomeIcon
    , innerShadow
    , labelAbove
    , labelLeft
    , linkButton
    , loadIcon
    , minusIcon
    , moneyInput
    , monthNavigationBar
    , notSelectable
    , onEnter
    , pageTitle
    , paragraph
    , paragraphParts
    , plusIcon
    , radio
    , radioButton
    , radioOption
    , radioRowOption
    , reconcileCheckBox
    , roundButton
    , roundCorners
    , saveIcon
    , scale
    , smallFont
    , smallerFont
    , text
    , textColumn
    , textInput
    , title
    , toggleSwitch
    , transition
    , verticalSpacer
    , viewDate
    , viewIcon
    , viewMoney
    , viewSum
    , warningIcon
    , warningParagraph
    , warningPopup
    , weekNavigationBar
    )

import Date exposing (Date)
import Element as E
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Html.Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Money
import Ui.Color as Color



-- ENVIRONMENT FOR UI


type alias Context =
    { width : Int
    , height : Int
    , device : E.Device
    , bigEm : Int
    , em : Int
    , smallEm : Int
    , density : Density
    }


type DeviceClass
    = AutoClass
    | Phone
    | Tablet
    | Desktop


encodeDeviceClass : DeviceClass -> Decode.Value
encodeDeviceClass deviceClass =
    Encode.string <|
        case deviceClass of
            AutoClass ->
                "AutoClass"

            Phone ->
                "Phone"

            Tablet ->
                "Tablet"

            Desktop ->
                "Desktop"


decodeDeviceClass : Decode.Decoder DeviceClass
decodeDeviceClass =
    Decode.string
        |> Decode.map
            (\deviceClassString ->
                case deviceClassString of
                    "Phone" ->
                        Phone

                    "Tablet" ->
                        Tablet

                    "Desktop" ->
                        Desktop

                    _ ->
                        AutoClass
            )


classifyContext : { width : Int, height : Int, fontSize : Int, deviceClass : DeviceClass } -> Context
classifyContext { width, height, fontSize, deviceClass } =
    let
        autoDevice =
            E.classifyDevice { width = width, height = height }

        device =
            case deviceClass of
                AutoClass ->
                    autoDevice

                Phone ->
                    { autoDevice | class = E.Phone }

                Tablet ->
                    { autoDevice | class = E.Tablet }

                Desktop ->
                    { autoDevice | class = E.Desktop }

        shortSide =
            min width height

        longSide =
            max width height

        defaultEm =
            if longSide > 1280 && shortSide > 900 then
                26

            else if longSide > 1024 && shortSide > 720 then
                24

            else
                22

        em =
            defaultEm + fontSize

        density =
            case device.orientation of
                E.Landscape ->
                    if width > 42 * em && height > 22 * em then
                        Comfortable

                    else if width > 28 * em && height > 16 * em then
                        Compact

                    else
                        Condensed

                E.Portrait ->
                    if width > 28 * em && height > 50 * em then
                        Comfortable

                    else if width > 14 * em && height > 38 * em then
                        Compact

                    else
                        Condensed
    in
    { width = width
    , height = height
    , device = device
    , bigEm = scale { em = em } 2
    , em = em
    , smallEm = scale { em = em } -1
    , density = density
    }


type Density
    = Comfortable
    | Compact
    | Condensed


scale : { a | em : Int } -> Int -> Int
scale { em } n =
    round <| E.modular (toFloat em) 1.25 n


contentWidth : { a | device : { b | orientation : E.Orientation }, width : Int } -> Int
contentWidth { device, width } =
    case device.orientation of
        E.Portrait ->
            width

        E.Landscape ->
            round <| 2 * toFloat width / 3



-- CONSTANTS


borderWidth : number
borderWidth =
    2


roundCorners : E.Attribute msg
roundCorners =
    Border.rounded 24


notSelectable : E.Attribute msg
notSelectable =
    E.htmlAttribute (Html.Attributes.style "user-select" "none")



-- STYLES FOR INTERACTIVE ELEMENTS


focusVisibleOnly : E.Attribute msg
focusVisibleOnly =
    E.htmlAttribute <| Html.Attributes.class "focus-visible-only"


transition : E.Attribute msg
transition =
    E.htmlAttribute <| Html.Attributes.class "button-transition"


defaultShadow : E.Attribute msg
defaultShadow =
    E.htmlAttribute <| Html.Attributes.class "button-shadow"


smallShadow : E.Attribute msg
smallShadow =
    E.htmlAttribute <| Html.Attributes.class "small-shadow"


innerShadow : E.Attribute msg
innerShadow =
    Border.innerShadow { offset = ( 0, 1 ), size = 0, blur = 4, color = E.rgba 0 0 0 0.5 }



-- FONTS


fontFamily : String -> E.Attribute msg
fontFamily font =
    Font.family
        [ Font.typeface font

        -- , Font.sansSerif
        ]


biggestFont : Context -> E.Attr decorative msg
biggestFont context =
    Font.size <| scale context 3


bigFont : Context -> E.Attr decorative msg
bigFont context =
    Font.size <| scale context 2


defaultFontSize : Context -> E.Attr decorative msg
defaultFontSize context =
    Font.size <| context.em


smallFont : Context -> E.Attr decorative msg
smallFont context =
    Font.size <| scale context -1


smallerFont : Context -> E.Attr decorative msg
smallerFont context =
    Font.size <| scale context -2


iconFont : E.Attribute msg
iconFont =
    Font.family [ Font.typeface "Font Awesome 5 Free" ]



-- ICONS


closeIcon : E.Element msg
closeIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F00D}")


backIcon : E.Element msg
backIcon =
    E.el [ iconFont ]
        -- F30A
        (E.text "\u{F060}")


editIcon : E.Element msg
editIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F044}")


deleteIcon : E.Element msg
deleteIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F2ED}")


minusIcon : E.Element msg
minusIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F068}")


plusIcon : E.Element msg
plusIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F067}")


checkIcon : E.Element msg
checkIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F00C}")


warningIcon : E.Element msg
warningIcon =
    E.el [ iconFont, E.centerX, E.paddingXY 24 0, Font.color Color.warning60 ]
        (E.text "\u{F071}")


errorIcon : E.Element msg
errorIcon =
    E.el [ iconFont, E.centerX, E.paddingXY 24 0, Font.color Color.white ]
        (E.text "\u{F071}")


bigWarningIcon : E.Element msg
bigWarningIcon =
    E.el
        [ iconFont, Font.size 48, E.alignLeft, E.alignTop, E.padding 0, Font.color Color.warning60 ]
        (E.text "\u{F071}")


incomeIcon : E.Element msg
incomeIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F067}")


expenseIcon : E.Element msg
expenseIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F068}")


saveIcon : E.Element msg
saveIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F0C7}")


loadIcon : E.Element msg
loadIcon =
    E.el [ iconFont, E.centerX ]
        (E.text "\u{F2EA}")



-- CONTAINERS


dialog :
    Context
    ->
        { key : String
        , content : E.Element msg
        , close : { label : E.Element msg, icon : E.Element msg, color : ButtonColor, onPress : msg }
        , actions : List { label : E.Element msg, icon : E.Element msg, color : ButtonColor, onPress : msg }
        }
    -> E.Element msg
dialog context { key, content, close, actions } =
    if context.device.class == E.Phone || context.device.class == E.Tablet then
        Keyed.el [ E.width E.fill, E.height E.fill ] <|
            ( key
            , E.column
                [ E.width E.fill
                , E.height E.fill
                , E.spacing <| context.em // 2
                ]
                [ E.row
                    [ E.width E.fill
                    , Background.color Color.neutral95
                    , E.htmlAttribute <| Html.Attributes.class "panel-shadow"
                    , E.htmlAttribute <| Html.Attributes.style "z-index" "2"
                    ]
                    (navigationButton context close
                        :: E.el [ E.width E.fill ] E.none
                        :: List.map
                            (\button -> navigationButton context button)
                            actions
                    )
                , E.el [ E.padding <| context.em // 2, E.width E.fill, E.height E.fill, E.clipX ]
                    content
                ]
            )

    else
        let
            buttonRow =
                E.row
                    [ E.width E.fill
                    , E.spacing <| context.em
                    ]
                <|
                    E.el [ E.width E.fill ] E.none
                        :: roundButton context close
                        :: List.map
                            (\button -> roundButton context button)
                            actions
        in
        Keyed.el [ E.width E.fill, E.height E.fill ] <|
            ( key
            , E.column
                [ E.width E.fill
                , E.height E.fill
                , E.spacing <| context.em * 2
                , E.paddingXY (2 * context.em) context.em
                ]
                [ content
                , buttonRow
                ]
            )


toggleSwitch :
    Context
    ->
        { label : String
        , checked : Bool
        , onChange : Bool -> msg
        }
    -> E.Element msg
toggleSwitch context { label, checked, onChange } =
    Input.checkbox
        [ E.width E.fill
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , E.paddingEach { bottom = 0, top = 0, left = context.em // 2, right = 0 }
        ]
        { label =
            Input.labelRight
                [ E.paddingEach { bottom = 0, top = 0, left = context.em // 2, right = context.em // 2 } ]
                (E.el [] (E.text label))
        , checked = checked
        , onChange = onChange
        , icon =
            \v ->
                if v then
                    E.el
                        [ E.width <| E.px <| 2 * context.em
                        , E.height <| E.px <| context.em
                        , E.htmlAttribute <| Html.Attributes.style "transform" "translate(0px,2px)"
                        , E.behindContent <|
                            E.el
                                [ E.centerY
                                , E.width <| E.px <| 2 * context.em
                                , E.height <| E.px <| context.em
                                , Border.rounded context.em
                                , Background.color Color.primary85
                                , innerShadow
                                , transition
                                ]
                                E.none
                        , E.inFront <|
                            E.el
                                [ E.alignRight
                                , E.centerY
                                , E.width <| E.px <| context.em + 4
                                , E.height <| E.px <| context.em + 4
                                , E.htmlAttribute <| Html.Attributes.style "transform" "translate(+2px,-2px)"
                                , Border.rounded context.em
                                , Background.color Color.primary40
                                , smallShadow
                                , transition
                                , E.mouseOver [ Background.color Color.primary50 ]
                                , E.mouseDown [ Background.color Color.primary30 ]
                                ]
                                E.none
                        ]
                        E.none

                else
                    E.el
                        [ E.width <| E.px <| 2 * context.em
                        , E.height <| E.px <| context.em
                        , E.htmlAttribute <| Html.Attributes.style "transform" "translate(0px,2px)"
                        , E.behindContent <|
                            E.el
                                [ E.centerY
                                , E.width <| E.px <| 2 * context.em
                                , E.height <| E.px <| context.em
                                , Border.rounded context.em
                                , Background.color Color.neutral95
                                , innerShadow
                                , transition
                                ]
                                E.none
                        , E.inFront <|
                            E.el
                                [ E.alignLeft
                                , E.centerY
                                , E.width <| E.px <| context.em + 4
                                , E.height <| E.px <| context.em + 4
                                , E.htmlAttribute <| Html.Attributes.style "transform" "translate(-2px,-2px)"
                                , Border.rounded context.em
                                , Background.color Color.neutral70
                                , smallShadow
                                , transition
                                , E.mouseOver [ Background.color Color.neutral80 ]
                                , E.mouseDown [ Background.color Color.neutral60 ]
                                ]
                                E.none
                        ]
                        E.none
        }


radio :
    Context
    ->
        { onChange : option -> msg
        , options : List (Input.Option option msg)
        , selected : Maybe option
        , label : Input.Label msg
        }
    -> E.Element msg
radio _ args =
    Input.radio
        [ Border.width 4, Border.color Color.transparent, focusVisibleOnly ]
        args


radioOption : Context -> value -> E.Element msg -> Input.Option value msg
radioOption context value element =
    let
        em =
            context.em

        dot state =
            E.el
                [ E.width <| E.px em
                , E.height <| E.px em
                , E.centerX
                , E.alignTop
                , Border.rounded 1000
                , Background.color Color.neutral95
                , innerShadow
                , E.padding <| em // 4
                ]
            <|
                case state of
                    Input.Idle ->
                        E.el
                            [ E.width E.fill
                            , E.height E.fill
                            , Border.rounded 1000
                            , Background.color Color.transparent
                            ]
                            E.none

                    Input.Focused ->
                        E.el
                            [ E.width E.fill
                            , E.height E.fill
                            , Border.rounded 1000
                            , Background.color Color.transparent
                            ]
                            E.none

                    Input.Selected ->
                        E.el
                            [ E.width E.fill
                            , E.height E.fill
                            , Border.rounded 1000
                            , Background.color Color.primary40
                            ]
                            E.none
    in
    Input.optionWith value <|
        \state ->
            E.row
                [ E.padding (em // 2)
                , E.spacing <| em // 2
                ]
                [ dot state
                , element
                ]


radioRowOption : value -> E.Element msg -> Input.Option value msg
radioRowOption value element =
    Input.optionWith
        value
        (\state ->
            E.el
                ([ E.centerX
                 , E.paddingXY 16 7
                 , Border.rounded 3
                 , transition
                 ]
                    ++ (case state of
                            Input.Idle ->
                                [ Font.color Color.neutral30
                                , E.mouseDown [ Background.color Color.neutral90 ]
                                , E.mouseOver [ Background.color Color.neutral95 ]
                                ]

                            Input.Focused ->
                                [ E.mouseDown [ Background.color Color.neutral90 ]
                                , E.mouseOver [ Background.color Color.neutral95 ]
                                ]

                            Input.Selected ->
                                [ Font.color (E.rgb 1 1 1)
                                , Background.color Color.primary40
                                , smallShadow
                                , E.mouseDown [ Background.color Color.primary30 ]
                                , E.mouseOver [ Background.color Color.primary40 ]
                                ]
                       )
                )
                element
        )



-- ELEMENTS


pageTitle : Context -> E.Element msg -> E.Element msg
pageTitle context element =
    let
        em =
            context.em
    in
    E.row
        [ E.centerX
        , E.width E.fill
        , E.paddingEach
            { top = 3
            , bottom = em // 4
            , left =
                if context.density == Comfortable then
                    2 * em

                else
                    em // 2
            , right =
                if context.density == Comfortable then
                    2 * em

                else
                    em // 2
            }
        ]
        [ E.el
            [ bigFont context
            , Font.center
            , Font.bold
            , E.padding <| em // 4
            , E.width E.fill
            , E.centerY
            , Background.color Color.neutral95
            , Border.roundEach { topLeft = 32, bottomLeft = 32, topRight = 32, bottomRight = 32 }
            , Font.color Color.neutral40
            , Font.center
            , smallShadow
            ]
            element
        ]


dialogSectionRow : Context -> String -> E.Element msg -> E.Element msg
dialogSectionRow context titleText content =
    E.row [ E.width E.fill, E.spacing <| context.em ]
        [ E.el
            [ Font.color Color.neutral30

            -- , Font.bold
            , E.padding 0
            , notSelectable
            ]
            (E.text titleText)
        , content
        ]


dialogSection : Context -> String -> E.Element msg -> E.Element msg
dialogSection context titleText content =
    E.column [ E.width E.fill, E.spacing <| context.em // 2 ]
        [ E.el
            [ E.width E.fill
            , Font.color Color.neutral30

            -- , Font.bold
            , E.padding 0
            , notSelectable
            ]
            (E.text titleText)
        , E.el [ E.width E.fill, E.paddingXY 0 0 ] content
        ]


warningParagraph : List (E.Element msg) -> E.Element msg
warningParagraph elements =
    E.row
        [ Font.color Color.neutral20
        , E.centerY
        , E.spacing 12
        , E.width E.fill
        , E.height (E.shrink |> E.minimum 48)
        ]
        [ bigWarningIcon
        , E.paragraph [] elements
        ]


warningPopup : Context -> List (E.Element msg) -> E.Element msg
warningPopup context elements =
    E.el
        [ E.padding 18
        , E.centerX
        , notSelectable
        , E.htmlAttribute <| Html.Attributes.style "cursor" "default"
        ]
    <|
        E.paragraph
            [ Font.color Color.neutral10
            , Background.color Color.focus85
            , E.centerY
            , E.spacing 12
            , E.height (E.shrink |> E.minimum 48)
            , E.centerX
            , E.paddingEach { left = 24, right = 24, top = 12, bottom = 12 }
            , E.spacing 6
            , Border.rounded 6
            , E.spacing 12
            , E.above <|
                E.el
                    [ E.centerX
                    , E.alignBottom
                    , iconFont
                    , biggestFont context
                    , Font.color Color.focus85
                    , notSelectable
                    , E.htmlAttribute <| Html.Attributes.style "transform" "translate(0, 18px)"
                    ]
                <|
                    E.text "\u{F0D8}"
            , E.width <| E.px 380
            , Font.center
            , Font.regular
            , notSelectable
            , smallShadow
            ]
            elements


monthNavigationBar : Context -> { a | date : Date, today : Date } -> (Date -> msg) -> E.Element msg
monthNavigationBar context model changeMsg =
    let
        em =
            context.em
    in
    E.row
        [ E.width E.fill
        , E.paddingEach
            { top = 3
            , bottom = em // 4
            , left =
                if context.density == Comfortable then
                    2 * em

                else
                    em // 2
            , right =
                if context.density == Comfortable then
                    2 * em

                else
                    em // 2
            }
        ]
        [ Keyed.row
            [ E.width <| E.fill
            , E.centerX
            , E.alignTop
            , Background.color Color.neutral95
            , Border.roundEach { topLeft = 32, bottomLeft = 32, topRight = 32, bottomRight = 32 }
            , smallShadow
            ]
            [ ( "previous month button"
              , E.el
                    [ E.width (E.fillPortion 2)
                    , E.height E.fill
                    ]
                    (Input.button
                        [ E.width E.fill
                        , E.height E.fill
                        , Border.roundEach { topLeft = 32, bottomLeft = 32, topRight = 0, bottomRight = 0 }
                        , Font.color Color.neutral30
                        , Background.color Color.neutral95
                        , Border.width 4
                        , Border.color Color.transparent
                        , focusVisibleOnly
                        , transition
                        , E.mouseDown [ Background.color Color.neutral90 ]
                        , E.mouseOver [ Background.color Color.neutral98 ]
                        ]
                        { label =
                            E.row
                                [ E.width E.fill ]
                                [ if context.density == Comfortable then
                                    E.el [ E.centerX ]
                                        (E.text (Date.getMonthName (Date.decrementMonth model.date)))

                                  else
                                    E.none
                                , E.el [ E.centerX, iconFont ] (E.text "  \u{F060}  ")
                                ]
                        , onPress = Just (changeMsg (Date.decrementMonthUI model.date model.today))
                        }
                    )
              )
            , ( "current month header"
              , E.el
                    [ E.width (E.fillPortion 3)
                    , E.height E.fill
                    , notSelectable
                    ]
                    (E.el
                        [ E.centerX
                        , Font.bold
                        , if context.density == Comfortable then
                            bigFont context

                          else
                            defaultFontSize context
                        , Font.color Color.neutral30
                        , E.padding <| em // 4
                        ]
                        (E.text (Date.getMonthFullName model.today model.date))
                    )
              )
            , ( "next month button"
              , E.el
                    -- needed to circumvent focus bug in elm-ui
                    [ E.width (E.fillPortion 2)
                    , E.height E.fill
                    ]
                    (Input.button
                        [ E.width E.fill
                        , E.height E.fill
                        , Border.roundEach { topLeft = 0, bottomLeft = 0, topRight = 32, bottomRight = 32 }
                        , Font.color Color.neutral30
                        , Background.color Color.neutral95
                        , Border.width 4
                        , Border.color Color.transparent
                        , focusVisibleOnly
                        , transition
                        , E.mouseDown [ Background.color Color.neutral90 ]
                        , E.mouseOver [ Background.color Color.neutral98 ]
                        ]
                        { label =
                            E.row
                                [ E.width E.fill ]
                                [ E.el [ E.centerX, iconFont ] (E.text "  \u{F061}  ")
                                , if context.density == Comfortable then
                                    E.el [ E.centerX ]
                                        (E.text (Date.getMonthName (Date.incrementMonth model.date)))

                                  else
                                    E.none
                                ]
                        , onPress = Just (changeMsg (Date.incrementMonthUI model.date model.today))
                        }
                    )
              )
            ]
        ]


weekNavigationBar : Context -> { a | date : Date, today : Date } -> (Date -> msg) -> E.Element msg
weekNavigationBar context model changeMsg =
    let
        em =
            context.em
    in
    E.column
        [ E.width E.fill
        , E.paddingEach { top = 3, bottom = 8, left = 3, right = 3 }
        ]
        [ Keyed.row
            [ E.width <| E.fill
            , E.centerX
            , E.alignTop
            , E.spacing <| em // 4
            ]
            [ ( "previous week button"
              , E.el
                    [ E.height E.fill
                    , E.paddingXY (em // 2) 0
                    ]
                    (Input.button
                        [ E.width E.fill
                        , E.height E.fill
                        , E.padding 4
                        , Border.roundEach { topLeft = 32, bottomLeft = 32, topRight = 32, bottomRight = 32 }
                        , Font.color Color.neutral30
                        , Background.color Color.neutral95
                        , smallShadow
                        , Border.width 4
                        , Border.color Color.transparent
                        , focusVisibleOnly
                        , transition
                        , E.mouseDown [ Background.color Color.neutral90 ]
                        , E.mouseOver [ Background.color Color.neutral98 ]
                        ]
                        { label =
                            E.row
                                [ E.width E.fill ]
                                [ E.el [ E.centerX, iconFont ] (E.text "  \u{F060}  ")
                                ]
                        , onPress = Just (changeMsg (Date.decrementWeek model.date))
                        }
                    )
              )
            , ( "current week header"
              , E.el
                    [ E.width E.fill
                    , E.height <| E.px <| 2 * em + em // 2
                    , notSelectable
                    , E.paddingEach { left = 0, right = 0, top = 0, bottom = em // 4 }
                    ]
                    (E.el
                        [ E.centerX
                        , E.centerY
                        , Font.center

                        -- , Font.bold
                        -- , smallFont context
                        , Font.color Color.neutral30
                        , E.padding 6
                        ]
                        (E.paragraph []
                            [ E.text (Date.fancyWeekDescription model.today model.date) ]
                        )
                    )
              )
            , ( "next week button"
              , E.el
                    -- needed to circumvent focus bug in elm-ui
                    [ E.height E.fill
                    , E.paddingXY (em // 2) 0
                    ]
                    (Input.button
                        [ E.width E.fill
                        , E.height E.fill
                        , E.padding 4
                        , Border.roundEach { topLeft = 32, bottomLeft = 32, topRight = 32, bottomRight = 32 }
                        , Font.color Color.neutral30
                        , Background.color Color.neutral95
                        , smallShadow
                        , Border.width 4
                        , Border.color Color.transparent
                        , focusVisibleOnly
                        , transition
                        , E.mouseDown [ Background.color Color.neutral90 ]
                        , E.mouseOver [ Background.color Color.neutral98 ]
                        ]
                        { label =
                            E.row
                                [ E.width E.fill ]
                                [ E.el [ E.centerX, iconFont ] (E.text "  \u{F061}  ")
                                ]
                        , onPress = Just (changeMsg (Date.incrementWeek model.date))
                        }
                    )
              )
            ]
        ]


viewIcon : String -> E.Element msg
viewIcon txt =
    E.el [ E.width (E.shrink |> E.minimum 48), iconFont, Font.center ]
        (E.text txt)


viewDate : Context -> Date -> E.Element msg
viewDate context date =
    E.paragraph
        [ E.width E.fill
        , Font.bold
        , if context.density /= Comfortable then
            defaultFontSize context

          else
            bigFont context
        , Font.color Color.neutral30
        , Font.center
        ]
        [ E.text
            (Date.getWeekdayName date
                ++ " "
                ++ String.fromInt (Date.getDay date)
                ++ " "
                ++ Date.getMonthName date
            )
        ]


viewMoney : Context -> Money.Money -> Bool -> E.Element msg
viewMoney context money future =
    let
        em =
            context.em

        openpar =
            if future then
                "("

            else
                ""

        closepar =
            if future then
                ")"

            else
                ""

        parts =
            Money.toStrings money

        isExpense =
            Money.isExpense money

        isZero =
            Money.isZero money
    in
    E.paragraph
        [ E.width <| E.minimum (4 * em + em // 2) <| E.fill
        , E.alignRight
        , Font.alignRight
        , if future then
            Font.color Color.neutral50

          else if isExpense then
            Font.color Color.expense40

          else if isZero then
            Font.color Color.neutral70

          else
            Font.color Color.income40
        , Font.variant Font.tabularNumbers
        , Font.alignRight
        ]
        (if isZero then
            [ E.el [ E.width (E.fillPortion 75), defaultFontSize context, Font.alignRight ] (E.text "—")
            , E.el [ E.width (E.fillPortion 25) ] E.none
            ]

         else
            [ E.el
                [ E.width (E.fillPortion 75)
                , defaultFontSize context
                , Font.bold
                , Font.alignRight
                ]
                (E.text (openpar ++ parts.sign ++ parts.units ++ ","))
            , E.row
                [ E.width (E.fillPortion 25) ]
                [ E.el
                    [ Font.bold
                    , smallFont context
                    , Font.alignLeft
                    ]
                    (E.text ("" ++ parts.cents))
                , E.el
                    [ defaultFontSize context
                    , Font.bold
                    , Font.alignRight
                    ]
                    (E.text closepar)
                ]
            ]
        )


viewSum : Context -> Money.Money -> E.Element msg
viewSum context money =
    let
        parts =
            Money.toStrings money
    in
    E.row
        [ E.width E.shrink
        , E.height E.shrink
        , E.paddingEach { top = 0, bottom = 0, left = 16, right = 16 }
        ]
        [ E.el
            [ E.width (E.fillPortion 75)
            , bigFont context
            , Font.alignRight
            , Font.bold
            ]
            (E.text (parts.sign ++ parts.units))
        , E.el
            [ E.width (E.fillPortion 25)
            , defaultFontSize context
            , Font.alignLeft
            , E.alignBottom
            , E.paddingXY 0 1
            , Font.bold
            ]
            (E.text ("," ++ parts.cents))
        ]



-- INTERACTIVE ELEMENTS


type ButtonColor
    = PlainButton
    | DangerButton
    | MainButton


roundButton :
    Context
    ->
        { a
            | label : E.Element msg
            , color : ButtonColor
            , onPress : msg
        }
    -> E.Element msg
roundButton context { label, color, onPress } =
    let
        em =
            context.em
    in
    Input.button
        [ Background.color <|
            case color of
                PlainButton ->
                    Color.neutral95

                DangerButton ->
                    Color.warning60

                MainButton ->
                    Color.primary40
        , Font.color <|
            case color of
                PlainButton ->
                    Color.neutral30

                DangerButton ->
                    Color.white

                MainButton ->
                    Color.white
        , Font.center
        , Border.rounded 1000
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , defaultShadow
        , transition
        , E.paddingXY em (em // 4)
        , E.mouseDown
            [ Background.color <|
                case color of
                    PlainButton ->
                        Color.neutral90

                    DangerButton ->
                        Color.warning50

                    MainButton ->
                        Color.primary30
            ]
        , E.mouseOver
            [ Background.color <|
                case color of
                    PlainButton ->
                        Color.neutral98

                    DangerButton ->
                        Color.warning70

                    MainButton ->
                        Color.primary50
            ]
        , E.htmlAttribute <| Html.Attributes.class "focus-visible-only"
        ]
        { onPress = Just onPress
        , label = label
        }


navigationButton :
    Context
    ->
        { a
            | icon : E.Element msg
            , color : ButtonColor
            , onPress : msg
        }
    -> E.Element msg
navigationButton context { icon, color, onPress } =
    let
        em =
            context.em
    in
    Input.button
        [ Background.color Color.transparent
        , Font.color <|
            case color of
                PlainButton ->
                    Color.primary40

                DangerButton ->
                    Color.warning60

                MainButton ->
                    Color.primary40
        , Font.center
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , transition
        , E.padding (em // 2)
        , E.mouseDown
            [ Font.color <|
                case color of
                    PlainButton ->
                        Color.primary30

                    DangerButton ->
                        Color.warning50

                    MainButton ->
                        Color.primary30
            ]
        , E.mouseOver
            [ Font.color <|
                case color of
                    PlainButton ->
                        Color.primary50

                    DangerButton ->
                        Color.warning70

                    MainButton ->
                        Color.primary50
            ]
        , E.htmlAttribute <| Html.Attributes.class "focus-visible-only"
        ]
        { onPress = Just onPress
        , label = icon
        }


incomeButton :
    Context
    -> { onPress : msg, label : E.Element msg }
    -> E.Element msg
incomeButton context { onPress, label } =
    Input.button
        [ E.width <| E.px <| 2 * context.bigEm + context.bigEm // 4
        , E.height <| E.px <| 2 * context.bigEm + context.bigEm // 4
        , Font.color Color.income30
        , Background.color Color.income90
        , Font.center
        , Border.rounded 1000
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , defaultShadow
        , transition
        , E.padding (context.em // 4)
        , E.mouseDown [ Background.color Color.income80, Border.color Color.income80 ]
        , E.mouseOver [ Background.color Color.income95, Border.color Color.income95 ]
        , E.htmlAttribute <| Html.Attributes.class "focus-visible-only"
        ]
        { onPress = Just onPress
        , label = E.el [ E.centerX, E.centerY ] label
        }


expenseButton :
    Context
    -> { onPress : msg, label : E.Element msg }
    -> E.Element msg
expenseButton context { onPress, label } =
    Input.button
        [ E.width <| E.px <| 2 * context.bigEm + context.bigEm // 4
        , E.height <| E.px <| 2 * context.bigEm + context.bigEm // 4
        , Background.color Color.expense90
        , Font.color Color.expense30
        , Font.center
        , Border.rounded 1000
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , defaultShadow
        , transition
        , E.padding (context.em // 4)
        , E.mouseDown [ Background.color Color.expense80, Border.color Color.expense80 ]
        , E.mouseOver [ Background.color Color.expense95, Border.color Color.expense95 ]
        , focusVisibleOnly
        ]
        { onPress = Just onPress
        , label = E.el [ E.centerX, E.centerY ] label
        }


flatButton :
    { onPress : Maybe msg, label : E.Element msg }
    -> E.Element msg
flatButton { onPress, label } =
    Input.button
        [ Background.color Color.transparent
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , transition
        , E.paddingXY 20 4
        , Font.color Color.primary40
        , E.mouseDown [ Font.color Color.primary30 ]
        , E.mouseOver [ Font.color Color.primary50 ]
        , E.htmlAttribute <| Html.Attributes.class "focus-visible-only"
        ]
        { onPress = onPress
        , label = label
        }


iconButton :
    { onPress : Maybe msg, icon : E.Element msg }
    -> E.Element msg
iconButton { onPress, icon } =
    Input.button
        [ Background.color Color.white
        , Font.color Color.primary40
        , Font.center
        , roundCorners
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , E.padding 4
        , E.width (E.shrink |> E.minimum 64)
        , E.height (E.px 48)
        , E.mouseDown [ Background.color Color.neutral90 ]
        , E.mouseOver [ Background.color Color.neutral95 ]
        ]
        { onPress = onPress
        , label = icon
        }


reconcileCheckBox :
    Context
    -> { state : Bool, onPress : Maybe msg, background : E.Color }
    -> E.Element msg
reconcileCheckBox context { state, onPress, background } =
    let
        em =
            context.em
    in
    Input.button
        [ Font.color Color.primary40
        , Font.center
        , E.width <| E.px <| 2 * em
        , E.height <| E.px <| 2 * em
        , E.alignRight
        , Background.color (E.rgba 1 1 1 1)
        , Border.width 4
        , Border.color background
        , focusVisibleOnly
        , E.padding 2
        , innerShadow
        , transition
        , E.mouseDown [ Background.color Color.neutral90 ]
        , E.mouseOver []
        ]
        { onPress = onPress
        , label =
            if state then
                checkIcon

            else
                E.none
        }


radioButton : Context -> { a | onPress : Maybe msg, icon : String, label : String, active : Bool } -> E.Element msg
radioButton context { onPress, icon, label, active } =
    let
        em =
            context.em
    in
    Input.button
        ([ Border.rounded 4
         , E.paddingXY 4 4
         , E.width E.fill
         , Border.width 4
         , Border.color Color.transparent
         , focusVisibleOnly
         , transition
         ]
            ++ (if active then
                    [ Font.color Color.white
                    , Background.color Color.primary40
                    , smallShadow
                    , E.mouseDown [ Background.color Color.primary30 ]
                    , E.mouseOver [ Background.color Color.primary40 ]
                    ]

                else
                    [ Font.color Color.primary40
                    , Background.color Color.white
                    , E.mouseDown [ Background.color Color.neutral90 ]
                    , E.mouseOver [ Background.color Color.neutral95 ]
                    ]
               )
        )
        { onPress = onPress
        , label =
            E.row []
                [ if icon /= "" then
                    E.el [ E.width (E.shrink |> E.minimum (em + em // 2)), iconFont, Font.center ]
                        (E.text icon)

                  else
                    E.none
                , if label /= "" then
                    E.text (" " ++ label)

                  else
                    E.none
                ]
        }


labelAbove : Context -> String -> Input.Label msg
labelAbove context txt =
    Input.labelAbove [ E.paddingEach { left = 0, right = 0, top = 0, bottom = context.em // 2 } ] (E.text txt)


labelLeft : Context -> String -> Input.Label msg
labelLeft context txt =
    Input.labelLeft [ E.paddingEach { left = 0, right = context.em // 2, top = 0, bottom = 0 } ] (E.text txt)


textInput : { label : Input.Label msg, text : String, onChange : String -> msg } -> E.Element msg
textInput args =
    Input.text
        [ E.width <| E.fill
        , Border.width 4
        , Border.color Color.white
        , Background.color Color.neutral98
        , innerShadow
        , E.focused
            [ Border.color Color.focus85
            ]
        , Font.color Color.neutral20
        , E.htmlAttribute <| Html.Attributes.autocomplete False
        ]
        { label = args.label
        , text = args.text
        , placeholder = Nothing
        , onChange = args.onChange
        }


moneyInput :
    Context
    ->
        { label : Input.Label msg
        , color : E.Color
        , state : ( String, Maybe String )
        , onChange : String -> msg
        }
    -> E.Element msg
moneyInput context args =
    let
        minWidth =
            6 * context.em
    in
    Input.text
        [ E.paddingXY 8 12
        , E.width (E.shrink |> E.minimum minWidth)
        , E.alignLeft
        , Border.width 4
        , Border.color Color.white
        , Background.color Color.neutral98
        , innerShadow
        , E.focused
            [ Border.color Color.focus85
            ]
        , E.htmlAttribute <| Html.Attributes.id "dialog-focus"
        , E.htmlAttribute <| Html.Attributes.autocomplete False
        , E.htmlAttribute <| Html.Attributes.attribute "inputmode" "numeric"
        , Font.color args.color
        , case Tuple.second args.state of
            Just error ->
                E.below <|
                    warningPopup context
                        [ E.text error ]

            _ ->
                E.below <| E.none
        ]
        { label = args.label
        , text = Tuple.first args.state
        , placeholder = Nothing
        , onChange = args.onChange
        }



-- ATTRIBUTES


onEnter : msg -> E.Attribute msg
onEnter msg =
    E.htmlAttribute
        (Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )



-- HELP ELEMENTS


helpList : List (E.Element msg) -> E.Element msg
helpList listItems =
    let
        withBullet para =
            E.row []
                [ E.column [ E.height E.fill ]
                    [ E.el [ E.paddingXY 6 0 ] (E.text "•")
                    , E.el [ E.height E.fill ] E.none
                    ]
                , para
                ]
    in
    E.column [ E.spacing 24 ]
        (List.map withBullet listItems)


helpNumberedList : List (E.Element msg) -> E.Element msg
helpNumberedList listItems =
    let
        withBullet index para =
            E.row
                []
                [ E.column [ E.height E.fill, E.spacing 0 ]
                    [ E.el [ E.width (E.px 48), Font.center ] (E.text (String.fromInt (index + 1) ++ "."))
                    , E.el [ E.height E.fill ] E.none
                    ]
                , para
                ]
    in
    E.column
        [ E.spacing 24
        ]
        (List.indexedMap withBullet listItems)


helpListItem : List (E.Element msg) -> E.Element msg
helpListItem texts =
    E.paragraph
        [ Font.color Color.neutral30
        , E.padding 0
        ]
        texts


helpImage : String -> String -> E.Element msg
helpImage src description =
    E.image
        [ E.centerX
        ]
        { src = src, description = description }


linkButton : { label : E.Element msg, onPress : Maybe msg } -> E.Element msg
linkButton { label, onPress } =
    Input.button
        [ Font.color Color.primary40
        , Font.underline
        , Border.width 4
        , Border.color Color.transparent
        , focusVisibleOnly
        , E.mouseDown [ Font.color Color.primary30 ]
        , E.mouseOver [ Font.color Color.primary50 ]
        , transition
        ]
        { label = label
        , onPress = onPress
        }



-- TEXT


textColumn : Context -> List (E.Element msg) -> E.Element msg
textColumn context elements =
    E.column
        [ E.width E.fill
        , E.spacing context.em
        ]
        (elements
            |> List.map
                (\el ->
                    E.el
                        [ E.centerX
                        , E.width <| E.maximum (paragraphWidth context) <| E.fill
                        , E.padding 6
                        ]
                        el
                )
        )


paragraphWidth : Context -> Int
paragraphWidth context =
    let
        w =
            32 * context.em
    in
    if w > 940 then
        940

    else
        w


title : Context -> String -> E.Element msg
title context txt =
    E.paragraph
        [ bigFont context
        , Font.bold
        , Font.color Color.neutral30
        ]
        [ E.text txt ]


verticalSpacer : E.Element msg
verticalSpacer =
    E.el [ E.height (E.px 0) ] E.none


paragraph : String -> E.Element msg
paragraph txt =
    E.paragraph
        [ Font.color Color.neutral30
        ]
        [ E.text txt ]


paragraphParts : List (E.Element msg) -> E.Element msg
paragraphParts parts =
    E.paragraph
        [ Font.color Color.neutral30
        ]
        parts


text : String -> E.Element msg
text txt =
    E.text txt


boldText : String -> E.Element msg
boldText txt =
    E.el [ Font.bold ] (E.text txt)
