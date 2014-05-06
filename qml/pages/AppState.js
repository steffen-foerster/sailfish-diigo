/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

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

// States
var S_START = "s_start";
var S_SETTINGS = "s_settings";
var S_ADD = "s_add";
var S_EDIT = "s_edit";
var S_SEARCH = "s_search";
var S_SHARE = "s_share";
var S_ADD_WAIT_SERVICE = "s_add_wait_service";
var S_SEARCH_WAIT_SERVICE = "s_search_wait_service";
var S_VIEW_BOOKMARK = "s_view_bookmark";

// Transitions
var T_MAIN_START = "t_main_start";
var T_CHANGE_SERVICE = "t_change_service";
var T_SERVICE_START = "t_service_start";
var T_START_SETTINGS = "t_start_settings";
var T_START_ADD = "t_start_add";
var T_START_SEARCH = "t_start_search";
var T_SETTINGS_ACCEPTED = "t_settings_accepted";
var T_SETTINGS_REJECTED = "t_settings_rejected";
var T_ADD_REJECTED = "t_add_rejected";
var T_ADD_ACCEPTED = "t_add_accepted";
var T_EDIT_REJECTED = "t_edit_rejected";
var T_EDIT_ACCEPTED = "t_edit_accepted";
var T_ADD_SERVICE_RESULT_RECIEVED = "t_add_service_result_recieved";
var T_SEARCH_SERVICE_RESULT_RECIEVED = "t_search_service_result_recieved";
var T_SEARCH_REJECTED = "t_search_rejected";
var T_SEARCH_ACCEPTED = "t_search_accepted";
var T_VIEW_BOOKMARK_START = "t_view_bookmark_start";
