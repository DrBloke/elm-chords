module Ukulele exposing (main)

import Browser
import Chords exposing (Voicing)
import Chords.Chart
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Instruments.Ukulele as Ukulele


type alias Model =
    { chords : String
    , variations : String
    }


initialModel : Model
initialModel =
    { chords =
        "Am Em-2 C"
    , variations =
        "Em-2"
    }


type Msg
    = NoOp
    | ChangeChordList String
    | ChangeDefaultVariations String


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


view : Model -> Html Msg
view model =
    let
        ukulele =
            { tuning = Ukulele.defaultTuning
            , numFrets = 12
            }

        variations =
            case Chords.parseChordSequence model.variations of
                Ok chordsWithVariation ->
                    chordsWithVariation
                        |> List.map
                            (\{ name, chord, variation } ->
                                ( name, variation )
                            )

                Err err ->
                    []

        content =
            let 
                chordsWithDefault =
                    String.split " " model.chords
                    |> List.map (\chord -> 
                        case List.filter (\(defaultChord, variation) -> chord == defaultChord) variations of
                            [] ->
                                chord
                            (_, variation) :: xs ->
                                chord ++ "-" ++ (String.fromInt variation)
                    )
                    |> String.join " "
            in
            case Chords.parseChordSequence chordsWithDefault of
                Ok chordsWithVariation ->
                    chordsWithVariation
                        |> List.map
                            (\{ name, chord, variation } ->
                                Ukulele.voicings ukulele chord
                                    |> List.drop (variation - 1)
                                    |> List.head
                                    |> Maybe.map (viewChart name)
                                    |> Maybe.withDefault
                                        (Html.text ("Could not find voicing for " ++ name))
                            )

                Err err ->
                    [ Html.text "Could not parse chord sequence" ]
    in
    Html.div []
        [ Html.input [ Event.onInput ChangeChordList, Attr.value model.chords ] []
        , Html.br [] []
        , Html.input [ Event.onInput ChangeDefaultVariations, Attr.value model.variations ] []
        , Html.div
            [ Attr.style "display" "flex"
            , Attr.style "flexDirection" "row"
            , Attr.style "flexWrap" "wrap"
            ]
            content
        ]


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

        ChangeChordList str ->
            { model | chords = str }

        ChangeDefaultVariations str ->
            { model | variations = str }
