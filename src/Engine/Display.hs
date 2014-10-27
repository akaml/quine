{-# LANGUAGE DeriveDataTypeable, TemplateHaskell #-}
module Engine.Display 
  ( Display(..)
  , HasDisplay(..)
  , warn
  ) where

import Control.Monad.IO.Class
import Control.Monad.State
import Control.Lens
import Data.Typeable
import Engine.GL.Cache
import Engine.SDL.Exception
import Foreign.C
import Graphics.UI.SDL
import Graphics.UI.SDL.Enum.Pattern
import Graphics.Rendering.OpenGL.GL.CoordTrans
import System.IO

-- basic opengl + sdl display for the screen, etc.

data Display = Display 
  { _displayWindow            :: !Window
  , _displayGL                :: !GLContext
  , _displayCaches            :: !Caches
  , _displayFullScreen        :: !Bool
  , _displayWindowSize        :: !Size
  , _displayWindowSizeChanged :: !Bool -- whenever this changes pretty much everything is borked.
  , _displayMinimized         :: !Bool
  , _displayHasMouseFocus     :: !Bool
  , _displayHasKeyboardFocus  :: !Bool
  , _displayVisible           :: !Bool
  } deriving Typeable

makeClassy ''Display

instance HasCaches Display where
  caches = displayCaches

-- | complain loudly enough to pop up a window
warn :: (MonadIO m, MonadState s m, HasDisplay s) => String -> String -> m ()
warn t m = do
  window <- use displayWindow
  liftIO $ do 
    hPutStrLn stderr $ "Warning: " ++ t ++ ": " ++ m
    withCString t $ \title -> withCString m $ \message ->
      showSimpleMessageBox MessageBoxFlagWarning title message window >>= err
