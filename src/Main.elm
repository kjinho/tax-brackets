module Main exposing (Model, Msg, main, update, view)

import Parser
import Browser
import Html exposing (div, input, text)
import Html.Events exposing (onInput)
import Html.Attributes exposing (placeholder)

import Numeral exposing (format)

-- import Browser.Dom exposing (Error)


main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model =
    { content: Maybe Float
    }

init: Model
init = { content = Just 100.00 }

type Msg
    = Change String

parseInput str model =
    case str |> Parser.run Parser.float of
        Ok f -> { content = Just f }
        Err _ -> { content = Nothing }
      
update msg model =
    case msg of
        Change newContent -> parseInput newContent model

modelToTaxesString model =
    case model.content of
        Just f ->
            calculatetaxes taxbracket2023single (f - standarddeduction2023single)
            |> format "$0,0.00"
        Nothing -> "Bad Input"

modelToTaxRateString model =
    case model.content of
        Just f ->
            calculateEffectiveTaxRate taxbracket2023single standarddeduction2023single f
            |> format "0%"
        Nothing -> "Bad Input"
                   
view model =
    div []
        [ div [] [ text "Tax Year 2023" ]
        , div [] [ div [] [ div [] [text "Annual Income: "]
                          , input [ placeholder "Income"
                                  -- , value (modelToString model)
                                  , onInput Change] []
                          ] ]
        , div [] [ div [] [ div [] [text "Federal Income Tax: "]
                          , div [] [text (modelToTaxesString model) ]]
                 , div [] [ div [] [text "Effective Federal Tax Rate: "]
                          , div [] [text (modelToTaxRateString model) ] ]]
        ]

taxbracket2023single = [ (578126.00,0.37)
                       , (231251.00,0.35)
                       , (182101.00,0.32)
                       , (95376.00,0.24)
                       , (44726.00,0.22)
                       , (11001.00,0.12)
                       , (0.00,0.10)
                       ]
standarddeduction2023single = 13850.00

calculatetaxesHelper bracket taxableIncome =
    let reducer = \ (bi,bt) (i,t) ->
                  if i > bi
                  then (bi,t+(bt*(i-bi)))
                  else (i,t)
    in
    List.foldl reducer (taxableIncome,0.00) bracket
        
calculatetaxes bracket taxableIncome =
    case calculatetaxesHelper bracket taxableIncome of
        (_, t) -> t

calculateEffectiveTaxRate bracket deduction income =
    let taxableIncome = if income > deduction
                        then income - deduction
                        else 0
    in
    (calculatetaxes bracket taxableIncome) / income
