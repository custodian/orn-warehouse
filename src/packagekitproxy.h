#ifndef PACKAGEKITPROXY_H
#define PACKAGEKITPROXY_H

#include <QObject>
#include <QScopedPointer>
#include <QVariantList>
#include <QStringList>

#include <Daemon>
#include <Transaction>

class TransactionProxy: public PackageKit::Transaction {
    Q_OBJECT
public:
    TransactionProxy(QObject *parent = 0);
    TransactionProxy(QString path, QObject *parent = 0);

    QString name();

    bool own;
};

class PackageKitProxy: public QObject
{
    Q_OBJECT
public:
    PackageKitProxy(QObject *parent = NULL);

    Q_INVOKABLE QString getRepoList();
    Q_INVOKABLE QString getUpdatesList();

    Q_INVOKABLE QString refreshRepositoryInfo();
    Q_INVOKABLE void enableRepository(QString reponame);
    Q_INVOKABLE void disableRepository(QString reponame);

    Q_INVOKABLE QString searchName(QString packagename);
    Q_INVOKABLE QString packageDetails(QString packageid);
    Q_INVOKABLE QString getInstalledApps();


    Q_INVOKABLE QString installFile(QString filename);
    Q_INVOKABLE QString installPackage(QString packageid);
    Q_INVOKABLE QString updatePackage(QString packageid);
    Q_INVOKABLE QString removePackage(QString packageid);

signals:
    void repoListChanged();
    void restartScheduled();
    void transactionListChanged(QStringList transactionList);
    void updatesChanged();
    void daemonQuit();

    void transactionProgress(QString trname, QVariantMap pkgobject, QString trstatus, int trprogress);
    void transactionPackage(QString trname, QVariantMap pkgobject, QString pkgstatus, QString pkgsummary);
    void transactionError(QString trname, QString trstatus, QString trmessage);
    void transactionFinished(QString trname, QString trstatus, int trruntime);
    void transactionRepoDetail(QString trname, QString repoid, QString repodesc, bool repoenabled);
    void transactionDetails(QString trname, QVariantMap pkgobject, QString pkglicense, QString pkggroup, QString pkgdetail, QString pkgurl, int pkgsize);

private slots:
    void d_onRepoListChanged();
    void d_onRestartScheduled();
    void d_onTransactionListChanged(const QStringList& transactionList);
    void d_onUpdatesChanged();
    void d_onDaemonQuit();

public slots:
    void t_onRepoDetail(QString repoid, QString description, bool enabled);
    void t_onItemProgress(QString packageid, PackageKit::Transaction::Status status ,uint progress);
    void t_onPackage(PackageKit::Transaction::Info info, QString packageid, QString summary);
    void t_onFinished(PackageKit::Transaction::Exit exit, quint32 runtime);
    void t_onErrorCode(PackageKit::Transaction::Error code,QString message);
    void t_onDetails(QString packageid,QString license,PackageKit::Transaction::Group group,QString detail,QString url,qulonglong size);

private:
    TransactionProxy* createTransaction(QString name = "", bool own = true);
    void saveTransaction(TransactionProxy *transaction, bool own = false);
    void deleteTransaction(TransactionProxy *transaction);
    QVariantMap packageObject(QString packageid);

    QMap<QString, TransactionProxy*> m_transactions;
};

#endif // PACKAGEKITPROXY_H
