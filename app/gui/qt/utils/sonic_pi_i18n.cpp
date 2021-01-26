#include <QDir>
#include <QString>
#include <QStringList>
#include <QLocale>
#include <QLanguage>
#include <QTranslator>
#include <QMainWindow>
#include <QApplication>
#include <QLibraryInfo>

#include <iostream>

#include "sonic_pi_i18n.h"
#include "lang_list.h"

SonicPii18n::SonicPii18n(QString rootpath) {
  this->root_path = rootpath;
  this->available_languages = findAvailableLanguages();
}

QString SonicPii18n::determineUILanguage(QString lang_pref) {
  QStringList available_languages = getAvailableLanguages();
  std::cout << available_languages.join("\n").toUtf8().constData() << '\n';
  QLocale locale;

  if (lang_pref != "system_locale") {
    if (available_languages.contains(lang_pref)) {
        return lang_pref;
    }

    // Add the general language as a fallback (e.g. pt_BR -> pt)
    QString general_name = lang_pref;
    general_name.truncate(lang_pref.lastIndexOf('_'));
    general_name.truncate(general_name.lastIndexOf('-'));

    if (available_languages.contains(general_name)) {
        return lang_pref;
    }
  } else {
    QStringList preferred_languages = locale.uiLanguages();
    // If the specified language isn't available, or if the setting is set to system_locale...
      // ...run through the list of preferred languages
    std::cout << "Looping through preferred ui languages" << std::endl;

    for (int i = 0; i < preferred_languages.length(); i += 1) {
      if (available_languages.contains(preferred_languages[i])) {
          return lang_pref;
      }
    }
  }

  // Fallback to English
  return "en";
}

QStringList SonicPii18n::findAvailableLanguages() {
  QStringList languages;
  QLocale locale;

  QString m_langPath = root_path + "/app/gui/qt/lang";
  std::cout << m_langPath.toUtf8().constData() << "\n";
  QDir dir(m_langPath);
  QStringList fileNames = dir.entryList(QStringList("sonic-pi_*.qm"));

  for (int i = 0; i < fileNames.size(); ++i) {
    // get locale extracted by filename
    QString locale;
    locale = fileNames[i]; // "TranslationExample_de.qm"
    locale.truncate(locale.lastIndexOf('.')); // "TranslationExample_de"
    locale.remove(0, locale.lastIndexOf("sonic-pi_") + 9); // "de"
    std::cout << locale.toUtf8().constData() << '\n';
    languages << locale;
  }
  return languages;
}

bool SonicPii18n::loadTranslations(QString lang) {
  QString language = lang;
  bool i18n = false;
  QCoreApplication* app = QCoreApplication::instance();

  // Remove any previous translations
  app->removeTranslator(&translator);
  app->removeTranslator(&qtTranslator);

  std::cout << "Loading translations for " << language.toUtf8().constData() << std::endl;

  i18n = translator.load("sonic-pi_" + language, ":/lang/") || language == "en_GB" || language == "en" || language == "C";
  if (!i18n) {
    std::cout << language.toUtf8().constData() << ": Language translation not available" << std::endl;
    language = "en";
  }
  app->installTranslator(&translator);

  qtTranslator.load("qt_" + language, QLibraryInfo::location(QLibraryInfo::TranslationsPath));
  app->installTranslator(&qtTranslator);

  return i18n;
}

QStringList SonicPii18n::getAvailableLanguages() {
  return self->available_languages;
}

static std::map<QString, QString> SonicPii18n::getLanguageNameList() {
  return self->native_language_names;
}

static QString SonicPii18n::getNativeLanguageName(QString lang) {
  if (native_language_names.contains(lang))
    return self->native_language_names[lang];
  else if (lang == "system_locale") {
    return tr("System language")
  } else {
    // Try using QLocale to find the native language name
    QLocale locale(lang);
    if (locale.language != QLanguage::C) {
      return locale.nativeLanguageName();
    } else {
      std::cout << "Warning: Invalid language code '" << lang.toUtf8().constData() << "'" << std:endl;
      return lang;
    }
  }
}
