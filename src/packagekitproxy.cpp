#include <QDebug>
#include <QVariantList>
#include <QStringList>

#include <QProcess>

#include <Daemon>
#include <Transaction>

#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusPendingCall>
#include <QtDBus/QDBusArgument>
#include <QtDBus/QDBusReply>

#include "packagekitproxy.h"

#define PKG_SERVICE "org.freedesktop.PackageKit"
#define PKG_PATH    "/org/freedesktop/PackageKit"
#define PKG_IFACE   "org.freedesktop.PackageKit"

#define ENUM_TO_STRING(Type, Value) PackageKit::Daemon::enumToString<PackageKit::Transaction>(Value, #Type)

TransactionProxy::TransactionProxy(QObject *parent):
    PackageKit::Transaction(QDBusObjectPath(),parent) {
    own = false;
}

TransactionProxy::TransactionProxy(QString path, QObject *parent):
    PackageKit::Transaction(QDBusObjectPath(path),parent) {
    own = false;
}

QString TransactionProxy::name()
{
    return this->tid().path();
}

PackageKitProxy::PackageKitProxy(QObject *parent):
    QObject(parent)
{
    QDBusConnection bus = QDBusConnection::systemBus();
    qDebug() << "DBus System Connection: " << bus.isConnected();
    qDebug() << "DBus PackageKit transactionListChanged connected" <<
    bus.connect(PKG_SERVICE, PKG_PATH, PKG_IFACE, "TransactionListChanged", this, SLOT(d_onTransactionListChanged(QStringList)));
    qDebug() << "DBus PackageKit updatesChanged connected" <<
    bus.connect(PKG_SERVICE, PKG_PATH, PKG_IFACE, "UpdatesChanged", this, SLOT(d_onUpdatesChanged()));
    qDebug() << "DBus PackageKit repoListChanged connect" <<
    bus.connect(PKG_SERVICE, PKG_PATH, PKG_IFACE, "RepoListChanged", this, SLOT(d_onRepoListChanged()));
    qDebug() << "DBus PackageKit restartScheduled connect" <<
    bus.connect(PKG_SERVICE, PKG_PATH, PKG_IFACE, "RestartScheduled", this, SLOT(d_onRestartScheduled()));

    PackageKit::Daemon *daemon = PackageKit::Daemon::global();
    qDebug() << "Found backend" << daemon->backendName();
    /*
     *  Bugged and dont work DBus used instead
     *
    qDebug() << "connect repoListChanged" <<
    connect(daemon,SIGNAL(repoListChanged()), SLOT(d_onRepoListChanged()));
    qDebug() << "connect restartScheduled" <<
    connect(daemon,SIGNAL(restartScheduled()), SLOT(d_onRestartScheduled()));
    qDebug() << "connect transactionListChanged" <<
    connect(daemon,SIGNAL(transactionListChanged(const QStringList&)), SLOT(d_onTransactionListChanged(const QStringList&)));
    qDebug() << "connect updatesChanged" <<
    connect(daemon,SIGNAL(updatesChanged()), SLOT(d_onUpdatesChanged()));
    */
    qDebug() << "connect daemonQuit" <<
    connect(daemon,SIGNAL(daemonQuit()), SLOT(d_onDaemonQuit()));

    /*
    qDebug() << "packageArch test" << PackageKit::Daemon::packageArch("ownNotes;1.1.2-1;i586;installed");
    qDebug() << "packageData test" << PackageKit::Daemon::packageData("ownNotes;1.1.2-1;i586;installed");
    qDebug() << "packageIcon test" << PackageKit::Daemon::packageIcon("ownNotes;1.1.2-1;i586;installed");
    qDebug() << "packageName test" << PackageKit::Daemon::packageName("ownNotes;1.1.2-1;i586;installed");
    qDebug() << "packageVersion test" << PackageKit::Daemon::packageVersion("ownNotes;1.1.2-1;i586;installed");

    qDebug() << "packageArch test2" << PackageKit::Daemon::packageArch("ownNotes;1.1.1-1;i586;openrepos-Khertan");
    qDebug() << "packageData test2" << PackageKit::Daemon::packageData("ownNotes;1.1.1-1;i586;openrepos-Khertan");
    qDebug() << "packageIcon test2" << PackageKit::Daemon::packageIcon("ownNotes;1.1.1-1;i586;openrepos-Khertan");
    qDebug() << "packageName test2" << PackageKit::Daemon::packageName("ownNotes;1.1.1-1;i586;openrepos-Khertan");
    qDebug() << "packageVersion test2" << PackageKit::Daemon::packageVersion("ownNotes;1.1.1-1;i586;openrepos-Khertan");
    */

    /*
    qDebug() << "Test install transaction";
    PackageKit::Transaction* tester = createTransaction();
    tester->installPackage("ownNotes;1.1.0-1;i586;openrepos-Khertan");
    /**/

    /*
    qDebug() << "Test remove transaction";
    TransactionProxy* tester = createTransaction();
    //tester->searchNames("ownNotes",PackageKit::Transaction::FilterInstalled);
    tester->removePackage("ownNotes;1.1.0-1;i586;installed");
    /**/
}

TransactionProxy* PackageKitProxy::createTransaction(QString name, bool own)
{
    TransactionProxy* transaction = new TransactionProxy(name);
    //qDebug() << "Transaction" << transaction->name() << "created";

    //insert transcation to own list
    saveTransaction(transaction, own);

    //TODO: more signals needed! MOAR!!11111
    connect(transaction,SIGNAL(package(PackageKit::Transaction::Info,QString,QString)),SLOT(t_onPackage(PackageKit::Transaction::Info,QString,QString)));
    connect(transaction,SIGNAL(errorCode(PackageKit::Transaction::Error,QString)),SLOT(t_onErrorCode(PackageKit::Transaction::Error,QString)));
    connect(transaction,SIGNAL(finished(PackageKit::Transaction::Exit,uint)),SLOT(t_onFinished(PackageKit::Transaction::Exit,quint32)));
    connect(transaction,SIGNAL(itemProgress(QString,PackageKit::Transaction::Status,uint)),SLOT(t_onItemProgress(QString,PackageKit::Transaction::Status,uint)));
    connect(transaction,SIGNAL(repoDetail(QString,QString,bool)),SLOT(t_onRepoDetail(QString,QString,bool)));
    connect(transaction,SIGNAL(details(QString,QString,PackageKit::Transaction::Group,QString,QString,qulonglong)),SLOT(t_onDetails(QString,QString,PackageKit::Transaction::Group,QString,QString,qulonglong)));

    return transaction;
}

void PackageKitProxy::saveTransaction(TransactionProxy *transaction, bool own)
{
    transaction->own = own;
    m_transactions.insert(transaction->name(), transaction);
}

void PackageKitProxy::deleteTransaction(TransactionProxy *transaction)
{
    QString path = transaction->name();
    if (m_transactions.contains(path)) {
        m_transactions.remove(path);
    } else {
        qDebug() << "Unknown transaction" << path << "probably a sync bug";
    }
    delete transaction;
    //qDebug() << "Transaction" << path << "deleted.";
}

QVariantMap PackageKitProxy::packageObject(QString packageid)
{
    QVariantMap obj;
    obj["packageid"] = packageid;
    obj["arch"] = PackageKit::Daemon::packageArch(packageid);
    obj["data"] = PackageKit::Daemon::packageData(packageid);
    obj["icon"] = PackageKit::Daemon::packageIcon(packageid);
    obj["name"] = PackageKit::Daemon::packageName(packageid);
    obj["version"] = PackageKit::Daemon::packageVersion(packageid);
    return obj;
}

QString PackageKitProxy::getRepoList()
{
    TransactionProxy *transaction = createTransaction();
    transaction->getRepoList();
    return transaction->name();
}

QString PackageKitProxy::getUpdatesList()
{
    TransactionProxy *transaction = createTransaction();
    transaction->getUpdates();
    return transaction->name();
}

QString PackageKitProxy::refreshRepositoryInfo()
{
    TransactionProxy *transaction = createTransaction();
    transaction->refreshCache(false);
    return transaction->name();
}

void PackageKitProxy::enableRepository(QString reponame)
{
    QString repoid = QString("openrepos-%1").arg(reponame);

    QStringList args;
    args.push_back("ar");
    args.push_back(repoid);
    args.push_back(QString("http://sailfish.openrepos.net/%1/personal/main").arg(reponame));
    QProcess ssuar;
    ssuar.start("ssu",args);
    ssuar.waitForFinished();

/*
    args.clear();

    QProcess ssuur;
    args.push_back("ur");
    ssuur.start("ssu", args);
    ssuur.waitForFinished();
*/
    refreshRepositoryInfo();
    emit repoListChanged();
}

void PackageKitProxy::disableRepository(QString reponame)
{
    QString repoid = QString("openrepos-%1").arg(reponame);

    QStringList args;
    args.push_back("rr");
    args.push_back(repoid);
    QProcess ssurr;
    ssurr.start("ssu",args);
    ssurr.waitForFinished();

/*
    args.clear();

    QProcess ssuur;
    args.push_back("ur");
    ssuur.start("ssu", args);
    ssuur.waitForFinished();
*/
    refreshRepositoryInfo();
    emit repoListChanged();
}

QString PackageKitProxy::searchName(QString packagename)
{
    TransactionProxy *transaction = createTransaction();
    transaction->searchNames(packagename, TransactionProxy::FilterBasename);
    return transaction->name();
}

QString PackageKitProxy::getInstalledApps()
{
    TransactionProxy *transaction = createTransaction();
    transaction->getPackages(TransactionProxy::FilterInstalled);
    return transaction->name();
}

QString PackageKitProxy::packageDetails(QString packageid)
{
    TransactionProxy *transaction = createTransaction();
    transaction->getDetails(packageid);
    return transaction->name();
}
QString PackageKitProxy::installFile(QString filename)
{
    TransactionProxy *transaction = createTransaction();
    transaction->installFile(filename);
    return transaction->name();
}

QString PackageKitProxy::installPackage(QString packageid)
{
    TransactionProxy *transaction = createTransaction();
    transaction->installPackage(packageid);
    return transaction->name();
}

QString PackageKitProxy::updatePackage(QString packageid)
{
    TransactionProxy *transaction = createTransaction();
    transaction->updatePackage(packageid);
    return transaction->name();
}

QString PackageKitProxy::removePackage(QString packageid)
{
    TransactionProxy *transaction = createTransaction();
    transaction->removePackage(packageid, false, false);
    return transaction->name();
}

void PackageKitProxy::d_onRepoListChanged()
{
    qDebug() << "d_onRepoListChanged";
    emit repoListChanged();
}

void PackageKitProxy::d_onRestartScheduled()
{
    qDebug() << "d_onRestartScheduled";
    emit restartScheduled();
}

void PackageKitProxy::d_onTransactionListChanged(const QStringList& transactionList)
{
    //qDebug() << "transaction list" << transactionList;
    foreach(QString transName, transactionList) {
        if (!m_transactions.contains(transName)) {
            //qDebug() << "Unknown transaction" << transName;
            createTransaction(transName, false);
        } else {
            //qDebug() << "Known transaction" << transName;
        }
    }
    emit transactionListChanged(transactionList);
}

void PackageKitProxy::d_onUpdatesChanged()
{
    qDebug() << "d_onUpdatesChanged";
    emit updatesChanged();
}

void PackageKitProxy::d_onDaemonQuit()
{
    qDebug() << "d_onDaemonQuit";
    emit daemonQuit();
}

void PackageKitProxy::t_onItemProgress(QString packageid, PackageKit::Transaction::Status code, uint progress)
{
    TransactionProxy *tran = qobject_cast<TransactionProxy *>(sender());
    if (tran) {
        QString trName = tran->name();
        QString status = ENUM_TO_STRING(Status, code);
        //qDebug() << "t_onItemProcess" << trName << "Package:" << packageid << "status" << status << "progress" << progress;
        emit transactionProgress(trName, packageObject(packageid), status, progress);
    }
}

void PackageKitProxy::t_onPackage(PackageKit::Transaction::Info info, QString packageid, QString summary)
{
    TransactionProxy *tran = qobject_cast<TransactionProxy *>(sender());
    if (tran) {
        QString trName = tran->name();
        QString status = ENUM_TO_STRING(Info, info);
        //qDebug() << "t_onPackage" << trName << "info:" << status << "packageid" << packageid << "summary" << summary;
        emit transactionPackage(trName, packageObject(packageid), status, summary);
    }
}

void PackageKitProxy::t_onErrorCode(PackageKit::Transaction::Error code,QString message)
{
    TransactionProxy *tran = qobject_cast<TransactionProxy *>(sender());
    if (tran) {
        QString trName = tran->name();
        QString status = ENUM_TO_STRING(Error, code);
        qDebug() << "t_onErrorCode" << trName << "code" << status << "message" << message;
        if (tran->own) {
            emit transactionError(trName, status, message);
        }
    }
}

void PackageKitProxy::t_onFinished(PackageKit::Transaction::Exit code, quint32 runtime)
{
    TransactionProxy *tran = qobject_cast<TransactionProxy *>(sender());
    if (tran) {
        QString trName = tran->name();
        QString status = ENUM_TO_STRING(Exit, code);
        //qDebug() << "t_onFinished" << trName << "exit:" << status << "runtime" << runtime;
        emit transactionFinished(trName, status, runtime);
        deleteTransaction(tran);
    }
}

void PackageKitProxy::t_onRepoDetail(QString repoid, QString description, bool enabled)
{
    TransactionProxy *tran = qobject_cast<TransactionProxy *>(sender());
    if (tran) {
        QString trName = tran->name();
        //qDebug() << "t_onRepoDetail" << trName << "repoid" << repoid << "desc" << description << "enabeld" << enabled;
        emit transactionRepoDetail(trName, repoid, description, enabled);
    }
}

void PackageKitProxy::t_onDetails(QString packageid,QString license,PackageKit::Transaction::Group group,QString detail,QString url,qulonglong size)
{
    TransactionProxy *tran = qobject_cast<TransactionProxy *>(sender());
    if (tran) {
        QString trName = tran->name();
        QString sgroup = ENUM_TO_STRING(Group, group);
        qDebug() << "t_onDetails" << trName << "packageid" << packageid << "license" << license << "group" << sgroup << "detail" << detail << "url" << url << "size" << size;
        emit transactionDetails(trName, packageObject(packageid), license, sgroup, detail, url, size);
    }
}
