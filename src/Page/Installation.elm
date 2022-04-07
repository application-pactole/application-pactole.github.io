module Page.Installation exposing (view)

import Element as E
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Keyed as Keyed
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Settings as Settings
import Ui
import Ui.Color as Color


view : Model -> Model.InstallationData -> E.Element Msg
view model installation =
    Keyed.el [ E.width E.fill, E.height E.fill, E.scrollbarY ]
        ( "Installation"
        , E.column
            [ E.width E.fill
            , E.height E.fill
            , E.scrollbarY
            , Border.widthEach { left = 2, top = 0, bottom = 0, right = 0 }
            , Border.color Color.neutral90
            ]
            [ E.column
                [ E.width E.fill
                , E.height E.fill
                , E.paddingXY 24 24
                ]
                [ viewInstallation model installation
                ]
            ]
        )


viewInstallation : Model -> Model.InstallationData -> E.Element Msg
viewInstallation model installation =
    E.row
        [ E.width E.fill
        , E.height E.fill
        ]
        [ Ui.textColumn model.device
            [ titleBanner model
            , Ui.paragraph
                """
                Pactole est une application très simple de gestion de budget personnel. Elle est
                destinée aux personnes pour qui les applications traditionnelles sont trop
                complexes.
                """
            , Ui.paragraph
                """
                Elle vous permet de saisir des opérations bancaires, et les affiche sous forme
                de calendrier. 
                """
            , Ui.paragraph
                """
                Par défaut son interface est réduite à l'essentiel: saisie d'entrées 
                d'argent et de dépenses, affichage du solde actuel. 
                Des fonctionnalités optionnelles peuvent être activées dans les réglages: bilan du
                mois, pointage, catégories pour les dépenses, dépenses mensuelles récurrentes.
                """
            , Ui.verticalSpacer
            , Ui.title model.device "Installation"
            , Ui.paragraph
                """
                Pactole est une application qui fonctionne dans le navigateur. 
                Ce n'est pas un site web: la page reste accessible même sans connexion internet.
                """
            , Ui.paragraphParts
                [ Ui.boldText
                    """
                    Il est nécessaire d'ajouter cette page à vos favoris
                    """
                , Ui.text
                    """
                    (parfois appelés marque-pages ou signets),
                    afin que le navigateur sache que vous voulez conserver les données de l'application.
                    """
                ]
            , Ui.paragraph
                """
                Si vous utilisez Firefox, le navigateur vous demandera l'autorisation de "conserver les
                données dans le stockage persistant": donnez cette autorisation.
                """
            , Ui.paragraph
                """
                Si vous utilisez Chrome, Edge ou Safari, vous
                pouvez ajouter l'application à votre écran d'accueil pour un accès plus rapide.
                """
            , Ui.paragraph
                """
                Notez que vos données ne sont pas enregistrées en ligne:
                elles sont uniquement disponibles sur l'appareil que vous utilisez actuellement.
                """
            , E.row [ E.width E.fill, E.spacing 12 ]
                [ E.el
                    [ E.width (E.px 12)
                    , E.height E.fill
                    , Background.color Color.focus85
                    ]
                    E.none
                , Ui.paragraphParts
                    [ Ui.text "Important: "
                    , Ui.boldText
                        """il ne faut jamais utiliser la fonctionnalité de nettoyage des données
                    du navigateur."""
                    , Ui.text
                        """
                    Cela effacerait tout les opérations que vous avez entrées dans Pactole.
                    """
                    ]
                ]
            , Ui.verticalSpacer
            , Ui.title model.device "Configuration initiale"
            , Ui.textInput
                { width = 400
                , label = Ui.labelLeft "Nom du compte:"
                , text = installation.firstAccount
                , onChange = \txt -> Msg.ChangeInstallName txt |> Msg.ForInstallation
                }
            , Ui.moneyInput model.device
                { label = Ui.labelLeft "Solde initial:"
                , color = Color.neutral20
                , state = installation.initialBalance
                , onChange = Msg.ForInstallation << Msg.ChangeInstallBalance
                }
            , Ui.verticalSpacer
            , Settings.configLocked model
            , E.wrappedRow [ E.spacing 36 ]
                [ Ui.mainButton
                    { label = E.text "Installer Pactole"
                    , onPress = Just (Msg.ProceedWithInstall |> Msg.ForInstallation)
                    }
                , Ui.simpleButton
                    { label = E.text "Récupérer une sauvegarde"
                    , onPress = Just (Msg.ImportInstall |> Msg.ForInstallation)
                    }
                ]
            , Ui.verticalSpacer
            ]
        ]


titleBanner : Model -> E.Element Msg
titleBanner model =
    E.row
        [ E.width E.fill
        , Background.color Color.greenApajh90
        , Border.rounded 44
        , Font.color Color.greenApajh
        , E.padding 12
        , E.spacing 12
        ]
        [ E.image [ E.alignLeft, E.height <| E.maximum 64 <| E.shrink ]
            { src = "images/icon-512x512.png"
            , description = "Pactole Logo"
            }
        , E.el [ E.alignLeft, Ui.biggestFont model.device, Font.bold ] (E.text "Pactole")
        ]
