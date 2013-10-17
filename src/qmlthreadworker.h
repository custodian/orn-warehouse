#ifndef QMLTHREADWORKER_H
#define QMLTHREADWORKER_H

#include <QObject>
#include <QVariant>
#include <QRunnable>

class QmlThreadWorker;
class WorkerTask: public QRunnable
{
public:
    WorkerTask(QmlThreadWorker *worker,
               QVariant payload){
        m_worker = mgr;
        m_payload = payload;
    }
    QmlThreadWorker *m_worker;
    QVariant m_payload;

    void run();
};

class QmlThreadWorker: public QObject
{
    Q_OBJECT
public:
    explicit QmlThreadWorker(QObject *parent = 0);

    Q_INVOKABLE void setComponent(QObject *component);

public slots:
    void queueAction(QVariant msg);

private:
    QObject * m_component;
};

#endif // QMLTHREADWORKER_H
