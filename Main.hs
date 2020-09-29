{-# LANGUAGE MonoLocalBinds #-}

import Data.Text (Text)
import qualified Data.Text as Text

import qualified GI.Gtk as Gtk
import qualified GI.Gio as Gio

main :: IO ()
main = do
  Just app <- Gtk.applicationNew (Just appId) []
  _ <- Gio.onApplicationActivate app (appActivate app)
  _ <- Gio.applicationRun app Nothing
  return ()

appId :: Text
appId = Text.pack "io.serokell.gui-haskell-app"

appActivate :: Gtk.Application -> IO ()
appActivate app = do
  window <- Gtk.applicationWindowNew app
  Gtk.setWindowTitle window (Text.pack "GUI Haskell App")
  vbox <- Gtk.boxNew Gtk.OrientationVertical 10
  Gtk.setWidgetMargin vbox 10
  Gtk.containerAdd window vbox
  Gtk.widgetShow vbox
  _entryC <- addEntry vbox
  _entryF <- addEntry vbox
  Gtk.widgetShow window

addEntry :: Gtk.IsContainer a => a -> IO Gtk.Entry
addEntry container = do
  entry <- Gtk.entryNew
  Gtk.containerAdd container entry
  Gtk.widgetShow entry
  return entry
