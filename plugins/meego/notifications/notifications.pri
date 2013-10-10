noticons.files = \
    $$PWD/icon-m-service-warehouse-notification.png \
    $$PWD/icon-m-low-power-mode-warehouse-notification.png \
    $$PWD/icon-s-status-notifier-warehouse-notification.png \
    $$PWD/icon-s-status-warehouse-notification.png
noticons.path = /usr/share/themes/blanco/meegotouch/icons

eventtype.files = $$PWD/warehouse.notification.conf
eventtype.path = /usr/share/meegotouch/notifications/eventtypes

INSTALLS += noticons eventtype
