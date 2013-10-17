#include <QDebug>
#include <QObject>
#include <QVariant>
#include <QThreadPool>

#include "qmlthreadworker.h"

void WorkerTask::run() {
       m_worker->processAction(m_payload);
}

QmlThreadWorker::QmlThreadWorker(QObject * parent):
    QObject(parent) {
    m_pool.setMaxThreadCount(1);
    m_object = NULL;
}

void QmlThreadWorker::setCallObject(QObject *object) {
    m_object = object;
}

void QmlThreadWorker::queueAction(QVariant msg) {
    m_pool.start(new WorkerTask(this,msg));
}

void QmlThreadWorker::processAction(QVariant msg) {
    if (m_object!=NULL) {
        QMetaObject::invokeMethod(m_object, "processAction", Qt::DirectConnection,
                Q_ARG(QVariant, msg));
    } else {
        QMetaObject::invokeMethod(this, "actionDone", Qt::DirectConnection,
                Q_ARG(QVariant, msg));
    }
}
