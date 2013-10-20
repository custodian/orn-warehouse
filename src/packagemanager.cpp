#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusPendingCall>
#include <QtDBus/QDBusArgument>
#include <QtDBus/QDBusReply>
#include <QThreadPool>
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
    m_worker.setCallObject(this);
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
void PackageManager::onPkgPackageListUpdate(bool updates) {
    qDebug() << "Package list update:" << updates;
    emit packageListUpdate(QVariant(updates));
}

void PackageManager::queueAction(QVariant msg) {
    m_worker.queueAction(msg);
}

void PackageManager::processAction(QVariant message) {
    QVariantMap msg = message.toMap();
    QString function = msg["name"].toString();
    QVariant params = msg["params"];
    QVariantMap reply;
    //qDebug() << "Process:" << function << "Args:" << params;
    if(function == "enableRepository") {
        enableRepository(params.toString());
    } else if(function == "disableRepository") {
        disableRepository(params.toString());
    } else if(function == "updateRepositoryList") {
        updateRepositoryList();
    } else if (function == "fetchRepositoryInfo") {
        reply = fetchRepositoryInfo(params.toString());
    } else if(function == "isRepositoryEnabled") {
        reply = isRepositoryEnabled(params.toString());
    } else if(function == "getPackageInfo") {
        reply = getPackageInfo(params.toString(), "");
    } else if(function == "install") {
        reply = install(params.toString());
    } else if (function == "upgrade") {
        reply = upgrade(params.toString());
    } else if(function == "uninstall") {
        reply = uninstall(params.toString());
    } else if(function == "getInstalledPackages") {
        reply = getInstalledPackages(params.toBool());
    }/* else if(function == "") {
    }*/
    if (reply.contains("reply")) {
        msg["result"] = reply["reply"];
    }
    if (reply.contains("error")) {
        msg["error"] = true;
        msg["errorText"] = reply["error"];
        qDebug() << "Call:" << function << "Error:" << reply["error"];
    }
    emit actionDone(msg);
}

QString PackageManager::getListFileName(QString name) {
    QString filename = QString("openrepos-%1.list").arg(name);
    QFileInfo info(m_repospath, filename);
    return info.absoluteFilePath();
}

QVariantMap PackageManager::fetchRepositoryInfo(QString domain) {
    QVariantMap callresult;
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"refresh_package_cache");
    QVariantList args;
    args.push_back(domain);
    args.push_back("");
    msg.setArguments(args);
    QDBusMessage reply = m_bus.call(msg, QDBus::Block, 60000);
    if (reply.type() == QDBusMessage::ErrorMessage) {
        qDebug() << "Error: " << reply.errorMessage();
        callresult["error"] = reply.errorMessage();
    }
#else
    emit operationStarted("Refresh", "", "");
    IWaiter::sleep(2);
    emit operationCompleted("Refresh","","","",false);
#endif
    return callresult;
}

QVariantMap PackageManager::getPackageInfo(QString packagename, QString version) {
    QVariantMap callresult;
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"fetch_package_data");
    QVariantList args;
    args.push_back(packagename);
    args.push_back(version);
    msg.setArguments(args);
    QDBusReply<QVariantMap> reply = m_bus.call(msg, QDBus::Block, 60000);
    if (reply.isValid()) {
        QVariantMap result = reply.value();
        result.remove("IconData");
        callresult["reply"] = QVariant::fromValue(result);
    } else {
        QDBusError error = reply.error();
        if (error.type() == 1 && reply.error().name() == "com.nokia.package_manager.Error.PackageNotFound") {
            callresult["reply"] = false;
        } else {
            callresult["error"] = reply.error().message();
        }
    }
#else
    QVariantMap result;
    result["Type"] = "NotInstalled";
    result["Version"] = "1.0.1";
    if (m_packages.contains(packagename)) {
        result = m_packages[packagename];
    } else {
        m_packages[packagename] = result;
    }
    return result;
#endif
    return callresult;
}

QVariantMap PackageManager::getInstalledPackages(bool owned) {
    QVariantMap callresult;
    QVariantList packages;
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"fetch_installed");
    QDBusReply<QDBusArgument> reply = m_bus.call(msg, QDBus::Block, 60000);
    if (reply.isValid()) {
        QDBusArgument var = reply.value();
        var.beginArray();
        while( !var.atEnd() ) {
            QVariantMap package;
            var >> package;
            bool goodpackage = !owned;
            if (owned) {
                QString origin = package["Origin"].toString();
                if (origin == "/net.openrepos.harmattan") {
                    goodpackage = true;
                } else if (origin != "com.nokia.maemo/ovi" && origin != "com.nokia.maemo" ) {
                    QVariantMap pkgInfo = getPackageInfo(package["Name"].toString(),package["Version"].toString())["reply"].toMap();
                    if (pkgInfo["Origin"].toString() == "/net.openrepos.harmattan" || pkgInfo["Repository"].toString().contains("harmattan.openrepos.net")) {
                        goodpackage = true;
                    }
                }
            }
            if (goodpackage) {
                packages.push_back(QVariant(package));
            }
        };
        callresult["reply"] = packages;
    } else {
        callresult["error"] = reply.error().message();
    }
#endif
    return callresult;
}

QVariantMap PackageManager::install(QString packagename) {
    QVariantMap callresult;
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"install");
    QVariantList args;
    args.push_back(packagename);
    args.push_back("");
    msg.setArguments(args);
    QDBusMessage reply = m_bus.call(msg, QDBus::Block, 60000);
    if (reply.type() == QDBusMessage::ErrorMessage) {
        callresult["error"] = reply.errorMessage();
    }
#else
    if (m_packages.contains(packagename)) {
        QVariantMap &package = m_packages[packagename];
        for (int i=0;i<100;i++) {
            emit downloadProgress("Download", packagename, package["Version"], i,100);
            IWaiter::msleep(10);
        }
        emit operationStarted("Install", packagename, package["Version"]);
        for (int i=0;i<100;i++) {
            emit operationProgress("Install", packagename, package["Version"], i);
            IWaiter::msleep(10);
        }
        emit operationCompleted("Install",packagename,package["Version"],"",false);
        package["Type"] = "Installed";
    }
#endif
    return callresult;
}

QVariantMap PackageManager::upgrade(QString packagename) {
    QVariantMap callresult;
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"upgrade");
    QVariantList args;
    args.push_back(packagename);
    args.push_back("");
    msg.setArguments(args);
    QDBusMessage reply = m_bus.call(msg, QDBus::Block, 60000);
    if (reply.type() == QDBusMessage::ErrorMessage) {
        callresult["error"] = reply.errorMessage();
    }
#else
    if (m_packages.contains(packagename)) {
        QVariantMap &package = m_packages[packagename];
        for (int i=0;i<100;i++) {
            emit downloadProgress("Download", packagename, package["Version"], i,100);
            IWaiter::msleep(10);
        }
        emit operationStarted("Upgrade", packagename, package["Version"]);
        for (int i=0;i<100;i++) {
            emit operationProgress("Upgrade", packagename, package["Version"], i);
            IWaiter::msleep(10);
        }
        emit operationCompleted("Upgrade",packagename,package["Version"],"",false);
        package["Type"] = "Installed";
    }
#endif
    return callresult;
}

QVariantMap PackageManager::uninstall(QString packagename) {
    QVariantMap callresult;
#if defined(Q_OS_HARMATTAN)
    QDBusMessage msg = QDBusMessage::createMethodCall(PKG_SERVICE,PKG_PATH,PKG_IFACE,"uninstall");
    QVariantList args;
    args.push_back(packagename);
    msg.setArguments(args);
    QDBusMessage reply = m_bus.call(msg, QDBus::Block, 60000);
    if (reply.type() == QDBusMessage::ErrorMessage) {
        callresult["error"] = reply.errorMessage();
    }
#else
    if (m_packages.contains(packagename)) {
        QVariantMap &package = m_packages[packagename];
        emit operationStarted("Uninstall", packagename, package["Version"]);
        for (int i=0;i<100;i++) {
            emit operationProgress("Uninstall", packagename, package["Version"], i);
            IWaiter::msleep(10);
        }
        emit operationCompleted("Uninstall",packagename,package["Version"],"",false);
        package["Type"] = "NotInstalled";
    }
#endif
    return callresult;
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

QVariantMap PackageManager::isRepositoryEnabled(QString name) {
    bool result = false;
    for (int i=0;i<m_repositories.count();i++) {
        QVariantMap rep = m_repositories.at(i).toMap();
        if (rep["name"] == name) {
            result = true;
            break;
        }
    }

    QVariantMap callresult;
    callresult["reply"] = result;
    return callresult;
}
