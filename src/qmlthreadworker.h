#ifndef QMLTHREADWORKER_H
#define QMLTHREADWORKER_H

#include <QObject>
#include <QVariant>
#include <QRunnable>
#include <QThreadPool>

class QmlThreadWorker;
class WorkerTask: public QRunnable
{
public:
    WorkerTask(QmlThreadWorker *worker,
               QVariant payload){
        m_worker = worker;
        m_payload = payload;
    }
    QmlThreadWorker *m_worker;
    QVariant m_payload;

    void run();
};

class QmlThreadWorker: public QObject
{
    Q_OBJECT
    friend class WorkerTask;
public:
    explicit QmlThreadWorker(QObject *parent = 0);
    void setCallObject(QObject *object);

public slots:
    void queueAction(QVariant msg);

protected:
    void processAction(QVariant msg);

private:
    QThreadPool m_pool;
    QObject * m_object;
};

#endif // QMLTHREADWORKER_H
