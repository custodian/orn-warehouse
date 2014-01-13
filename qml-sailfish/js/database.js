.pragma library

var QUERY = {
    SETTINGS_TABLE_CREATE: 'CREATE TABLE Settings(setting TEXT UNIQUE, value TEXT);',
}

var db = openDatabaseSync("Warehouse", "", "Warehouse Database", 1000000, function(db) {
    db.changeVersion(db.version, "1.0", function(tx) {
        tx.executeSql(QUERY.SETTINGS_TABLE_CREATE);
    });
});

function setSetting(settings) {
    db.transaction(function(tx) {
        for (var s in settings) {
            tx.executeSql('INSERT OR REPLACE INTO Settings VALUES(?,?);', [s, settings[s]]);
        }
    });
}

function getSetting(setting) {
    var res = "";
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM Settings WHERE setting=?;', [setting])
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        }
    })
    return res;
}

function getAllSettings() {
    var res = {};
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM Settings;');
        for (var i=0; i<rs.rows.length; i++) {
            res[rs.rows.item(i).setting] = rs.rows.item(i).value;
        }
    })
    return res;
}


function clearTable(tableName) {
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM ' + tableName);
    });
}

function dropTable(tableName) {
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE ' + tableName);
    });
}

function resetSettings() {
    clearTable("settings");
}
