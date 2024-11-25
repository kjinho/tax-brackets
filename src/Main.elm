module Main exposing (Model, Msg, update, view, main)

import TaxData exposing (..)
import Parser
import Browser
import Html exposing (Html, div, input, text, table, caption, tbody, tr, th, td)
import Html.Events exposing (onInput)
import Html.Attributes exposing (class, placeholder)

import Numeral exposing (format)

main : Program () Model Msg
main =
    Browser.element { init = init
                     , view = view
                     , update = update
                     , subscriptions = subscriptions
                     }

-- MODEL

type alias Model =
    { content: Maybe Float
    }

init : () -> (Model, Cmd Msg)
init _ = ( { content = Just 100.00}
         , Cmd.none
         )

type Msg
    = Change String

parseInput : String -> Model
parseInput str =
    let
        cleanInput = str
                     |> String.replace "$" ""
                     |> String.replace "," ""
                     |> Parser.run Parser.float
    in
        case cleanInput of
            Ok f -> { content = Just f }
            Err _ -> { content = Nothing }
      
update : Msg -> b -> ( Model, Cmd msg )
update msg _ =
    case msg of
        Change newContent -> ( parseInput newContent , Cmd.none )

-- VIEWS

modelToTaxesString : Model -> String
modelToTaxesString model =
    case model.content of
        Just f ->
            calculatetaxes taxbracket2023single (f - standarddeduction2023single)
            |> format "$0,0"
        Nothing -> "Bad Input"

modelToTaxRateString : Model -> String
modelToTaxRateString model =
    case model.content of
        Just f ->
            calculateEffectiveTaxRate taxbracket2023single standarddeduction2023single f
            |> format "0.0%"
        Nothing -> "Bad Input"

view : Model -> Html Msg
view model = 
    viewHelper model

viewHelper : Model -> Html.Html Msg
viewHelper model =
    div []
        [ maintable [class "table"] model ]

maintable : List (Html.Attribute Msg) -> Model -> Html.Html Msg
maintable attributes model = 
    table attributes [ caption [] [ text "Tax Year 2023" 
                          , tbody [] [ tr [] [ th [] [text "Annual Income"]
                                             , td [] [input [ placeholder "Income"
                                                     , onInput Change ] [] ]]
                                     , trrow [] [ text "Federal Income Tax" 
                                                , text (modelToTaxesString model) ]
                                     , trrow [] [ text "Effective Federal Tax Rate"
                                                , text (modelToTaxRateString model) ]]]]

trrow : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
trrow attributes contents =
    case contents of 
        [] -> tr attributes []
        a::c -> tr attributes ((th [] [a])::(List.map (\x -> x) c))

type alias BracketRate = (Float,Float)
type alias Brackets = List BracketRate

calculatetaxesHelper : Brackets -> Float -> ( Float, Float )
calculatetaxesHelper bracket taxableIncome =
    let reducer = \ (bi,bt) (i,t) ->
                  if i > bi
                  then (bi,t+(bt*(i - bi)))
                  else (i,t)
    in
    List.foldl reducer (taxableIncome,0.00) bracket
        
calculatetaxes : Brackets -> Float -> Float
calculatetaxes bracket taxableIncome =
    case calculatetaxesHelper bracket taxableIncome of
        (_, t) -> t

calculateEffectiveTaxRate : Brackets -> Float -> Float -> Float
calculateEffectiveTaxRate bracket deduction income =
    let taxableIncome = if income > deduction
                        then income - deduction
                        else 0
    in
    (calculatetaxes bracket taxableIncome) / income

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none