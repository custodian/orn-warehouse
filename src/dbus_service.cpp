#include "dbus_service.h"

#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDBus/QDBusConnection>
#include <QDebug>

DBusService::DBusService(QApplication *parent, QDeclarativeView *view) :
    QDBusAbstractAdaptor(parent), m_view(view)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.registerService("com.thecust.warehouse");
#if defined(Q_OS_HARMATTAN)
    bus.registerObject("/com/thecust/warehouse", parent);
#elif defined(Q_OS_MAEMO)
    bus.registerObject("/com/thecust/warehouse", this, QDBusConnection::ExportScriptableSlots);
#endif


    QObject *rootObject = qobject_cast<QObject*>(view->rootObject());
    rootObject->connect(this,SIGNAL(processUINotification(QVariant)),SLOT(processUINotification(QVariant)));
    rootObject->connect(this,SIGNAL(processURI(QVariant)),SLOT(processURI(QVariant)));
}

void DBusService::showApplication() {
    m_view->show();
    m_view->activateWindow();
    //TODO: //BUG: process killed when event emited
    //emit processURI(QVariant("start/top"));
}

void DBusService::loadURI(const QStringList &url)
{
    showApplication();
    if (url.size()) {
        QString param = url.at(0);
        emit processURI(QVariant(param.replace("openrepos://","")));
    }
}

void DBusService::notification(QString identificator)
{
    showApplication();
    emit processUINotification(QVariant(identificator));
}
