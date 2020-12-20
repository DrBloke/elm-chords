module Ukulele exposing (main)

import Browser
import Chords exposing (Voicing)
import Chords.Chart
import Html exposing (Html)
import Html.Attributes as Attr
import Instruments.Ukulele as Ukulele


type alias Model =
    { chords : List (String) }


initialModel : Model
initialModel =
    { chords =
        [ ("C 1")
        , ("Dm 1")
        , ("Em 1")
        , ("F 1")
        , ("G 1")
        , ("Am 1")
        , ("Bdim 1")
        ]
    }


type Msg
    = NoOp


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


view : Model -> Html msg
view model =
    let
        ukulele =
            { tuning = Ukulele.defaultTuning
            , numFrets = 12
            }

        content =
            model.chords
                |> List.map (\elem -> (  elem, Chords.parseChordVariation  elem ))
                |> List.map
                    (\( name, result ) ->
                        case result of
                            Ok (chord, variation) ->
                                Ukulele.voicings ukulele chord
                                    |> List.drop (variation - 1) 
                                    |> List.head
                                    |> Maybe.map (viewChart name)
                                    |> Maybe.withDefault
                                        (Html.text ("Could not find voicing for " ++ name))

                            Err err ->
                                Html.text ("Could not parse chord " ++ name)
                    )
    in
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flexDirection" "row"
        , Attr.style "flexWrap" "wrap"
        ]
        content


viewChart : String -> Voicing -> Html msg
viewChart name voicing =
    Html.div
        [ Attr.style "width" "150px"
        ]
        [ Chords.Chart.view name voicing
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model
