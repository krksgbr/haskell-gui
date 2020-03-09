{-# LANGUAGE BangPatterns        #-}
{-# LANGUAGE OverloadedStrings   #-}

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
import qualified Data.Text as T
import qualified Graphics.UI.TinyFileDialogs as Dialogs
import Data.Time.Clock
import Data.Maybe



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


chooseFiles :: IO (Maybe [T.Text])
chooseFiles =
  Dialogs.openFileDialog "Choose a fucking file" "" [] "" True


update :: Action -> Model -> Effect Action Model
update NoOp    m = noEff m

update LoadImg m = m <# do
        liftIO $ do
          imgs <- chooseFiles
          case imgs of
            Just im -> do
              -- result <- ImgLoaded . ms <$> Img.loadImage (T.unpack $ head im)
              let result = ImgLoaded $ ms (head im)
              pure result
            Nothing ->
              pure NoOp

update (ImgLoaded    im) m = noEff $ m { image = Just im }
update (FilesDropped fs) m = noEff m

view :: Model -> View Action
view m = marioImage
    where
        h          = (10 :: Double)
        w          = (10 :: Double)
        marioImage = div_
                [height_ (ms h), width_ (ms w)]
                [img_[src_ $ fromMaybe "file://st2" (image m)]
                , div_ [] [button_ [onClick LoadImg] [text "Choose Image"]]
                -- , fileDrop FilesDropped
                , fileInput
                ]

mkStyles :: Model -> M.Map MisoString MisoString
mkStyles Model { image = Just image } = M.fromList
        [ ("display"         , "block")
        , ("width"           , "300px")
        , ("height"          , "100%")
        , ("background-color", "transparent")
        , ( "background-image"
          , "url(" <> (Debug.log "image" image) <> ")"
          )
        , ("background-repeat", "no-repeat")
        ]

mkStyles Model { image = Nothing } = M.fromList []


fileInput =
  input_ [ type_ "file"
         , id_ "fr"
         , boolProp "webkitdirectory" True
         , style_ $ M.fromList
                [ ("width"          , "500px")
                , ("height"         , "500px")
                , ("background"     , "red")
                , ("color"          , "white")
                , ("display"        , "flex")
                , ("align-items"    , "center")
                , ("justify-content", "center")
                , ("cursor"         , "pointer")
                ]
         ]


  -- https://github.com/react-dropzone/react-dropzone/issues/459
  -- https://github.com/mtolly/tinyfiledialogs
  -- http://hackage.haskell.org/package/wxcore
  -- patch source of webkit to allow full path on files
  -- https://github.com/WebKit/webkit/blob/89c28d471fae35f1788a0f857067896a10af8974/Source/WebCore/Modules/entriesapi/HTMLInputElementEntriesAPI.cpp
  -- https://github.com/WebKit/webkit/blob/6d2932b133968294beb5c49c6d5dea4696b8a2c5/Source/WebCore/html/HTMLInputElement.cpp
  -- especially this https://github.com/WebKit/webkit/blob/e70478bcfeabf1b18ed0664f24343e14a16ea476/Source/WebCore/dom/DataTransfer.cpp
  -- save images to project directory: give access by opening the file
  -- or just use electron
  -- https://codetalk.io/posts/2016-05-11-using-electron-with-haskell.html
  -- https://lettier.github.io/posts/2016-08-15-making-movie-monad.html
  -- https://github.com/lettier/webviewhs
  -- use fltk
