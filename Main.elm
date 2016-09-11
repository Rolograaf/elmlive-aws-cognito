module Main exposing (..)

import Cognito
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App


type alias Model =
    { signupForm :
        { username : String
        , email : String
        , password : String
        }
    }


initialModel =
    { signupForm =
        { username = "demo2"
        , email = "'rolograaf+elmlive+demo2@gmail.com"
        , password = "password"
        }
    }


type Msg
    = DoSignUp


update msg model =
    case Debug.log "update" msg of
        DoSignUp ->
            ( model, Cognito.signup model.signupForm )


view model =
    -- TODO make this a form instead of a div
    -- then the attribite of the form onSubmit DoSignUp
    -- and make the Button a Submit
    Html.div []
        [ input
            [ placeholder "Email Address"
            , defaultValue model.signupForm.email
            ]
            []
        , input
            [ placeholder "Username"
            , defaultValue model.signupForm.username
            ]
            []
        , input
            [ placeholder "Password"
            , defaultValue model.signupForm.password
            , type' "password"
            ]
            []
        , button [ onClick DoSignUp ] [ text "Sign Up" ]
        ]


main =
    Html.App.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = \model -> Sub.none
        , view = view
        }
