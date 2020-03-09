module Main where

main =
  putStrLn "oi"

-- {-# LANGUAGE OverloadedStrings #-}
-- {-# LANGUAGE RecordWildCards   #-}
-- {-# LANGUAGE MultiWayIf        #-}
-- {-# LANGUAGE BangPatterns      #-}
-- module Main where

-- import           Data.Bool
-- import           Data.Function
-- import qualified Data.Map as M
-- import           Data.Monoid

-- import           Miso
-- import           Miso.String

-- import qualified Language.Javascript.JSaddle.WebKitGTK as JSaddle
-- import qualified Data.ByteString as BS
-- import qualified Data.ByteString.Base64 as BS64
-- import qualified System.Directory as System
-- import qualified Debug.Trace as Debug
-- import Control.Monad.IO.Class
-- import Prelude hiding (init)

-- data Action =
--    NoOp
--   | SaveStr
--   | UpdateInput MisoString

-- loadImage = do
--   pwd <- System.getCurrentDirectory
--   bs <- BS.readFile (pwd ++ "/imgs/mario.png")
--   return $ BS64.encode bs



-- main :: IO ()
-- main = do
--   image <- loadImage
--   JSaddle.run $ do
--     time <- now
--     let m = initModel { image = image
--             }
--     startApp App { model = m
--                  , initialAction = NoOp
--                  , ..
--                  }
--   where
--     update = updateMario
--     view   = display
--     events = defaultEvents
--     subs   = []
--     mountPoint = Nothing


-- saveString =
--   writeFile "marioInput.txt"


-- data Model = Model
--     {image :: BS.ByteString
--     , inputValue :: MisoString
--     } deriving (Show, Eq)

-- data Direction
--   = L
--   | R
--   deriving (Show,Eq)

-- initModel :: Model
-- initModel = Model
--     { image = ""
--     , inputValue = ""
--     }

-- updateMario :: Action -> Model -> Effect Action Model
-- updateMario NoOp m = noEff m

-- updateMario (UpdateInput s) m = noEff newModel
--   where
--     newModel = m { inputValue = s }

-- updateMario (SaveStr) m = m <# do
--   liftIO
--     $ writeFile "marioInput.txt" (fromMisoString $ inputValue m) >> pure NoOp
--     >> pure NoOp


-- display :: Model -> View Action
-- display m@Model{..} = marioImage
--   where
--     h = (10 :: Double)
--     w = (10 :: Double)
--     marioImage =
--       div_ [ height_ (ms h)
--            , width_ (ms w)
--            ]
--            [ nodeHtml "style" [] ["@keyframes play { 100% { background-position: -296px; } }"]
--            , div_ [ style_ (mkStyles m 10) ] []
--            , div_ [][ textarea_ [
--                           value_ inputValue
--                           , rows_ "10"
--                           , onInput (\s -> Debug.trace (show s) (UpdateInput s) )
--                           , autofocus_ True
--                         ][]
--                     , button_ [onClick SaveStr
--                               ][text "Save"]
--                     ]
--            ]

-- mkStyles :: Model -> Double -> M.Map MisoString MisoString
-- mkStyles Model {..} gy =
--   M.fromList [("display", "block")
--              , ("width", "37px")
--              , ("height", "37px")
--              , ("background-color", "transparent")
--              , ("background-image", "url(data:image/png;base64," <> ms image <> ")" )
--              , ("background-repeat", "no-repeat")
--              ]

-- matrix :: Direction -> Double -> Double -> MisoString
-- matrix dir x y =
--   "matrix("
--      <> (if dir == L then "-1" else "1")
--      <> ",0,0,1,"
--      <> ms x
--      <> ","
--      <> ms y
--      <> ")"
