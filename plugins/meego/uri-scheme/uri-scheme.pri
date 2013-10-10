#meego

#warehouse contentaction
contentaction.files = $$PWD/openrepos.xml
contentaction.path = /usr/share/contentaction
INSTALLS += contentaction

OTHER_FILES += $$PWD/openrepos.xml

#warehouse dbus service
service.files = $$PWD/com.thecust.warehouse.service
service.path = /usr/share/dbus-1/services
INSTALLS += service

OTHER_FILES += $$PWD/com.thecust.warehouse.service
