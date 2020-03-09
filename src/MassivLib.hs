{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
module MassivLib
    ( someFunc
    , readMario
    )
where

import           Data.Massiv.Array             as A
import           Data.Massiv.Array.IO
import           Graphics.ColorSpace.YCbCr
import           Graphics.ColorSpace
import qualified Data.ByteString               as BS
import qualified Data.ByteString.Lazy          as BSL
import qualified Data.ByteString.Base64        as BS64

someFunc :: IO ()
someFunc = do
    img <- readImage "imgs/mario.png" :: IO (Image S RGBA Word8)
    putStrLn (show img)
    displayImage img


marioPath :: FilePath
marioPath = "/home/gbr/projects/glyphcollector/imgs/mario.png"


readMario :: IO BS.ByteString
readMario = do
    img <- readImage marioPath :: IO (Image S RGBA Word8)
    print "encoded"
    return $ BS64.encode $ BSL.toStrict $ encodeImage imageWriteAutoFormats
                                                      marioPath
                                                      img

  -- putStrLn $ show $ makeVectorR D Seq 10 id
  -- putStrLn "someFunc"

-- dropColumnMaybe ::
--   Ix1
--   -> Array D Ix2 a
--   -> Maybe (Array D Ix1 a, Array D Ix2 a, Array D Ix2 a)
-- dropColumnMaybe i arr = do
--   column <- arr <!? i
--   let Sz2 m n = size arr
--   left <- extractM (0 :. 0) (Sz2 m i) arr
--   right <- extractM (0 :. i + 1) (Sz2 m (n-i-1)) arr
--   pure (column, left, right)

-- dropColumnMaybe' ::
--      Ix1 -> Array D Ix2 a -> Maybe (Array D Ix1 a, Array DL Ix2 a)
-- dropColumnMaybe' i arr = do
--   column <- arr <!? i
--   let Sz2 m n = size arr
--   left <- extractM (0 :. 0) (Sz2 m i) arr
--   right <- extractM (0 :. i + 1) (Sz2 m (n-i-1)) arr
--   popped <- appendM 1 left right
--   pure (column, popped)

-- forceDropped (column, popped) =
--   (computeAs U (resize' (Sz (n :. 1)) column), computeAs U popped)
--   where n = unSz $ size column
