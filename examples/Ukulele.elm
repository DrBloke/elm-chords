module Ukulele exposing (main)

import Browser
import Chords exposing (Voicing)
import Chords.Chart
import Html exposing (Html)
import Html.Attributes as Attr
import Instruments.Ukulele as Ukulele


type alias Model =
    { chords : String }


initialModel : Model
initialModel =
    { chords =
        "Am Em-2 C"
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
            case Chords.parseChordSequence model.chords of
                Ok chordsWithVariation ->
                    chordsWithVariation
                           |> List.map
                            (\{name, chord, variation} ->
                                        Ukulele.voicings ukulele chord
                                            |> List.drop (variation - 1) 
                                            |> List.head
                                            |> Maybe.map (viewChart name)
                                            |> Maybe.withDefault
                                                (Html.text ("Could not find voicing for " ++ name))
                            )

                Err err ->
                                [Html.text ("Could not parse chord sequence")]
                    
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
