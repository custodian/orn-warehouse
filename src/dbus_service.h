#ifndef DBUS_SERVICE_H
#define DBUS_SERVICE_H

#include <QtDBus/QDBusAbstractAdaptor>

class QApplication;
class QDeclarativeView;

class DBusService : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.thecust.warehouse")
public:
    explicit DBusService(QApplication *parent, QDeclarativeView *view);

public slots:
    void notification(QString identificator);
    void loadURI(const QStringList &url);
    Q_SCRIPTABLE void showApplication();

signals:
    void processUINotification(QVariant id);
    void processURI(QVariant url);

private:
    QDeclarativeView *m_view;
};

#endif // DBUS_SERVICE_H
