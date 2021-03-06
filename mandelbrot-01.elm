import Html exposing (Html, Attribute, button, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Svg exposing (Svg, svg, g, line)
import Svg.Attributes exposing (x1, x2, y1, y2, stroke)


main =
  Html.beginnerProgram { model = model, view = view, update = update }


-- MODEL

--type Model = List (PoFloat, PoFloat)
type alias Model = List ((Float, Float),(Float, Float))

type alias Point = { x: Float, y: Float}

model : Model
model =
--  List.map (\(a,b) -> Point (a,b))
  [ ((0,0), (0,1))
  , ((0,1), (1,1))
  , ((1,1), (1,0))
  , ((1,0), (0,0))
  ]

-- model = [((0,0.5),(0,1))]

t : ((Float, Float),(Float, Float)) -> List ((Float, Float),(Float, Float))
t ((a,b), (c,d)) =
  let
    eps = -0.03
    ht  = 0.45
    p1 = ( a,b )
    p2 = ( (0.5-eps)*a+(0.5+eps)*c , (0.5-eps)*b+(0.5+eps)*d  )
    p3 = ( 0.5*(a+c) + ht*(d-b) , 0.5*(b+d) - ht*(c-a) )
    p4 = ( (0.5+eps)*a+(0.5-eps)*c , (0.5+eps)*b+(0.5-eps)*d )
    p5 = ( c,d  )
  in
    [ (p1, p2)
    , (p2, p3)
    , (p3, p4)
    , (p4, p5)
    ]
-- UPDATE

type Msg = Increment | Decrement

update : Msg -> Model -> Model
update msg model =
  case msg of

    -- > List.map (\x -> x + 1)
    -- <function> : List number -> List number
    Increment -> ( List.concat << List.map t ) model

    Decrement -> model


-- VIEW

view : Model -> Html Msg
view model =
    div [ style [("padding", "5px")]]
      [ div [ style [("display", "inline-block"), ("width", "50px")] ] [ button [ onClick Decrement ] [ text "-" ] ]
      , div [ style [("display", "inline-block"), ("font-family", "Courier")] ] [ div [] [ (text << toString << List.sum << List.map (\x -> 1)) model ] ]
      , div [ style [("display", "inline-block"), ("width", "50px")] ] [ button [ onClick Increment ] [ text "+" ] ]
      , div [ style [("margin-top", "5px")] ] [ svg [ style [("width", "520"), ("height", "520"), ("background-color", "#E0E0E0")]]
          [   g []
          <|  List.map (\((a,b), (c,d)) -> line [ x1 a, x2 c, y1 b, y2 d , stroke "#000000"] [] )
          <|  List.map (\((a,b), (c,d)) -> ((toString a, toString b), (toString c, toString d)) )
          <|  List.map (\((a,b), (c,d)) -> ((a+10, b+10),(c+10,d+10))   )
          <|  List.map (\((a,b), (c,d)) -> ((500*a, 500*b), (500*c, 500*d)) )
          <|  model
          ]
        ]
      , div [ style [ ("height", "500px"), ("overflow-x", "auto"), ("overflow-y", "auto"), ("width", "500px")] ]
          [ div [ style [("font-family", "courier"), ("display", "inline-block")] ]
            <| List.map (\x -> div [] [ ( text << toString )  x ] )
            <| List.map (\((a,b),(c,d)) -> (c-a, d-b)) model
          , div [ style [("font-family", "courier"), ("display", "inline-block")] ]
            <| List.map (\(t,x) ->
              case t % 2 of
                0 -> div [ style [("background-color", "#D6E8C8")] ] [ ( text << toString )  x ]
                1 -> div [ style [("background-color", "#FEFEFE")] ] [ ( text << toString )  x ]
                _ -> div [] []
              )
            <| List.map2 (,) (List.range 0 ((List.sum << List.map (\x -> 1)) model)) model
          ]
      ]
