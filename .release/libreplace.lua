#!/usr/bin/env lua

local lfs = require('lfs')
local addon = lfs.currentdir():match('.+[\\/](.+)$')

local file = io.open('.libreplace', 'r')
local libs = file:read('*all')
file:close()

file = io.open(addon .. '.toc', 'r+')
local toc = file:read('*all')
file:seek('set')
file:write((toc:gsub('#@lib%-replace@', libs)))
file:close()

-- vim: set filetype=lua :