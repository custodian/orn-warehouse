#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include <QMap>
#include <QVariantMap>
#include <QtDBus/QDBusAbstractAdaptor>
#ifndef Q_WS_SIMULATOR
#include <QtDBus/QDBusConnection>
#endif

class PackageManager : public QObject
{
    Q_OBJECT
public:
    explicit PackageManager(QObject *parent);

public slots:
    void updateRepositoryList();
    void enableRepository(QString name);
    void disableRepository(QString name);

    QVariant isRepositoryEnabled(QString name);

    void fetchRepositoryInfo();
    QVariant getPackageInfo(QString packagename);

    void install(QString packagename);
    void uninstall(QString packagename);

    void onPkgOperationStarted(QString operation, QString name, QString version);
    void onPkgOperationProgress(QString operation, QString name, QString version, qint32 progress);
    void onPkgOperationCompleted(QString operation, QString name, QString version, QString message, bool isError);

    void onPkgDownloadProgress(QString operation, QString name, QString version, qint32 curBytes, qint32 totalBytes);
    void onPkgPackageListUpdate(bool result);

signals:
    void repositoryListChanged(QVariant repos);

    void operationStarted(QVariant operation, QVariant name, QVariant version);
    void operationProgress(QVariant operation, QVariant name, QVariant version, QVariant progress);
    void operationCompleted(QVariant operation, QVariant name, QVariant version, QVariant message, QVariant error);

    void downloadProgress(QVariant operation, QVariant name, QVariant version, QVariant curBytes, QVariant totalBytes);
    void packageListUpdate(QVariant result);

private:
    QString getListFileName(QString name);

private:
    QString m_repospath;
    QVariantList m_repositories;
#ifndef Q_WS_SIMULATOR
    QDBusConnection m_bus;
#endif
};

#endif // PACKAGEMANAGER_H
