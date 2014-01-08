#if defined(Q_OS_SAILFISH)
#include <QtQuick>
#include <sailfishapp.h>
#include <QGuiApplication>
#else
#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QGraphicsObject>
#include <QInputContext>
#include "qmlapplicationviewer.h"
#include <QSplashScreen>
#endif

#include <qplatformdefs.h>

#include "apptranslator.h"
#include "cache.h"

#if defined(Q_OS_SAILFISH)
#include "packagekitproxy.h"
#else
#include "packagemanager.h"
#endif

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

#if defined(Q_OS_SAILFISH)
    QGuiApplication *app = SailfishApp::application(argc, argv);
#else
    QApplication *app = createApplication(argc, argv);
#endif

    AppTranslator *appTranslator = new AppTranslator(app);
    Cache *imageCache = new Cache("warehouse",app);

    app->setApplicationName("Warehouse");
    app->setOrganizationName("Openrepos");

#if defined(Q_OS_SAILFISH)
    QQuickView* viewer = SailfishApp::createView();
    qmlRegisterType<PackageKitProxy>("net.thecust.packagekit", 1, 0, "PackageManagerProxy");
#else
    QmlApplicationViewer *viewer = new QmlApplicationViewer();
    PackageManager *pkgManager = new PackageManager(app);
    viewer->rootContext()->setContextProperty("pkgManager", pkgManager);
    pkgManager->updateRepositoryList();
#endif

#if defined(Q_OS_MAEMO)
    QPixmap pixmap("/opt/warehouse/qml/images/splash-turned.png");
    QSplashScreen splash(pixmap);
    EventDisabler eventDisabler;
    splash.installEventFilter(&eventDisabler);
    splash.showFullScreen();
#endif

    viewer->rootContext()->setContextProperty("appTranslator", appTranslator);
    viewer->rootContext()->setContextProperty("imageCache", imageCache);


#if defined(Q_OS_MAEMO)
    viewer->addImportPath(QString("/opt/qtm12/imports"));
    viewer->engine()->addImportPath(QString("/opt/qtm12/imports"));
    viewer->engine()->addPluginPath(QString("/opt/qtm12/plugins"));
#endif

#if defined(Q_OS_SAILFISH)
    viewer->setSource(SailfishApp::pathTo("qml/main-sailfish.qml"));
    QObject::connect(viewer->engine(), SIGNAL(quit()), QCoreApplication::instance(), SLOT(quit()));
#else
    viewer->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->setAttribute(Qt::WA_NoSystemBackground);
    viewer->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->viewport()->setAttribute(Qt::WA_NoSystemBackground);

    viewer->setMainQmlFile(QLatin1String("qml/main-harmattan.qml"));
    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    Q_UNUSED(rootObject)
    //rootObject->connect(cache,SIGNAL(cacheUpdated(QVariant,QVariant,QVariant)),SLOT(onCacheUpdated(QVariant,QVariant,QVariant)));
    //rootObject->connect(appTranslator,SIGNAL(languageChanged(QVariant)),SLOT(onLanguageChanged(QVariant)));
#endif


#if defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
    DBusService dbus(app,&viewer);
    Q_UNUSED(dbus);
#endif

#if defined(Q_OS_MAEMO)
    viewer->showFullScreen();
#elif defined(Q_OS_HARMATTAN)
    viewer->showExpanded();
#elif defined(Q_OS_SAILFISH)
    viewer->show();
#else
    viewer->showExpanded();
#endif

#if defined(Q_OS_MAEMO)
    splash.finish(&viewer);
#endif

    return app->exec();
}
