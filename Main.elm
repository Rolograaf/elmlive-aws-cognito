module Main exposing (..)

import Cognito
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.App


type alias Model =
    { signupFlow : FormState
    }


type FormState
    = SignupForm
        { username : String
        , email : String
        , password : String
        , isSubmitting : Bool
        , error : Maybe String
        }
    | ConfirmationCodeForm
        { username : String
        , code : String
        , isSubmitting : Bool
        , error : Maybe String
        }
    | DoneWithEverything


initialModel : Model
initialModel =
    { signupFlow =
        -- SignupForm
        --     { username = "demo4"
        --     , email = "'rolograaf+elmlive+demo4@gmail.com"
        --     , password = "password"
        --     , isSubmitting = False
        --     , error = Nothing
        --     }
        ConfirmationCodeForm
            { username = "demo4"
            , code = ""
            , isSubmitting = False
            , error = Nothing
            }
    }


type Msg
    = DoSignUp
    | DoConfirmUser
    | CodeChanged String
    | CognitoError String
    | CognitoSignupSuccess { username : String }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.signupFlow ) of
        ( DoSignUp, SignupForm form ) ->
            ( model
            , Cognito.signup
                { username = form.username
                , password = form.password
                , email = form.email
                }
            )

        ( CognitoError error, SignupForm form ) ->
            ( { model
                | signupFlow =
                    SignupForm { form | error = Just error }
              }
            , Cmd.none
            )

        ( CognitoSignupSuccess data, SignupForm form ) ->
            ( { model
                | signupFlow =
                    ConfirmationCodeForm
                        { username = data.username
                        , code = ""
                        , isSubmitting = False
                        , error = Nothing
                        }
              }
            , Cmd.none
            )

        ( CodeChanged newCode, ConfirmationCodeForm form ) ->
            ( { model
                | signupFlow =
                    ConfirmationCodeForm
                        { form
                            | code = newCode
                        }
              }
            , Cmd.none
            )

        ( DoConfirmUser, ConfirmationCodeForm form ) ->
            ( { model
                | signupFlow =
                    ConfirmationCodeForm
                        { form
                            | isSubmitting = True
                        }
              }
            , Cognito.confirmUser
                { username = form.username
                , code = form.code
                }
            )

        _ ->
            Debug.crash "TODO"


view : Model -> Html Msg
view model =
    case model.signupFlow of
        SignupForm form ->
            Html.div []
                [ input
                    [ placeholder "Email Address"
                    , defaultValue form.email
                    ]
                    []
                , input
                    [ placeholder "Username"
                    , defaultValue form.username
                    ]
                    []
                , input
                    [ placeholder "Password"
                    , defaultValue form.password
                    , type' "password"
                    ]
                    []
                , case form.error of
                    Nothing ->
                        text ""

                    Just message ->
                        p [] [ text <| "Error: " ++ message ]
                , button
                    [ onClick DoSignUp
                    ]
                    [ text "Sign Up" ]
                ]

        ConfirmationCodeForm form ->
            Html.div []
                [ p []
                    [ text <| "Please enter the confirmation code for " ++ form.username ]
                , input
                    [ placeholder "Confirmation code"
                    , defaultValue form.code
                    , onInput CodeChanged
                    ]
                    []
                , case form.error of
                    Nothing ->
                        text ""

                    Just message ->
                        p [] [ text <| "Error: " ++ message ]
                , button
                    [ onClick DoConfirmUser
                    ]
                    [ text "Confirm Registration" ]
                ]

        DoneWithEverything ->
            text "TODO: Thanks for signing up!"


main : Program Never
main =
    Html.App.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions =
            \model ->
                Sub.batch
                    [ Cognito.signupSuccess CognitoSignupSuccess
                    , Cognito.errors CognitoError
                    ]
        , view = view
        }
