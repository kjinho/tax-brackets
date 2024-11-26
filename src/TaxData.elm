module TaxData exposing (..)

import Browser
import Html exposing (Html, div, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class)
import String


type alias BracketRate =
    ( Int, Int )


type alias Brackets =
    List BracketRate


type Msg
    = Change String


formatIntPadded : Int -> String
formatIntPadded n =
    if n < 10 then
        "00" ++ String.fromInt n

    else if n < 100 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


formatIntHelper : List String -> Int -> String
formatIntHelper result n =
    if n < 1000 then
        String.fromInt n
            :: result
            |> String.join ","

    else
        let
            rem =
                remainderBy 1000 n

            str =
                formatIntPadded rem
        in
        formatIntHelper (str :: result) (n // 1000)


formatInt : Int -> String
formatInt =
    formatIntHelper []


taxBracket2023single : Brackets
taxBracket2023single =
    [ ( 578120, 37 )
    , ( 231250, 35 )
    , ( 182100, 32 )
    , ( 95375, 24 )
    , ( 44725, 22 )
    , ( 11000, 12 )
    , ( 0, 10 )
    ]


standardDeduction2023single : Int
standardDeduction2023single =
    13850


dataFormatted : Brackets -> List ( String, String )
dataFormatted bracket =
    let
        lowerBound =
            bracket
                |> List.map (\( x, _ ) -> "$" ++ formatInt (x + 1))

        upperBound =
            " or more"
                :: (bracket
                        |> List.map (\( x, _ ) -> "$" ++ formatInt x)
                        |> List.map (\x -> " to " ++ x)
                   )

        rates =
            bracket
                |> List.map (\( _, y ) -> formatInt y ++ "%")
    in
    List.map3 (\x y z -> ( x, y ++ z ))
        rates
        lowerBound
        upperBound
        |> List.reverse


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    ( ()
    , Cmd.none
    )


view : Model -> Html Msg
view _ =
    div []
        [ bracketDiv
        ]


deductionDiv : Html msg
deductionDiv =
    div []
        [ text "Standard Deduction: "
        , text ("$" ++ formatInt standardDeduction2023single)
        ]


bracketDiv : Html msg
bracketDiv =
    table [ class "table" ]
        [ tr []
            [ th [] [ text "Tax rate" ]
            , th [] [ text "Income range" ]
            ]
        , tbody [] (taxBracketRows (dataFormatted taxBracket2023single))
        ]


taxBracketRows : List ( String, String ) -> List (Html msg)
taxBracketRows formattedBracket =
    List.map
        (\( x, y ) ->
            tr []
                [ td [] [ text x ]
                , td [] [ text y ]
                ]
        )
        formattedBracket


update : Msg -> b -> ( Model, Cmd msg )
update _ _ =
    ( (), Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
