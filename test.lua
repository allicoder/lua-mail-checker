#!/usr/bin/env lua

--[[
-- lua-mail-checker - Email checker for maildir using lua, suitable for
-- integration into awesome WM.
-- Copyright (C) 2015 allicoder
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software Foundation; either version 2 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-- more details.
--
-- You should have received a copy of the GNU General Public License along with
-- this program; if not, write to the Free Software Foundation, Inc., 51
-- Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--
-- --
--
-- Like you're gonna wanna copy it anyway, but eh. It's the idea of the thing.
--]]

lfs       = require("lfs")
mailcheck = require("mailcheck")

-- folders to check
-- this needs to have consecutive integer keys
to_check = {}

if #arg < 1 then
  error("No folders given!")
end

for _, folder in ipairs(arg) do
  table.insert(to_check, folder)
end

found_mail = mailcheck.scanAllUnder(to_check)

for _, mailbox in pairs(found_mail) do
  num_new = #mailbox.new_mail -- this works because we've been careful with
                              -- our list indexing.
  if 0 ~= num_new then
    print(num_new .. " new messages in " .. mailbox.name)
  end
end
