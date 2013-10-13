#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusPendingCall>
#include <QtDBus/QDBusArgument>
#include <QtDBus/QDBusReply>
#include <QDebug>

#include <QDir>
#include <QFile>
#include <QFileInfoList>

#include <QDesktopServices>

#include "packagemanager.h"

#define PKG_SERVICE "com.nokia.package_manager"
#define PKG_PATH    "/com/nokia/package_manager"
#define PKG_IFACE   "com.nokia.package_manager"

PackageManager::PackageManager(QObject *parent) :
    QObject(parent)
#ifndef Q_WS_SIMULATOR
  , m_bus("warehouse")
#endif
{
#if defined(Q_OS_HARMATTAN)
    m_repospath = "/etc/apt/sources.list.d";

    //Connect to DBUS for events and calls
    m_bus = QDBusConnection::systemBus();
    qDebug() << "DBus Connection: " << m_bus.isConnected();

    qDebug() << "OnOperationStarted connected: " <<
    m_bus.connect(PKG_SERVICE,PKG_PATH,PKG_IFACE,"operation_started",this,SLOT(onPkgOperationStarted(QString,QString,QString)));
    qDebug() << "OnOperationProgress connected: " <<
    m_bus.connect(PKG_SERVICE,PKG_PATH,PKG_IFACE,"operation_progress",this,SLOT(onPkgOperationProgress(QString,QString,QString,qint32)));
    qDebug() << "OnOperationCompleted connected: " <<
    m_bus.connect(PKG_SERVICE,PKG_PATH,PKG_IFACE,"operation_complete",this,SLOT(onPkgOperationCompleted(QString,QString,QString,QString,bool)));

    qDebug() << "OnDownloadProgress connected: " <<
    m_bus.connect(PKG_SERVICE,PKG_PATH,PKG_IFACE,"download_progress",this,SLOT(onPkgDownloadProgress(QString,QString,QString,qint32,qint32)));
    qDebug() << "OnPackageListUpdated connected: " <<
    m_bus.connect(PKG_SERVICE,PKG_PATH,PKG_IFACE,"package_list_updated",this,SLOT(onPkgPackageListUpdate(bool)));
#else
    QDesktopServices dirs;
    m_repospath = dirs.storageLocation(QDesktopServices::CacheLocation) + "/warehouse/repos";
    QDir dir;
    dir.mkdir(m_repospath);
#endif
}

void PackageManager::onPkgOperationStarted(QString operation, QString name, QString version) {
    //qDebug() << "Operation started" << operation << name << version;
    emit operationStarted(QVariant(operation),QVariant(name),QVariant(version));
}
void PackageManager::onPkgOperationProgress(QString operation, QString name, QString version, qint32 progress){
    //qDebug() << "Operation progress" << operation << name << version << "progress" << progress;
    emit operationProgress(QVariant(operation), QVariant(name), QVariant(version), QVariant(progress));
}
void PackageManager::onPkgOperationCompleted(QString operation, QString name, QString version, QString message, bool isError) {
    //qDebug() << "Operation completed" << operation << name << version << "Message:" << message << "IsError" << isError;
    emit operationCompleted(QVariant(operation), QVariant(name), QVariant(version), QVariant(message), QVariant(isError));
}

void PackageManager::onPkgDownloadProgress(QString operation, QString name, QString version, qint32 curBytes, qint32 totalBytes) {
    //qDebug() << "Download progress" << operation << name << version << "Downloaded" << curBytes << "of" << totalBytes;
    emit downloadProgress(QVariant(operation), QVariant(name), QVariant(version), QVariant(curBytes), QVariant(totalBytes));
}
void PackageManager::onPkgPackageListUpdate(bool result) {
    //qDebug() << "Package list update:" << result;
    emit packageListUpdate(QVariant(result));
}

QString PackageManager::getListFileName(QString name) {
    QString filename = QString("openrepos-%1.list").arg(name);
    QFileInfo info(m_repospath, filename);
    return info.absoluteFilePath();
}

void PackageManager::fetchRepositoryInfo() {
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"refresh_package_cache");
    QVariantList args;
    args.push_back("");
    args.push_back("");
    msg.setArguments(args);
    m_bus.asyncCall(msg);
#endif
}

QVariant PackageManager::getPackageInfo(QString packagename) {
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"fetch_package_data");
    QVariantList args;
    args.push_back(packagename);
    args.push_back("");
    msg.setArguments(args);
    QDBusReply<QVariantMap> reply = m_bus.call(msg);
    if (reply.isValid()) {
        QVariantMap result = reply.value();
        return QVariant::fromValue(result);
    } else {
        return QVariant(false);
    }
#else
    Q_UNUSED(packagename);
    return QVariant(false);
#endif
}

void PackageManager::install(QString packagename) {
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"install");
    QVariantList args;
    args.push_back(packagename);
    args.push_back("");
    msg.setArguments(args);
    m_bus.asyncCall(msg);
}

void PackageManager::uninstall(QString packagename) {
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"uninstall");
    QVariantList args;
    args.push_back(packagename);
    msg.setArguments(args);
    m_bus.asyncCall(msg);
}

void PackageManager::enableRepository(QString name)
{
    QString filepath = getListFileName(name);
    QFile file(filepath);
    QString repositoryString = QString("deb http://harmattan.openrepos.net/%1 personal main").arg(name);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(repositoryString.toLocal8Bit());
    file.close();
    //update list
    updateRepositoryList();
}

void PackageManager::disableRepository(QString name)
{
    QString filepath = getListFileName(name);
    qDebug() << "removing" << filepath;
    QFile::remove(filepath);
    //update list
    updateRepositoryList();
}

void PackageManager::updateRepositoryList()
{
    m_repositories.clear();
    emit repositoryListChanged(QVariant::fromValue(m_repositories));

    QDir dir(m_repospath);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    dir.setNameFilters(QStringList("openrepos-*.list*"));
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
        QVariantMap map;
        QFileInfo info = list.at(i);
        QString reponame = info.baseName();
        reponame.replace("openrepos-","");
        map.insert("name", reponame);
        map.insert("enabled", info.completeSuffix() == "list");
        m_repositories.push_back(map);
    }

    QVariant repos = QVariant::fromValue(m_repositories);
    //qDebug() << "REPOS: " << repos;

    emit repositoryListChanged(repos);
}

QVariant PackageManager::isRepositoryEnabled(QString name) {
    bool result = false;
    for (int i=0;i<m_repositories.count();i++) {
        QVariantMap rep = m_repositories.at(i).toMap();
        if (rep["name"] == name) {
            result = true;
            break;
        }
    }

    return QVariant(result);
}
