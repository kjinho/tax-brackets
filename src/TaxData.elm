module TaxData exposing (..)
import Browser
import Html exposing (Html, div, table, th, tr, td, tbody, text)
import Html.Attributes exposing (class)
import Numeral exposing (format)


type alias BracketRate = (Float,Float)
type alias Brackets = List BracketRate
type Msg
    = Change String


taxBracket2023single : Brackets
taxBracket2023single = [ (578126.00,0.37)
                       , (231251.00,0.35)
                       , (182101.00,0.32)
                       , (95376.00,0.24)
                       , (44726.00,0.22)
                       , (11001.00,0.12)
                       , (0.00,0.10)
                       ]
standardDeduction2023single : Float
standardDeduction2023single = 13850.00

dataFormatted : Brackets -> List ( String, String )
dataFormatted bracket =
    let
        lowerBound = 
            bracket 
            |> List.map (\(x,_) -> format "$0,0" x)
        
        upperBound = 
            " or more"::(bracket 
                         |> List.map (\(x,_) -> format "$0,0" (x - 1.00))
                         |> List.map (\x -> " to " ++ x))
        
        rates =
            bracket
            |> List.map (\(_,y) -> format "0%" y)
    in
        List.map3 (\x y z -> (x,y++z)) 
            rates lowerBound upperBound
        |> List.reverse
    

main : Program () Model Msg
main =
    Browser.element { init = init
                     , view = view
                     , update = update
                     , subscriptions = subscriptions
                     }

-- MODEL

type alias Model = ()

init : () -> (Model, Cmd Msg)
init _ = ( ()
         , Cmd.none
         )

view : Model -> Html Msg
view _ = 
    div [] [ bracketDiv  
           ]

deductionDiv : Html msg
deductionDiv = 
    div [] [ text "Standard Deduction: "
           , text (format "$0,0.00" standardDeduction2023single) ]

bracketDiv : Html msg
bracketDiv =
    table [class "table"] 
          [ tr [] [ th [] [text "Tax rate"]
                  , th [] [text "Income range"]
                  ]
          , tbody [] (taxBracketRows (dataFormatted taxBracket2023single))
          ]

taxBracketRows : List ( String, String ) -> List (Html msg)
taxBracketRows formattedBracket = 
    List.map 
        (\ (x,y) -> tr [] [ td [] [text x]
                            , td [] [text y]
                            ])
        formattedBracket

update : Msg -> b -> ( Model, Cmd msg )
update _ _ =
    ( () , Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none 

