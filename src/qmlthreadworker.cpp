#include <QObject>
#include <QVariant>
#include <QThreadPool>

#include "qmlthreadworker.h"

void WorkerTask::run() {
       m_worker->processAction(payload);
}

QmlThreadWorker::QmlThreadWorker(QObject * parent):
    QObject(parent) {
    m_component = NULL;
}

void QmlThreadWorker::queueAction(QVariant msg) {
    QThreadPool::globalInstance()->start(new WorkerTask(this,msg));
}

void QmlThreadWorker::processAction(QVariant msg) {

}
