{-
  webviewhs
  (C) 2018 David Lettier
  lettier.com
-}

{-# LANGUAGE
    OverloadedStrings
  , QuasiQuotes
#-}

import System.Random
import Data.Text
import Control.Concurrent.MVar
import Language.Javascript.JMacro
import qualified Graphics.UI.Webviewhs as WHS

main :: IO ()
main = do
  counter <- newMVar (0 :: Int)
  WHS.withWindowLoop
    WHS.WindowParams
      { WHS.windowParamsTitle      = "webviewhs - How do I run my own function in the window loop?"
        -- This could be a localhost URL to your single-page application (SPA).
      , WHS.windowParamsUri        = "https://lettier.github.com"
      , WHS.windowParamsWidth      = 800
      , WHS.windowParamsHeight     = 600
      , WHS.windowParamsResizable  = True
      , WHS.windowParamsDebuggable = True
      }
    -- This is the callback JavaScript can execute.
    (\ _window text -> do
         print text
         WHS.runJavaScript _window [jmacro| setDocumentText("This came from  external.invoke callback.")|]
         return ()
     )
    -- This function runs before the loop.
    (WHS.WithWindowLoopSetUp    (\ _window -> print ("Setting up." :: Data.Text.Text)))
    -- This function runs after the loop.
    (WHS.WithWindowLoopTearDown (\ _window -> print ("Tearing down." :: Data.Text.Text)))
    -- This function runs every window loop.
    -- Return True to continue the loop or False to exit the loop.
    $ \ window -> do
      counter' <- takeMVar counter
      -- Every so often, change the web page background color to a random color.
      if counter' >= 100000
        then do
          putMVar counter 0
          red   <- randomRIO (0 :: Int, 255)
          green <- randomRIO (0 :: Int, 255)
          blue  <- randomRIO (0 :: Int, 255)
          WHS.runJavaScript
            window
            [jmacro|
              fun setDocumentText x {
                 document.body.innerHTML = x;
              }
              fun setBackgroundColor r g b {
                var color = "rgba(" + r + ", " + g + ", " + b + ", 1)";
                document.body.style.backgroundColor = color;
              };
              setTimeout(
                \ -> setBackgroundColor `(red)` `(green)` `(blue)`,
                1000
              );
            |]
        else do
          putMVar counter $ counter' + 1
          return True
