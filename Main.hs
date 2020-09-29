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
  Gtk.setWindowResizable window False
  Gtk.setWindowDefaultWidth window 300
  vbox <- Gtk.boxNew Gtk.OrientationVertical 10
  Gtk.setWidgetMargin vbox 10
  Gtk.containerAdd window vbox
  Gtk.widgetShow vbox
  _entryC <- addEntry (Text.pack "°C") vbox
  _entryF <- addEntry (Text.pack "°F") vbox
  Gtk.widgetShow window

addEntry :: Gtk.IsContainer a => Text -> a -> IO Gtk.Entry
addEntry labelStr container = do
  hbox <- Gtk.boxNew Gtk.OrientationHorizontal 5
  entry <- Gtk.entryNew
  label <- Gtk.labelNew (Just labelStr)
  Gtk.containerAdd hbox entry
  Gtk.containerAdd hbox label
  Gtk.containerAdd container hbox
  Gtk.widgetShow entry
  Gtk.widgetShow label
  Gtk.widgetShow hbox
  return entry
