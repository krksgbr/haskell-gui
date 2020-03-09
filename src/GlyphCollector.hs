{-# LANGUAGE BangPatterns        #-}

module GlyphCollector
        ( init
        , update
        , view
        , Model(..)
        , initialAction
        )
where


import           Data.Bool
import           Data.Function
import qualified Data.Map                      as M
import           Data.Monoid

import           Miso                    hiding ( view
                                                , initialAction
                                                , update
                                                )
import           Miso.String                    ( MisoString
                                                , fromMisoString
                                                , ms
                                                )

import qualified Data.ByteString               as BS
import qualified Data.ByteString.Base64        as BS64
import qualified System.Directory              as System
import           Control.Monad.IO.Class
import           Prelude                 hiding ( init )
import qualified MassivLib                     as Img
import qualified Debug
import           Data.Aeson.Types



data Action =
   LoadImg
  | ImgLoaded MisoString
  | NoOp
  | FilesDropped [MisoString]
  deriving (Show)

data Model = Model
    { image :: Maybe MisoString
    } deriving (Show, Eq)

data Direction
  = L
  | R
  deriving (Show,Eq)

init :: Model
init = Model { image = Nothing }

initialAction = NoOp



update :: Action -> Model -> Effect Action Model
update NoOp    m = noEff m

update LoadImg m = m <# do
        liftIO $ ImgLoaded . ms <$> Img.readMario

update (ImgLoaded    im) m = noEff $ m { image = Just im }
update (FilesDropped fs) m = noEff m

view :: Model -> View Action
view m = marioImage
    where
        h          = (10 :: Double)
        w          = (10 :: Double)
        marioImage = div_
                [height_ (ms h), width_ (ms w)]
                [ nodeHtml
                        "style"
                        []
                        [ "@keyframes play { 100% { background-position: -296px; } }"
                        ]
                , div_ [style_ (mkStyles m)] []
                , div_ [] [button_ [onClick LoadImg] [text "Save"]]
                , fileDrop FilesDropped
                ]

mkStyles :: Model -> M.Map MisoString MisoString
mkStyles Model { image = Just image } = M.fromList
        [ ("display"         , "block")
        , ("width"           , "37px")
        , ("height"          , "37px")
        , ("background-color", "transparent")
        , ( "background-image"
          , "url(data:image/png;base64," <> ms (Debug.log "image:" image) <> ")"
          )
        , ("background-repeat", "no-repeat")
        ]

mkStyles Model { image = Nothing } = M.fromList []

myDecoder :: Decoder [MisoString]
myDecoder = Decoder
        { decodeAt = DecodeTarget ["dataTransfer"]
        , decoder  = \v ->
            let
              !printed = Debug.log "value" v
            in
            (withObject "foobar200" $ \o -> Debug.log "object" o .: "files") v
        }

disabledEvent x = onWithOptions
        (Miso.defaultOptions { preventDefault = True, stopPropagation = True })
        x
        emptyDecoder
        (\() -> NoOp)

fileDrop action = div_
        [ style_ $ M.fromList
                [ ("width"          , "500px")
                , ("height"         , "500px")
                , ("background"     , "blue")
                , ("color"          , "white")
                , ("display"        , "flex")
                , ("align-items"    , "center")
                , ("justify-content", "center")
                , ("cursor"         , "pointer")
                ]
        , onWithOptions
                (Miso.defaultOptions { preventDefault  = True
                                     , stopPropagation = True
                                     }
                )
                "drop"
                myDecoder
                (\result ->
                   let
                     !x = Debug.log "result" result
                   in
                     action []
                )
        , disabledEvent "drag"
        , disabledEvent "dragstart"
        , disabledEvent "dragend"
        , disabledEvent "dragover"
        , disabledEvent "dragenter"
        , disabledEvent "dragleave"
        , id_ "dropzone"
        ]
        [text "Drop it like it's hot"]
