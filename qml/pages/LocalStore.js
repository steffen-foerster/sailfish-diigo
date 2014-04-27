/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

I used some ideas of the file
https://github.com/tworaz/sailfish-ytplayer/pages/Settings.js
from Peter Tworek for the below JavaScript.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

.pragma library

.import QtQuick.LocalStorage 2.0 as Sql

var private = {
    getDatabase : function() {
        return Sql.LocalStorage.openDatabaseSync("Bookmark", "1.0", "Database of application Bookmark", 100000);
    }
}

// ------------------------------------------------------------
// Initialize
// ------------------------------------------------------------

function initializeDatabase(defaultSettings) {
    var db = private.getDatabase();
    db.transaction(function(tx) {
        initializeSettings(defaultSettings, tx);
        //initializeSearchStore(tx);
        initializeVersion(tx);
    });
}

function initializeSettings(defaultSettings, tx) {
    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(service INTEGER, key TEXT, value TEXT, PRIMARY KEY (service, key))');
    for (var i = 0; i < defaultSettings.length; i++) {
        var serviceSettings = defaultSettings[i];
        for (var key in serviceSettings.values) {
            tx.executeSql('INSERT OR IGNORE INTO settings (service, key, value) VALUES (?, ?, ?);',
                          [serviceSettings.service, key, serviceSettings.values[key]]);
        }
    }
    console.debug("Table SETTINGS initialized");
}

function initializeSearchStore(tx) {
    tx.executeSql('CREATE TABLE IF NOT EXISTS search(' +
                  '  name TEXT PRIMARY KEY,' +
                  '  tags TEXT,' +
                  '  list TEXT,' +
                  '  filter INTEGER,' +
                  '  sort INTEGER,' +
                  '  max_rows INTEGER,' +
                  '  user TEXT)');
    console.debug("Table SEARCH initialized");
}

function initializeVersion(tx) {
    tx.executeSql('CREATE TABLE IF NOT EXISTS migration(version INTEGER PRIMARY KEY)');
    tx.executeSql('INSERT OR IGNORE INTO migration (version) VALUES (?);', [1]);
    console.debug("Table MIGRATION initialized");
}

// ------------------------------------------------------------
// Settings
// ------------------------------------------------------------

function set(service, key, value) {
    console.debug("saving setting " + key + ", service: " + service);
    var db = private.getDatabase();
    db.transaction(function (tx) {
        tx.executeSql('INSERT OR REPLACE INTO settings VALUES(?, ?, ?);', [service, key, value]);
    });
}

function get(service, key) {
    var db = private.getDatabase();
    var retval = undefined;
    db.transaction(function (tx) {
        var res = tx.executeSql('SELECT value FROM settings WHERE service = ? AND key = ?;', [service, key]);
        if (res.rows.length > 0) {
            retval = res.rows.item(0).value;
        } else {
            console.warn("key ", key, " for service ", service, " not found!");
            retval = undefined;
        }
    });
    return retval;
}

// ------------------------------------------------------------
// Search
// ------------------------------------------------------------

function saveSearch(name, criteria) {
    var db = private.getDatabase();
    db.transaction(function (tx) {
        var res = tx.executeSql('DELETE FROM search WHERE LOWER(name) = ?;', [name.toLowerCase()]);
        if (res.rowsAffected > 0) {
            console.log("Existed search criteria deleted");
        }

        tx.executeSql('INSERT OR REPLACE INTO search' +
                      '  (name, tags, list, filter, sort, max_rows, user) VALUES(?, ?, ?, ?, ?, ?, ?);',
                      [name, criteria.tags, criteria.list, criteria.filter, criteria.sort, criteria.max_rows, criteria.user]);
    });
}

function getSavedSearches() {
    var db = private.getDatabase();
    var retval = [];
    db.transaction(function (tx) {
        var res = tx.executeSql('SELECT * FROM search ORDER BY name');
        if (res.rows.length > 0) {
            for (var i = 0; i < res.rows.length; i++) {
                retval.push({
                                name: res.rows.item(i).name,
                                tags: res.rows.item(i).tags,
                                list: res.rows.item(i).list,
                                filter: res.rows.item(i).filter,
                                sort: res.rows.item(i).sort,
                                max_rows: res.rows.item(i).max_rows,
                                user: res.rows.item(i).user
                            });
            }
        }
    });
    return retval;
}
