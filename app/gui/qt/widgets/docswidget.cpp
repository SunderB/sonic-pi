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

#include <iostream>

// Qt stuff
#include <QDesktopWidget>
#include <QDesktopServices>
#include <QAction>
#include <QApplication>
#include <QFileDialog>
#include <QMenu>
#include <QMenuBar>
#include <QMessageBox>
#include <QDockWidget>
#include <QStatusBar>
#include <QTextBrowser>
#include <QToolBar>
#include <QShortcut>
#include <QToolButton>
#include <QScrollBar>
#include <QSplitter>
#include <QListWidget>
#include <QSplashScreen>
#include <QBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QStyle>

#include "docswidget.h"

#include "../utils/ruby_help.h"
#include "../utils/borderlesslinksproxystyle.h"

DocsWidget::DocsWidget(MainWindow *parent) {
  mainWindow = parent;

  docsCentral = new QTabWidget;
  docsCentral->setFocusPolicy(Qt::NoFocus);
  docsCentral->setTabsClosable(false);
  docsCentral->setMovable(false);
  docsCentral->setTabPosition(QTabWidget::South);
  QShortcut *left = new QShortcut(Qt::Key_Left, docsCentral);
  left->setContext(Qt::WidgetWithChildrenShortcut);
  connect(left, SIGNAL(activated()), mainWindow, SLOT(docPrevTab()));
  QShortcut *right = new QShortcut(Qt::Key_Right, docsCentral);
  right->setContext(Qt::WidgetWithChildrenShortcut);
  connect(right, SIGNAL(activated()), mainWindow, SLOT(docNextTab()));

  docsCentral->setStyleSheet("");

  docPane = new QTextBrowser;
  QSizePolicy policy = docPane->sizePolicy();
  policy.setHorizontalStretch(QSizePolicy::Maximum);
  docPane->setSizePolicy(policy);
  docPane->setMinimumHeight(100);
  docPane->setOpenLinks(false);
  docPane->setOpenExternalLinks(true);
  docPane->setStyle(new BorderlessLinksProxyStyle);
  connect(docPane, SIGNAL(anchorClicked(const QUrl &)), mainWindow, SLOT(docLinkClicked(const QUrl &)));

  QShortcut *up = new QShortcut(mainWindow->ctrlKey('p'), docPane);
  up->setContext(Qt::WidgetShortcut);
  connect(up, SIGNAL(activated()), this, SLOT(docScrollUp()));
  QShortcut *down = new QShortcut(mainWindow->ctrlKey('n'), docPane);
  down->setContext(Qt::WidgetShortcut);
  connect(down, SIGNAL(activated()), this, SLOT(docScrollDown()));

  docPane->setSource(QUrl("qrc:///html/doc.html"));

  mainWindow->addUniversalCopyShortcuts(docPane);

  this->addWidget(docsCentral);
  this->addWidget(docPane);
}

DocsWidget::~DocsWidget() {

}


void DocsWidget::createDocTabs(QString lang) {
  // Delete all existing tabs if there are any
  size_t length = docsCentral->count();
  std::cout << "[GUI] - number of tabs: " << length << std::endl;
  if (length != 0) {
    for (int i = length - 1; i >= 0; i--) {
      std::cout << "[GUI] - removing doc tab " << i << std::endl;
      QWidget* tab = docsCentral->widget(i);
      docsCentral->removeTab(i);
      delete docsCentral->widget(i);
      delete tab;
    }
  }

  size_t helplists_length = helpLists.size();
  std::cout << "[GUI] - number of tabs: " << length << std::endl;
  if (length != 0) {
    for (int i = helplists_length - 1; i >= 0; i--) {
      if (helpLists[i] != nullptr) {
        QListWidget* temp = helpLists[i];
        delete temp;
      }
    }
  }

  // Create new tabs
  std::cout << "[GUI] - initialising documentation window" << std::endl;
  initDocsWindow(lang);
  std::cout << "[GUI] - new no. of tabs: " << docsCentral->count() << std::endl;

  //docsCentral->setCurrentIndex(0);
  //helpLists[0]->setCurrentRow(0);

}


void DocsWidget::addHelpPage(QListWidget *nameList, struct help_page *helpPages, int len) {
    int i;
    struct help_entry entry;
    entry.pageIndex = docsCentral->count()-1;

    for(i = 0; i < len; i++) {
        QListWidgetItem *item = new QListWidgetItem(helpPages[i].title);
        item->setData(32, QVariant(helpPages[i].url));
        nameList->addItem(item);
        entry.entryIndex = nameList->count()-1;

        if (helpPages[i].keyword != NULL) {
            helpKeywords.insert(helpPages[i].keyword, entry);
            // magic numbers ahoy
            // to be revamped along with the help system
            switch (entry.pageIndex) {
                case 2:
                    mainWindow->autocomplete->addSymbol(SonicPiAPIs::Synth, helpPages[i].keyword);
                    break;
                case 3:
                    mainWindow->autocomplete->addSymbol(SonicPiAPIs::FX, helpPages[i].keyword);
                    break;
                case 5:
                    mainWindow->autocomplete->addKeyword(SonicPiAPIs::Func, helpPages[i].keyword);
                    break;
            }
        }
    }
}

QListWidget *DocsWidget::createHelpTab(QString name) {
    QListWidget *nameList = new QListWidget;
    connect(nameList,
            SIGNAL(itemPressed(QListWidgetItem*)),
            this, SLOT(updateDocPane(QListWidgetItem*)));
    connect(nameList,
            SIGNAL(currentItemChanged(QListWidgetItem*, QListWidgetItem*)),
            this, SLOT(updateDocPane2(QListWidgetItem*, QListWidgetItem*)));

    QShortcut *up = new QShortcut(mainWindow->ctrlKey('p'), nameList);
    up->setContext(Qt::WidgetShortcut);
    connect(up, SIGNAL(activated()), this, SLOT(helpScrollUp()));
    QShortcut *down = new QShortcut(mainWindow->ctrlKey('n'), nameList);
    down->setContext(Qt::WidgetShortcut);
    connect(down, SIGNAL(activated()), this, SLOT(helpScrollDown()));

    QBoxLayout *layout = new QBoxLayout(QBoxLayout::LeftToRight);
    layout->addWidget(nameList);
    layout->setStretch(1, 1);
    QWidget *tabWidget = new QWidget;
    tabWidget->setLayout(layout);
    docsCentral->addTab(tabWidget, name);
    helpLists.append(nameList);
    return nameList;
}

void DocsWidget::helpScrollUp() {
    int section = docsCentral->currentIndex();
    int entry = helpLists[section]->currentRow();

    if (entry > 0)
        entry--;
    helpLists[section]->setCurrentRow(entry);
}

void DocsWidget::helpScrollDown() {
    int section = docsCentral->currentIndex();
    int entry = helpLists[section]->currentRow();

    if (entry < helpLists[section]->count()-1)
        entry++;
    helpLists[section]->setCurrentRow(entry);
}

void DocsWidget::docPrevTab() {
    int section = docsCentral->currentIndex();
    if (section > 0)
        docsCentral->setCurrentIndex(section - 1);
}

void DocsWidget::docNextTab() {
    int section = docsCentral->currentIndex();
    if (section < docsCentral->count() - 1)
        docsCentral->setCurrentIndex(section + 1);
}

void DocsWidget::docScrollUp() {
    docPane->verticalScrollBar()->triggerAction(QAbstractSlider::SliderSingleStepSub);
}

void DocsWidget::docScrollDown() {
    docPane->verticalScrollBar()->triggerAction(QAbstractSlider::SliderSingleStepAdd);
}

void DocsWidget::focusHelpListing() {
  docsCentral->showNormal();
  docsCentral->currentWidget()->setFocus();
  docsCentral->raise();
  docsCentral->setVisible(true);
  docsCentral->activateWindow();
}

void DocsWidget::focusHelpDetails() {
  docPane->showNormal();
  docPane->setFocusPolicy(Qt::StrongFocus);
  docPane->setFocus();
  docPane->raise();
  docPane->setVisible(true);
  docPane->activateWindow();
}


// void DocsWidget::closeEvent(QCloseEvent *event){
//  emit closed();
//  event->accept();
// }
