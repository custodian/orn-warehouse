TEMPLATE = app

TARGET = harbour-warehouse
target.path = $$INSTALL_ROOT/usr/bin

QT += network dbus quick qml

CONFIG += link_pkgconfig
PKGCONFIG += packagekit-qt5

PKGCONFIG += sailfishapp
INCLUDEPATH += /usr/include/sailfishapp

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS
DEFINES += Q_OS_SAILFISH

packagesExist(sailfishapp) {
#special cases?
}

####################DEPLOYMENT SETTINGS###################
qml.files = qml/sailfish/*
qml.path = $$INSTALL_ROOT/usr/share/harbour-warehouse/qml

js.files = qml/js
js.path = $$INSTALL_ROOT/usr/share/harbour-warehouse/qml

desktop.files = harbour-warehouse.desktop
desktop.path = $$INSTALL_ROOT/usr/share/applications

icon.files = harbour-warehouse.png
icon.path = $$INSTALL_ROOT/usr/share/icons/hicolor/86x86/apps

#dbus.files = dbus/net.thecust.harbour_warehouse.service
#dbus.path = /usr/share/dbus-1/services

zypp.files = rpm/openrepos.enabled
zypp.path = $$INSTALL_ROOT/etc/zypp/repos.d

polkit.files = rpm/50-net.openrepos.warehouse-packagekit.pkla
polkit.path = $$INSTALL_ROOT/var/lib/polkit-1/localauthority/50-local.d

INSTALLS = zypp target qml js desktop icon polkit #dbus

INCLUDEPATH += $PWD/src

HEADERS += \
    src/apptranslator.h \
    src/packagekitproxy.h \
    src/qmlthreadworker.h \
    src/cache.h

SOURCES += src/main.cpp \
    src/apptranslator.cpp \
    src/packagekitproxy.cpp \
    src/qmlthreadworker.cpp \
    src/cache.cpp

#dbus
#HEADERS += src/dbus_service.h
#SOURCES += src/dbus_service.cpp

OTHER_FILES += \
    rpm/harbour-warehouse.spec \
    rpm/harbour-warehouse.yaml \
    rpm/harbour-warehouse.changes \
    rpm/openrepos.enabled

OTHER_FILES += \
    harbour-warehouse.desktop \
    qml/sailfish/main-sailfish.qml \
    qml/sailfish/components/*.qml \
    qml/sailfish/pages/*.qml \
    qml/js/*.js

############## translations settings ##################
lupdate_only {
    SOURCES = qml/sailfish/main-sailfish.qml \
        qml/sailfish/components/*.qml \
        qml/sailfish/pages/*.qml \
        qml/js/*.js
}

#for qtcreator
INCLUDEPATH += $$[QT_HOST_PREFIX]/include/PackageKit
