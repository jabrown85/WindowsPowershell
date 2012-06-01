@echo off
rem Batch file to start Vim with less.vim.
rem Read stdin if no arguments were given.
rem Based upon less.sh from the Vim distribution.
rem Version: 1.0
rem Author:  Erik Falor <ewfalor@gmail.com>

IF !%1==! (vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -) ELSE (vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" %*)
