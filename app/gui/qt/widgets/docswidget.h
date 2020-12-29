//--
// This file is part of Sonic Pi: http://sonic-pi.net
// Full project source: https://github.com/samaaron/sonic-pi
// License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
//
// Copyright 2017 by Sam Aaron (http://sam.aaron.name).
// All rights reserved.
//
// Permission is granted for use, copying, modification, and
// distribution of modified versions of this work as long as this
// notice is included.
//++

#ifndef DOCSWIDGET_H
#define DOCSWIDGET_H

#include <QWidget>
#include <QSplitter>

#include "../mainwindow.h"

class QSlider;
class QTabWidget;
class QBoxLayout;
class QGroupBox;
class QComboBox;
class QCheckBox;
class QPushButton;
class QLabel;
class QLineEdit;
class QButtonGroup;
class QSignalMapper;
class QVBoxLayout;
class QTabWidget;
class QDockWidget;
class QSplitter;



struct help_page {
    QString title;
    QString keyword;
    QString url;
};

struct help_entry {
    int pageIndex;
    int entryIndex;
};

class DocsWidget : public QSplitter
{
    Q_OBJECT

public:
    DocsWidget(MainWindow *parent);
    ~DocsWidget();

    void createDocTabs(QString lang);
    void focusHelpListing();
    void focusHelpDetails();

    QTabWidget *docsCentral;
    QTextBrowser *docPane;

    QList<QListWidget *> helpLists;
    QHash<QString, help_entry> helpKeywords;

private slots:
  void helpScrollUp();
  void helpScrollDown();
  void docPrevTab();
  void docNextTab();
  void docScrollUp();
  void docScrollDown();

private:
  //   void initPrefsWindow();
  void initDocsWindow(QString language);
  void addTutorialDocsTab(QString lang);
  void addSynthDocsTab();
  void addFXDocsTab();
  void addSampleDocsTab();
  void addLangDocsTab();
  void addExamplesDocsTab();
  void addAutocompleteArgs();

  QListWidget *createHelpTab(QString name);
  void addHelpPage(QListWidget *nameList, struct help_page *helpPages, int len);

  MainWindow *mainWindow;
  //void closeEvent(QCloseEvent *event);
};

#endif
