//--
// This file is part of Sonic Pi: http://sonic-pi.net
// Full project source: https://github.com/samaaron/sonic-pi
// License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
//
// Copyright 2013, 2014, 2015, 2016 by Sam Aaron (http://sam.aaron.name).
// All rights reserved.
//
// Permission is granted for use, copying, modification, and
// distribution of modified versions of this work as long as this
// notice is included.
//++

#include <iostream>

#include <QApplication>
#include <QSplashScreen>
#include <QPixmap>
#include <QBitmap>
#include <QLabel>
#include <QTranslator>
#include <QSettings>
#include <QLibraryInfo>

#include "mainwindow.h"

#include "widgets/sonicpilog.h"

#include "dpi.h"

#ifdef _WIN32
#include <QtPlatformHeaders\QWindowsWindowFunctions>
#endif

#ifdef Q_OS_MAC
    #include "platform/macos.h"
#endif

int main(int argc, char *argv[])
{

#ifndef Q_OS_MAC
  Q_INIT_RESOURCE(SonicPi);
#endif

  QApplication app(argc, argv);

  QApplication::setAttribute(Qt::AA_DontShowIconsInMenus, true);

  QFontDatabase::addApplicationFont(":/fonts/Hack-Regular.ttf");
  QFontDatabase::addApplicationFont(":/fonts/Hack-Italic.ttf");

  qRegisterMetaType<SonicPiLog::MultiMessage>("SonicPiLog::MultiMessage");

  // language/translations ----------
  //QString selected_language = "";

  QLocale locale;
  QStringList preferred_languages = locale.system().uiLanguages()
  //QString systemLocale = QLocale::system().name();

  QTranslator qtTranslator;
  QTranslator translator;

  bool i18n = false;

  // Get the specified language from the settings
  QSettings settings(QSettings::IniFormat, QSettings::UserScope, "sonic-pi.net", "gui-settings");
  QString language = settings.value("prefs/language").toString();

  std::cout << "[Debug] Settings file name:" << std::endl;
  std::cout << (settings.fileName().toUtf8().constData()) << std::endl;
  std::cout << "Language setting: " << std::endl;
  std::cout << (language.toUtf8().constData()) << std::endl;



  // If a language is specified...
  if (language != "system_locale") {
    // ...try using the specified language
    i18n = translator.load("sonic-pi_" + language, ":/lang/") || language.startsWith("en") || language == "C";
  }

  // If the specified language isn't available, or if the setting is set to system_locale...
  if (!i18n || language == "system_locale") {
    // ...run through the list of preferred languages
    std::cout << "Looping through preferred ui languages" << std::endl;

    for (int i = 0; i < preferred_languages.length(); i += 1) {
      i18n = translator.load("sonic-pi_" + preferred_languages[i].replace("-", "_"), ":/lang/") || preferred_languages[i].startsWith("en") || preferred_languages[i] == "C";
      if (i18n) {
        std::cout << preferred_languages[i].replace("-", "_").toUtf8().constData() << ": Found language translation" << std::endl;
        language = preferred_languages[i].replace("-", "_");
        break;
      } else {
        std::cout << preferred_languages[i].replace("-", "_").toUtf8().constData() << ": Language translation not available" << std::endl;
      }
    }
  }

  // Fallback to english
  if (!i18n) {
    std::cout << "No preferred language translation found, falling back to English" << std::endl;
    language = "en";
  }

  std::cout << "Using language: " << language.toUtf8().constData() << std::endl;

  app.installTranslator(&translator);

  qtTranslator.load("qt_" + language, QLibraryInfo::location(QLibraryInfo::TranslationsPath));
  app.installTranslator(&qtTranslator);
  // ----------

  app.setApplicationName(QObject::tr("Sonic Pi"));
  app.setStyle("gtk");


#ifdef __linux__
  //linux code goes here

  QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QPixmap pixmap(":/images/splash@2x.png");

  QSplashScreen *splash = new QSplashScreen(pixmap);
  splash->setMask(pixmap.mask());
  splash->show();
  splash->repaint();
  app.processEvents();
  MainWindow mainWin(app, language, i18n, splash);

  return app.exec();
#elif _WIN32
  // windows code goes here

  // A temporary fix, until stylesheets are removed.
  // Only do the dpi scaling when the platform is high dpi

  if (GetDisplayScale().width() > 1.1f)
    {
      QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
      QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    }

  QPixmap pixmap;
  QSplashScreen *splash;

  if (GetDisplayScale().width() > 1.8f)
    {
      QPixmap pixmap(":/images/splash2x.png");
      splash = new QSplashScreen(pixmap);
    } else
    {
      QPixmap pixmap(":/images/splash.png");
      splash = new QSplashScreen(pixmap);
    }


  splash->setMask(pixmap.mask());
  splash->show();
  splash->repaint();
  app.processEvents();
  MainWindow mainWin(app, language, i18n, splash);

  // Fix for full screen mode. See: https://doc.qt.io/qt-5/windows-issues.html#fullscreen-opengl-based-windows
  QWindowsWindowFunctions::setHasBorderInFullScreen(mainWin.windowHandle(), true);

  return app.exec();

#elif __APPLE__
  // macOS code goes here

  SonicPi::removeMacosSpecificMenuItems();

  QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

  QMainWindow* splashWindow = new QMainWindow(0, Qt::FramelessWindowHint);
  QLabel* imageLabel = new QLabel();
  splashWindow->setAttribute( Qt::WA_TranslucentBackground);
  QPixmap image(":/images/splash@2x.png");
  imageLabel->setPixmap(image);

  splashWindow->setCentralWidget(imageLabel);
  splashWindow->setMinimumHeight(image.height()/2);
  splashWindow->setMaximumHeight(image.height()/2);
  splashWindow->setMinimumWidth(image.width()/2);
  splashWindow->setMaximumWidth(image.width()/2);

  splashWindow->raise();
  splashWindow->show();
  app.processEvents();

  MainWindow mainWin(app, language, i18n, splashWindow);
  return app.exec();

#endif

}
