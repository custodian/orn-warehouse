#include "cache.h"
#include <QUrl>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>
#include <QByteArray>
#include <QCryptographicHash>
#include <QDesktopServices>
#include <QString>
#include <QDebug>

Cache::Cache(QString name, QObject *parent) :
    QObject(parent)
{
    m_cacheonly = false;


#if defined(Q_OS_SAILFISH)
    m_path = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
#else
    QDesktopServices dirs;
    m_path = dirs.storageLocation(QDesktopServices::CacheLocation);
#endif
    m_path += "/"+name+"/";
    //qDebug() << "Cache location: " << m_path;

    if (m_path.length()) {
        QDir dir;
        if (!dir.mkpath(m_path))
            qDebug () << "Error creating cache directory";
    }

    manager = new QNetworkAccessManager (this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),SLOT(onDownloadFinished(QNetworkReply*)));
}

QVariant Cache::getFile(QVariant url)
{
    QString data;
    QFile file(url.toString());
    if (file.exists()) {
        file.open(QIODevice::ReadOnly);
        data = file.readAll();
    }
    return QVariant(data);
}

QVariant Cache::loadtype(QVariant _type) {
    QString type = _type.toString();
    if (type == "all") {
        m_cacheonly = false;
    } else {
        m_cacheonly = true;
    }
    return QVariant(true);
}

void Cache::onDownloadFinished(QNetworkReply * reply){
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Error downloading: " << reply->errorString();
        return;
    }
    QByteArray data = reply->readAll();
    if (data.size() == 0) {
        qDebug() << "Empty data packet";
        return;
    }
    QString url = reply->request().url().toString();
    QString namelocal = makeCachedURL(url);

    {
        QFile file(namelocal);
        file.open(QFile::WriteOnly);
        file.write(data);
    }

    m_cachemap_lock.lockForWrite();
    m_cachemap.insert(url,namelocal);
    m_cachemap_lock.unlock();
    makeCallbackAll(true,url);
}

void Cache::processBase64Data(QVariant dataurl) {
    QString url = dataurl.toString();
    QString namelocal = makeCachedURL(url);
    QString datastr = url.right(datastr.length()-4);
    datastr = datastr.replace("base64://","");
    QByteArray data = QByteArray::fromBase64(datastr.toLocal8Bit());
    datastr = data;
    if (datastr.contains("xml version")) {
        namelocal += ".svg";
    }
    {
        QFile file(namelocal);
        file.open(QFile::WriteOnly);
        file.write(data);
    }
    m_cachemap_lock.lockForWrite();
    m_cachemap.insert(url,namelocal);
    m_cachemap_lock.unlock();
    makeCallbackAll(true,dataurl);
}

QString Cache::md5(QString data)
{
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(data.toLatin1());
    return hash.result().toHex();
}

QString Cache::makeCachedURL(QString url)
{
    QUrl uri(url);
    url = uri.toString(QUrl::RemoveQuery);
    QString ext = url.right(url.size() - url.lastIndexOf("."));
    ext = ext.left(ext.indexOf("/"));
    return m_path + "/" + md5(url) + ext;
}

QVariant Cache::removeUrl(QVariant dataurl)
{
    QString url = dataurl.toString();
    if (url.size()) {
        m_cachemap_lock.lockForWrite();
        m_cachemap.remove(url);
        m_cachemap_lock.unlock();
        QFile::remove(makeCachedURL(url));
    }
    return QVariant(true);
}

void Cache::queueObject(QVariant dataurl, QVariant callback)
{
    //qDebug() << "QueueObject callback: " << callback;
    QString namelocal;
    QString url = dataurl.toString();
    if (url.size()) {
        m_cachemap_lock.lockForRead();
        QMap<QString,QString>::iterator it = m_cachemap.find(url);
        if (it!=m_cachemap.end()) {
            //qDebug() << "cache hit" << url;
            namelocal = it.value();
            m_cachemap_lock.unlock();
            makeCallback(callback,true,namelocal);
        } else {
            //qDebug() << "cache miss" << url;
            namelocal = makeCachedURL(url);
            //qDebug() << "Hash:" << name << "Status:" << file.exists() << "URL:" << url;
#ifndef Q_WS_SIMULATOR
            {
                QFileInfo fileinfo(namelocal);
                QDateTime modif = fileinfo.lastModified();
                if (modif.daysTo(QDateTime::currentDateTime()) > CACHE_DAY_DURATION) {
                    QFile(fileinfo.absoluteFilePath()).remove();
                }
            }
#endif
            QFileInfo file(namelocal);
            if (file.exists()) {
                m_cachemap_lock.unlock();
                m_cachemap_lock.lockForWrite();
                m_cachemap.insert(url,namelocal);
                m_cachemap_lock.unlock();
                makeCallback(callback,true,namelocal);
            } else {
                m_cachemap_lock.unlock();
                if (m_cacheonly) {
                    dataurl = QVariant("");
                } else {
                    //add to queue, post and download query
                    if (queueCacheUpdate(dataurl, callback)) {
                        if (url.contains("base64://")) {
                            processBase64Data(dataurl);
                        } else {
                        manager->get(QNetworkRequest(QUrl(url)));
                        }
                    }
                }
            }            
        }
    } else {
        makeCallback(callback,false,dataurl);
    }
}

void Cache::dequeueObject(QVariant url, QVariant callback)
{
    //qDebug() << "Removing callback from queue" << callback << url;
    CCacheQueue::iterator it;
    m_cachequeue_lock.lockForWrite();
    it = m_cachequeue.find(url.toString());
    if (it == m_cachequeue.end()) {
        m_cachequeue_lock.unlock();
        //qDebug() << "Callback not found";
        //qDebug() << m_cachequeue;
        return;
    }
    CCallbackList &callbacks = *it;
    //qDebug() << "Remove callback from queue" << callback;
    callbacks.remove(callback.toString()); //return removing callback
    m_cachequeue_lock.unlock();
}

bool Cache::queueCacheUpdate(QVariant url, QVariant callback) {
    bool fresh = false;
    //qDebug() << "Adding callback to queue" << callback << url;
    m_cachequeue_lock.lockForWrite();
    CCacheQueue::iterator it;
    it = m_cachequeue.find(url.toString());
    if (it == m_cachequeue.end()) {
        m_cachequeue.insert(url.toString(),CCallbackList());
        it = m_cachequeue.find(url.toString());
        fresh = true;
    };
    it->insert(callback.toString());
    m_cachequeue_lock.unlock();
    return fresh;
}

void Cache::makeCallbackAll(bool status, QVariant url)
{
    //qDebug() << "make all callback" << url;
    CCacheQueue::iterator it;
    m_cachequeue_lock.lockForRead();
    it = m_cachequeue.find(url.toString());
    if (it == m_cachequeue.end()) {
        m_cachequeue_lock.unlock();
        return;
    }
    QString namelocal = makeCachedURL(url.toString());
    CCallbackList callbacks = *it; //Make a copy of list
    m_cachequeue_lock.unlock();
    m_cachequeue_lock.lockForWrite();
    m_cachequeue.remove(url.toString());
    m_cachequeue_lock.unlock();

    //Make callbacks
    CCallbackList::iterator itc = callbacks.begin();
    while(itc!=callbacks.end()) {
        makeCallback(*itc,status,namelocal);
        itc++;
    }
}

void Cache::makeCallback(QVariant callback, bool status, QVariant url)
{
    //qDebug() << "makecallback: " << callback;
    emit cacheUpdated(/*QVariant::fromValue(*/callback/*)*/, QVariant(status), url);
}

QVariant Cache::info()
{
    QDateTime today;
    today = QDateTime::currentDateTime();
    qint64 total = 0;
    QDir dir(m_path);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
            total += list.at(i).size();
    }

    double result = double(total) / 1000000;
    return QVariant(QString("%1 MB").arg(result,0,'g',3));
}

QVariant Cache::reset()
{
    m_cachemap.clear();

    QDir dir(m_path);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
        QFile(list.at(i).absoluteFilePath()).remove();
    }

    return QVariant(true);
}
