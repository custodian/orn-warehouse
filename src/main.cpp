#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QGraphicsObject>
#include <QInputContext>
#include <QSplashScreen>
#include "qmlapplicationviewer.h"

#include <qplatformdefs.h>

#include "apptranslator.h"
#include "cache.h"
#include "packagemanager.h"
#include "qmlthreadworker.h"

#if defined(Q_OS_HARMATTAN)
#include <MDeclarativeCache>
#endif

#if defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
#include "dbus_service.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#if defined(Q_WS_SIMULATOR)
    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::SslV3);
    QSslConfiguration::setDefaultConfiguration(config);
#endif

    QApplication *app = createApplication(argc, argv);

    AppTranslator *appTranslator = new AppTranslator(app);
    Cache *imageCache = new Cache("warehouse",app);
    PackageManager *pkgManager = new PackageManager(app);
    pkgManager->updateRepositoryList();

    //TODO: Enable before stable release, after remastering settings
    //Also check if app hangs on new install without database
    app->setApplicationName("Warehouse");
    app->setOrganizationName("Openrepos");

    QmlApplicationViewer viewer;

#if defined(Q_OS_MAEMO)
    QPixmap pixmap("/opt/warehouse/qml/images/splash-turned.png");
    QSplashScreen splash(pixmap);
    EventDisabler eventDisabler;
    splash.installEventFilter(&eventDisabler);
    splash.showFullScreen();
#endif

#if defined(Q_OS_MAEMO)
    viewer.addImportPath(QString("/opt/qtm12/imports"));
    viewer.engine()->addImportPath(QString("/opt/qtm12/imports"));
    viewer.engine()->addPluginPath(QString("/opt/qtm12/plugins"));
#endif

    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);

    viewer.rootContext()->setContextProperty("appTranslator", appTranslator);
    viewer.rootContext()->setContextProperty("imageCache", imageCache);
    viewer.rootContext()->setContextProperty("pkgManager", pkgManager);

    viewer.setMainQmlFile(QLatin1String("qml/main.qml"));
    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    Q_UNUSED(rootObject)
    //rootObject->connect(cache,SIGNAL(cacheUpdated(QVariant,QVariant,QVariant)),SLOT(onCacheUpdated(QVariant,QVariant,QVariant)));
    //rootObject->connect(appTranslator,SIGNAL(languageChanged(QVariant)),SLOT(onLanguageChanged(QVariant)));

#if defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
    DBusService dbus(app,&viewer);
    Q_UNUSED(dbus);
#endif

#if defined(Q_OS_MAEMO)
    viewer.showFullScreen();
#elif defined(Q_OS_HARMATTAN)
    viewer.showExpanded();
#else
    viewer.showExpanded();
#endif

#if defined(Q_OS_MAEMO)
    splash.finish(&viewer);
#endif

    return app->exec();
}
