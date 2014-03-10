TEMPLATE = app
TARGET = warehouse

VERSION = 0.1
PACKAGENAME = com.thecust.warehouse

QT += network
#CONFIG +=

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

contains(MEEGO_EDITION,harmattan){
    DEFINES += Q_OS_HARMATTAN
    QT += dbus
    CONFIG += qdeclarative-boostable meegotouch
    CONFIG += mobility meegotouchevents
    MOBILITY += feedback
    include(plugins/meego/notifications/notifications.pri)
    include(plugins/meego/uri-scheme/uri-scheme.pri)
    include(plugins/meego/source-policy/source-policy.pri)
}
maemo5 {
    DEFINES += Q_OS_MAEMO
    CONFIG += mobility12 qdbus
    include(plugins/maemo/uri-scheme/uri-scheme.pri)
}
win32 {
    # Define QMLJSDEBUGGER to allow debugging of QML in debug builds
    # (This might significantly increase build time)
    QMLJSDEBUGGER_PATH = C:\QtSDK\QtCreator\share\qtcreator\qml\qmljsdebugger
    DEFINES += QMLJSDEBUGGER
}

INCLUDEPATH += $PWD/src

HEADERS += \
    src/apptranslator.h \
    src/packagemanager.h \
    src/qmlthreadworker.h \
    src/cache.h

SOURCES += src/main.cpp \
    src/apptranslator.cpp \
    src/packagemanager.cpp \
    src/qmlthreadworker.cpp \
    src/cache.cpp

!simulator {
    HEADERS += src/dbus_service.h
    SOURCES += src/dbus_service.cpp
}

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qtc_packaging/debian_harmattan/postinst \
    qtc_packaging/debian_harmattan/postrm

OTHER_FILES += \
    warehouse_maemo.desktop \
    warehouse_meego.desktop \
    qml-harmattan/*

#translations settings
lupdate_only {
    SOURCES = qml-harmattan/main.qml \
        qml-harmattan/components/*.qml \
        qml-harmattan/pages/*.qml \
        qml-harmattan/js/*.js
}

####################DEPLOYMENT SETTINGS###################
include(src/qmlapplicationviewer/qmlapplicationviewer.pri)

maemo5 {
    qmlresources.source = $$PWD/qml-harmattan
    qmli18n.source = $$PWD/i18n/*.qm
} else {
    qmlresources.source = qml-harmattan
    qmli18n.source = i18n/*.qm
}
qmlresources.target = .
qmli18n.target = i18n
DEPLOYMENTFOLDERS += qmlresources qmli18n

!simulator {
    openreposkey.source = $$PWD/openrepos.key
    openreposkey.target = .
    DEPLOYMENTFOLDERS += openreposkey
}

#deploy targets
qtcAddDeployment()
