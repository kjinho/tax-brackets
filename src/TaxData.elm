module TaxData exposing (..)
import Browser
import Html exposing (Html, div, table, th, tr, td, tbody, text)
import Html.Attributes exposing (class)
import Numeral exposing (format)


type alias BracketRate = (Float,Float)
type alias Brackets = List BracketRate
type Msg
    = Change String


taxbracket2023single : Brackets
taxbracket2023single = [ (578126.00,0.37)
                       , (231251.00,0.35)
                       , (182101.00,0.32)
                       , (95376.00,0.24)
                       , (44726.00,0.22)
                       , (11001.00,0.12)
                       , (0.00,0.10)
                       ]
standarddeduction2023single : Float
standarddeduction2023single = 13850.00

dataformatted : Brackets -> List ( String, String )
dataformatted bracket =
    let
        lowerbounds = 
            bracket 
            |> List.map (\(x,_) -> format "$0,0" x)
        
        upperbounds = 
            " or more"::(bracket 
                         |> List.map (\(x,_) -> format "$0,0" (x - 1.00))
                         |> List.map (\x -> " to " ++ x))
        
        rates =
            bracket
            |> List.map (\(_,y) -> format "0%" y)
    in
        List.map3 (\x y z -> (x,y++z)) 
            rates lowerbounds upperbounds
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
    div [] [ bracketdiv  
           ]

deductiondiv : Html msg
deductiondiv = 
    div [] [ text "Standard Deduction: "
           , text (format "$0,0.00" standarddeduction2023single) ]

bracketdiv : Html msg
bracketdiv =
    table [class "table"] 
          [ tr [] [ th [] [text "Tax rate"]
                  , th [] [text "Income range"]
                  ]
          , tbody [] (taxbracketrows (dataformatted taxbracket2023single))
          ]

taxbracketrows : List ( String, String ) -> List (Html msg)
taxbracketrows formattedbracket = 
    List.map 
        (\ (x,y) -> tr [] [ td [] [text x]
                            , td [] [text y]
                            ])
        formattedbracket

update : Msg -> b -> ( Model, Cmd msg )
update _ _ =
    ( () , Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none 

