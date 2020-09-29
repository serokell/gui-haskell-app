{-# LANGUAGE MonoLocalBinds, TypeApplications #-}

import Data.Text (Text)
import qualified Data.Text as Text
import Data.Fixed (Centi)
import Control.Concurrent (threadDelay)
import System.Random (randomRIO)
import Text.Read (readMaybe)

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
  entryC <- addEntry (Text.pack "°C") vbox
  entryF <- addEntry (Text.pack "°F") vbox
  _ <- Gtk.onEditableChanged entryC $
    do s <- Gtk.entryGetText entryC
       Gtk.entrySetText entryF (Text.reverse s)
  button <- Gtk.buttonNew
  Gtk.setButtonLabel button (Text.pack "Get Weather")
  Gtk.setWidgetHalign button Gtk.AlignCenter
  Gtk.containerAdd vbox button
  Gtk.widgetShow button
  Gtk.widgetShow window

addEntry :: Gtk.IsContainer a => Text -> a -> IO Gtk.Entry
addEntry labelStr container = do
  hbox <- Gtk.boxNew Gtk.OrientationHorizontal 5
  entry <- Gtk.entryNew
  Gtk.setWidgetExpand entry True
  Gtk.setEntryXalign entry 1
  label <- Gtk.labelNew (Just labelStr)
  Gtk.containerAdd hbox entry
  Gtk.containerAdd hbox label
  Gtk.containerAdd container hbox
  Gtk.widgetShow entry
  Gtk.widgetShow label
  Gtk.widgetShow hbox
  return entry

c_to_f, f_to_c :: Double -> Double
c_to_f = (+32) . (*1.8)
f_to_c = (/1.8) . subtract 32

parseDouble :: Text -> Maybe Double
parseDouble = readMaybe . Text.unpack

renderDouble :: Double -> Text
renderDouble = Text.pack . show @Centi . realToFrac

getWeather :: IO Double
getWeather = do
  threadDelay (3 * 1000000)
  randomRIO (-30, 30)
