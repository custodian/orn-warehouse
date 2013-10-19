#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include <QMap>
#include <QVariantMap>
#include <QtDBus/QDBusAbstractAdaptor>
#include "qmlthreadworker.h"

#ifndef Q_WS_SIMULATOR
#include <QtDBus/QDBusConnection>
#else
#include <QThread>

class IWaiter: public QThread
{
public:
    static void sleep(unsigned long secs) {
        QThread::sleep(secs);
    }
    static void msleep(unsigned long msecs) {
        QThread::msleep(msecs);
    }
    static void usleep(unsigned long usecs) {
        QThread::usleep(usecs);
    }
};
#endif

class PackageManager : public QObject
{
    Q_OBJECT
public:
    explicit PackageManager(QObject *parent);

public slots:
    void queueAction(QVariant msg);
    void processAction(QVariant msg);

    void updateRepositoryList();
    void enableRepository(QString name);
    void disableRepository(QString name);

    void fetchRepositoryInfo(QString domain);
    QVariant isRepositoryEnabled(QString name);
    QVariant getPackageInfo(QString packagename);

    void install(QString packagename);
    void uninstall(QString packagename);

    void onPkgOperationStarted(QString operation, QString name, QString version);
    void onPkgOperationProgress(QString operation, QString name, QString version, qint32 progress);
    void onPkgOperationCompleted(QString operation, QString name, QString version, QString message, bool isError);

    void onPkgDownloadProgress(QString operation, QString name, QString version, qint32 curBytes, qint32 totalBytes);
    void onPkgPackageListUpdate(bool updates);

signals:
    void actionDone(QVariant msg);

    void repositoryListChanged(QVariant repos);

    void operationStarted(QVariant operation, QVariant name, QVariant version);
    void operationProgress(QVariant operation, QVariant name, QVariant version, QVariant progress);
    void operationCompleted(QVariant operation, QVariant name, QVariant version, QVariant message, QVariant error);

    void downloadProgress(QVariant operation, QVariant name, QVariant version, QVariant curBytes, QVariant totalBytes);
    void packageListUpdate(QVariant updates);

private:
    QString getListFileName(QString name);

private:
    QString m_repospath;
    QObject * m_component;
    QVariantList m_repositories;

    QmlThreadWorker m_worker;
#ifndef Q_WS_SIMULATOR
    QDBusConnection m_bus;
#else
    QMap<QString, QVariantMap> m_packages;
#endif
};

#endif // PACKAGEMANAGER_H
