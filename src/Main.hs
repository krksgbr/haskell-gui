{-# LANGUAGE MultiWayIf        #-}
{-# LANGUAGE BangPatterns      #-}

module Main where

import qualified GlyphCollector as GC
import qualified MassivLib as  Img
import qualified Language.Javascript.JSaddle.WebKitGTK as JSaddle
import Miso


main :: IO ()
main = do
  JSaddle.run $ do
    time <- now
    let m = GC.init
    startApp App { model = m
                 , initialAction = GC.initialAction
                 , view = GC.view
                 , events = defaultEvents
                 , subs = []
                 , mountPoint = Nothing
                 , update = GC.update
                 }
