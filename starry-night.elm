port module VanGogh exposing (..)

import Html exposing (div, span, button, text, Attribute, img, Html, program)
import Html.Events exposing (onClick, onMouseOver, onMouseOut)
import Html.Attributes as Html exposing (style, src, width, height)
import Mouse exposing (Position)

import Svg exposing (rect, svg, Svg)
import Svg.Attributes as Svg exposing (width, height, viewBox, x, y, fill)

import Array exposing (..)

import Time exposing (Time, second)


main =
  program { init = init, view = view, update = update, subscriptions = subscriptions}

-- Elm does not save us from CSS it only makes it more manageable
-- https://developer.mozilla.org/en-US/docs/Web/CSS/display
-- https://developer.mozilla.org/en-US/docs/Web/CSS/float

subscriptions: Model -> Sub Msg
subscriptions model = Sub.batch [ Mouse.moves MouseLocation, getImageData GetImage  ]

-- http://package.elm-lang.org/packages/elm-lang/core/4.0.5/Array
-- http://package.elm-lang.org/packages/elm-lang/core/4.0.5/List
type alias Model = { n: Int, x: Int, y: Int, p: Bool, img: Array Int }

type QuadTree a = Empty | Node a (QuadTree a) (QuadTree a) (QuadTree a) (QuadTree a)


init : ( Model, Cmd Msg )
init = ( { n = 0, x = 0, y = 0, p= False , img = Array.empty} , Cmd.none  )

buttonStyle : Attribute msg
buttonStyle = style [ ("width", "25px"), ("display", "inline-block") ]

numStyle : Attribute msg
numStyle = style [ ("width", "25px"),("display", "inline-block"), ("text-align", "center")]

display : Model -> Html Msg
display model =
  if model.p
    then text <| "Mouse Location:" ++ " ( " ++ (toString model.x) ++ "," ++ (toString model.y) ++ " )"
  else
    text <| "Mouse Location:" ++ " -------- "

-- idiosyncracy
-- Svg.width  : String -> Attribute Msg
-- Html.width : Int    -> Attribute Msg

toHex: Maybe Int -> String
toHex x = case x of
  Just a -> toString a
  Nothing -> "255"


getR: Array Int -> (Int, Int) -> String
getR image (x,y) = toHex  <| get ( x*4 + 500*4*y     ) image

getG: Array Int -> (Int, Int) -> String
getG image (x,y) = toHex  <| get ( x*4 + 500*4*y + 1 ) image

getB: Array Int -> (Int, Int) -> String
getB image (x,y) = toHex  <| get ( x*4 + 500*4*y + 2 ) image

getColor: Array Int -> (Int,Int) -> String
getColor image x = "rgb(" ++ (getR image x) ++ "," ++ (getG image x) ++ "," ++ (getB image x) ++ ")"


square: Model -> Html Msg
square model =
  if model.p then
    svg [ Svg.width "20", Svg.height "20", Svg.viewBox "0 0 20 20"] [ rect [ Svg.x "0", Svg.y "0", Svg.width "20", Svg.height "20", Svg.fill <| getColor model.img (model.x, model.y)] [] ]
  else
    svg [ Svg.width "20", Svg.height "20", Svg.viewBox "0 0 20 20"] [ rect [ Svg.x "0", Svg.y "0", Svg.width "20", Svg.height "20", Svg.fill "rgb(255,255,255)"            ] [] ]

f : Model -> Int -> Svg Msg
f model t = rect [ Svg.x "0", Svg.y "0", Svg.width "10", Svg.height "10", Svg.fill "#A0A0A0"] []

pixel : Model -> Svg Msg
pixel model = svg [ Svg.width "500" , Svg.height "500" ]
  <| Array.toList <| Array.map (\x -> f model x ) <| Array.fromList
  <| List.map (\x -> 10000*x) <| List.range 0 <| (Array.length model.img ) // 10000

view: Model -> Html Msg
view model =

  div [ Html.width 500 ] [
    div [   ]
      [ div [ style [ ("width", "200px"), ("text-align", "left")  , ("display", "inline-block")] ] [ display model ]
      , div [ style [ ("width", "100px"), ("text-align", "left")  , ("display", "inline-block")] ] [ text <| getColor model.img (model.x, model.y)  ]
      , div [ style [ ("width", "75px") , ("text-align", "center"), ("display", "inline-block")] ] [ square model ]
      , button [onClick CheckImage ] [ text "pixelate"]
      ]
    , div [ Html.width 500, style [ ("float", "left")]  ] [img [ src "starry-night.jpg", Html.width 500, Html.height 300,  onMouseOver ShowLocation, onMouseOut HideLocation] [] ]
    , div [ Html.width 500 ] [ pixel model ]
    ]

type Msg = MouseLocation Position | ShowLocation | HideLocation | CheckImage | GetImage ( Array Int )



-- our example could be read mouse locaation (over image) and return color of pixel at mouse location

update: Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    MouseLocation pt->
      ( {model| x = pt.x - 10, y = pt.y - 35} , Cmd.none )
    ShowLocation ->
      ( {model | p  = True } , Cmd.none)
    HideLocation ->
      ( {model | p = False } , Cmd.none)
    CheckImage ->
      ( model, checkImageData "starry-night.jpg" )
    GetImage x ->
      ( {model | img = x  }, Cmd.none )

port checkImageData : String -> Cmd msg

port getImageData: (Array Int -> msg ) -> Sub msg
