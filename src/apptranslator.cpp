#include <QDebug>
#include <QVariant>
#include <QCoreApplication>
#include <QFile>
#include <QDir>
#include <QMap>
#include <QLocale>

#include "apptranslator.h"

#ifndef Q_OS_SAILFISH
#include "qmlapplicationviewer.h"
#endif

AppTranslator::AppTranslator(QCoreApplication *app)
{
    m_app = app;
#if defined(Q_OS_SAILFISH)
    m_langdir = "/usr/share/harbour-warehouse/i18n";
#else
    m_langdir = QmlApplicationViewerPrivate::adjustPath("i18n");
#endif
    loadAvailableLanguages();
    m_app->installTranslator(&m_translator);
    //changeLanguage(QVariant(lang));
}

QVariant AppTranslator::getDefaultLanguage()
{
    QString lang = QLocale::system().name();
    //qDebug() << "Default:" << lang;
    if (m_languages.find(lang)==m_languages.end())
        lang.truncate(2);
    if (m_languages.find(lang)==m_languages.end())
        lang = "en";
    const QStringList appArgs = m_app->arguments();
    foreach (const QString &arg, appArgs) {
        if (arg.startsWith(QLatin1String("--lang="))) {
            lang = arg.mid(7);
            break;
        }
    }
    return QVariant(lang);
}

void AppTranslator::changeLanguage(QVariant language)
{
    m_app->removeTranslator(&m_translator);
    QString lang = language.toString();
    qDebug("Loading \"%s\" translation", qPrintable(lang));
    m_translator.load(lang, m_langdir);
    m_app->installTranslator(&m_translator);
    emit languageChanged(lang);
}

QVariant AppTranslator::getLanguageName(QVariant code)
{
    return QVariant(m_languages[code.toString()]);
}

QVariant AppTranslator::getAvailableLanguages()
{
    return QVariant(m_languages);
}

void AppTranslator::loadAvailableLanguages()
{
    QVariantMap languages;

    QTranslator loader;
    QDir dir(m_langdir);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    dir.setNameFilters(QStringList("*.qm"));
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
        QString filename = list.at(i).baseName();
        if (loader.load(filename,m_langdir)) {
            QString code = filename;
            QLocale loc(code);
            //qDebug() << "Locale found:" << loc.name() << "from:" << code;
            QString name = QLocale::languageToString(loc.language());
            if (code.length()>2)
                name += " (" + QLocale::countryToString(loc.country()) + ")";
            languages.insert(code,name);
        }
    }
    m_languages = languages;
}
