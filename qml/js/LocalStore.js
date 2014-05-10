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

.import "Utils.js" as Utils
.import "Bookmark.js" as Bookmark
.import "../services/Services.js" as Services

var private = {
    getDatabase : function() {
        return Sql.LocalStorage.openDatabaseSync("Bookmark", "1.0", "Database of application Bookmark", 1000000);
    }
}

// ------------------------------------------------------------
// Initialize
// ------------------------------------------------------------

function initializeDatabase(defaultSettings) {
    console.log("initializing database");
    var db = private.getDatabase();
    db.transaction(function(tx) {
        initializeSettings(defaultSettings, tx);
        //initializeSearchStore(tx);
        initializeVersion(tx);
        // database migration
        migrateToVersion2(tx);
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

function migrateToVersion2(tx) {
    var res = tx.executeSql('SELECT MAX(version) max_version FROM migration;');
    if (res.rows.item(0).max_version === 1) {
        tx.executeSql('DROP TABLE pinboard_post IF EXISTS');
        console.debug("Dropped table PINBOARD_POST");

        tx.executeSql('CREATE TABLE IF NOT EXISTS bookmark(' +
                      '  service INTEGER,' +
                      '  href TEXT,' +
                      '  tags TEXT,' +
                      '  title TEXT,' +
                      '  desc TEXT,' +
                      '  shared TEXT,' +
                      '  toread TEXT,' +
                      '  time TEXT,' +
                      '  PRIMARY KEY (service, href))');
        console.debug("Table BOOKMARK initialized");

        tx.executeSql('INSERT OR IGNORE INTO migration (version) VALUES (?);', [2]);
        console.debug("Version 2 saved into table MIGRATION");
    }
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
// BOOKMARK
// ------------------------------------------------------------

function savePinboardBookmarks(bookmarks) {
    console.log("Saving PINBOARD bookmarks ...");
    var db = private.getDatabase();
    db.transaction(function (tx) {
        var res = tx.executeSql('DELETE FROM bookmark WHERE service = ?;', [Services.PINBOARD]);
        console.log("Deleted posts: ", res.rowsAffected);
        if (bookmarks) {
            for (var i = 0; i < bookmarks.length; i++) {
                var b = bookmarks[i];
                tx.executeSql('INSERT OR REPLACE INTO bookmark' +
                              '  (service, href, title, desc, time, shared, toread, tags) VALUES(?, ?, ?, ?, ?, ?, ?, ?);',
                              [Services.PINBOARD, b.href, b.description, b.extended, b.time, b.shared, b.toread, b.tags]);
            }
            console.log("Inserted PINBOARD bookmarks: " + bookmarks.length);
        }
        else {
            console.log("bookmarks is: ", bookmarks);
        }
    });
}

function saveDiigoBookmarks(bookmarks) {
    console.log("Saving DIIGO bookmarks ...");
    var db = private.getDatabase();
    db.transaction(function (tx) {
        var res = tx.executeSql('DELETE FROM bookmark WHERE service = ?;', [Services.DIIGO]);
        console.log("Deleted bookmarks: ", res.rowsAffected);
        if (bookmarks) {
            for (var i = 0; i < bookmarks.length; i++) {
                var b = bookmarks[i];
                tx.executeSql('INSERT OR REPLACE INTO bookmark' +
                              '  (service, href, title, desc, time, shared, toread, tags) VALUES(?, ?, ?, ?, ?, ?, ?, ?);',
                              [Services.DIIGO, b.href, b.title, b.desc, b.created_at, b.shared, b.toread,
                               Utils.commaToSpaceSeparated(b.tags)]);
            }
            console.log("Inserted DIIGO bookmarks: " + bookmarks.length);
        }
        else {
            console.log("bookmarks is: ", bookmarks);
        }
    });
}

// A bookmark with the same URL will be replaced.
function addOrUpdateBookmark(bookmark, service) {
    var db = private.getDatabase();
    db.transaction(function (tx) {
        var time = bookmark.time ? bookmark.time : new Date().toISOString()
        tx.executeSql('INSERT OR REPLACE INTO bookmark' +
                      '  (service, href, title, desc, shared, toread, tags, time) VALUES(?, ?, ?, ?, ?, ?, ?, ?);',
                      [service, bookmark.href, bookmark.title, bookmark.desc, bookmark.shared, bookmark.toread, bookmark.tags, time]);

    });
}

function deleteBookmark(href, service) {
    var db = private.getDatabase();
    db.transaction(function (tx) {
        var res = tx.executeSql('DELETE FROM bookmark WHERE href = ? AND service = ?;', [href, service]);
        console.log("Deleted bookmarks: ", res.rowsAffected);
    });
}

function fetchRecentBookmarks(count, service) {
    var db = private.getDatabase();
    var retval = [];
    db.transaction(function (tx) {
        var res = tx.executeSql('SELECT * FROM bookmark WHERE service = ? ORDER BY time DESC LIMIT ?;', [service, count]);
        retval = createBookmarks(res);
    });
    return retval;
}

function searchBookmarks(criteria, service) {
    var db = private.getDatabase();
    var retval = [];
    db.transaction(function (tx) {
        var res = tx.executeSql(createSearchQuery(criteria, service));
        retval = createBookmarks(res);
    });
    return retval;
}

function createBookmarks(resultSet) {
    var retval = [];
    for (var i = 0; i < resultSet.rows.length; i++) {
        var bookmark = Bookmark.create(
            resultSet.rows.item(i).href,
            resultSet.rows.item(i).title,
            resultSet.rows.item(i).desc,
            resultSet.rows.item(i).tags,
            resultSet.rows.item(i).shared,
            resultSet.rows.item(i).toread,
            resultSet.rows.item(i).time
        );
        retval.push(bookmark);
    }
    return retval;
}

function createSearchQuery(criteria, service) {
    var query = "SELECT * FROM bookmark";
    var where = "service = " + service;

    console.log("description: ", criteria.description, " where: ", where);
    if (criteria.description && criteria.description.trim().length > 0) {
        where = addCondition(where, "description LIKE '%" + criteria.description + "%'", "AND");
    }

    console.log("extended: ", criteria.extended, "where: ", where);
    if (criteria.extended && criteria.extended.trim().length > 0) {
        where = addCondition(where, "extended LIKE '%" + criteria.extended + "%'", "AND");
    }

    console.log("tags: ", criteria.tags, " where: ", where);
    if (criteria.tags && criteria.tags.trim().length > 0) {
        var tags = criteria.tags.split(" ");
        for (var i = 0; i < tags.length; i++) {
            where = addCondition(where, " tags LIKE '%" + tags[i].trim() + "%'", "AND");
        }
    }
    query += " WHERE " + where;
    query += " ORDER BY time DESC";
    query += " LIMIT " + criteria.count;

    console.log("query: " + query);
    return query;
}

function addCondition(where, condition, operator) {
    if (where.length > 0) {
        where += " " + operator + " ";
    }
    return where + condition;
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
