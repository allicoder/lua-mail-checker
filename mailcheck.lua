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

-- need a path manip library
-- think there's one here:
-- https://github.com/moteus/lua-path
-- but in the meantime, let's just use this
local PATH_SEP = "/"
local function path_join(cpt_list)
  return table.concat(cpt_list, PATH_SEP)
end
-- test it
assert(path_join({"one", "two"}) == "one/two")
assert(path_join({"", "one"}) == "/one")

local function checkUnderFolder(folder_to_check,
  look_for_mailboxes = true, look_for_new_mail = true)
  -- list of the folders we've found that contain entries "new", "cur" and "tmp"
  -- (which we interpret as a Maildir mailbox).
  -- This will also contain lists of mail found, in the form
  -- {
  --   {mailbox, {mail1, mail2}},
  --   ...
  -- }
  found_mail = {}
  num_found_mailboxes = 0

  -- Go through each listed mailbox
  -- We're looping like this so we can add elements to the 'end' of the table.
  i = 1
  while nil ~= folder_to_check[i] do
    has_new = false
    has_cur = false
    has_tmp = false

    -- Check for interesting dir entries
    for ent in lfs.dir(folder_to_check[i]) do
      if "." ~= ent and ".." ~= ent then
        if "new" == ent then
          has_new = true
        elseif "tmp" == ent then
          has_tmp = true
        elseif "cur" == ent then
          has_cur = true
        elseif "directory" == lfs.attributes(
          path_join({folder_to_check[i], ent}), "mode") then
          -- recurse
          table.insert(folder_to_check, path_join({folder_to_check[i], ent}))
        end
      end
    end

    if has_new and has_tmp and has_cur then
      table.insert(found_mail, {name = folder_to_check[i], new_mail = {}})
    end
    i = i + 1 -- y u no incremeent :(
  end

  -- TODO perhaps should cache the list of mailboxes?

  for _, mailbox in pairs(found_mail) do
    mailbox_dir = path_join({mailbox.name, "new"})
    for ent in lfs.dir(mailbox_dir) do
      -- if not directory also excludes . and .. if present.
      if "directory" ~= lfs.attributes(path_join({mailbox_dir, ent}), "mode")
      then
        -- add all new mails to the table
        table.insert(mailbox.new_mail, ent)
      end
    end
  end

  return found_mail
end

local function findMailboxesUnder(folder)
  return checkUnderFolder(folder, true, false)
end

local function scanForNewMailIn(folder)
  return checkUnderFolder(folder, false, true)
end

local function scanAllUnder(folder)
  return checkUnderFolder(folder, true, true)
end

return {
  findMailboxesUnder = findMailboxesUnder,
  scanForNewMailIn   = scanForNewMailIn,
  scanAllUnder       = scanAllUnder,
}

