#!/bin/lua5.3
local inputB = io.open("input.txt")
local input = io.open("tmp.txt", "w+")
input:write(inputB:read("*a"):gsub("%\n\n", "\255"):gsub("%\n", " "):gsub("%\255", "\n"):gsub("%:", " "), " ")
input:close()
input = io.open("tmp.txt")

local line
local tmp
local tokens = {}
for line in input:lines() do
  tmp = ""
  line = line.." "
  local innerTokens = {}
  for char in string.gmatch(line, ".") do
    if char == " " then
      if tmp ~= "" then
        table.insert(innerTokens, string.lower(tmp))
        tmp = ""
        if char == "\n" then
          table.insert(tokens, "\n")
        end
      end
    else
      tmp = tmp..char
    end
  end
  table.insert(tokens, innerTokens)
end

local trueTokens = {
  byr = 1,
  iyr = 2,
  eyr = 4,
  hgt = 8,
  hcl = 16,
  ecl = 32,
  pid = 64,
  --cid = 128
}

local colors = {
  amb = 32,
  blu = 32,
  brn = 32,
  gry = 32,
  grn = 32,
  hzl = 32,
  oth = 32,
}

local hairColors = {}

setmetatable(trueTokens, {__index = function(tab, key)return 0 end})
setmetatable(colors, {__index = function(tab, key)return 0 end})
setmetatable(hairColors, {__index = function(tab, key)return 0 end})

--debug.sethook(function(event, line)
--  print(line)
--end, "l")

local hexLookup = {0,1,2,3,4,5,6,7,8,9,"A","B","C","D","E","F"}

function dec2hex(num)
  local tmp = ""
  local i = 0
  while i < 6 do
    tmp = tmp..tostring(hexLookup[num % 16 + 1])
    num = math.floor(num / 16)
    i = i + 1
  end
  return tmp
end

local validPassports = 0
local invalidPassports = 0
local wait = false
local mask = 0
local olMask = 0
for i, valueC in ipairs(tokens) do
  wait = false
  mask = 0
  local byr = false
  local iyr = false
  local eyr = false
  local hgt = false
  local hcl = false
  local ecl = false
  local pid = false
  
  --print(table.unpack(value))
  
  --for j, value in ipairs(valueC) do
  for i = 1, #valueC, 2 do
    --if wait == false then
    --  --print(i, value, mask, trueTokens[value])
    --  if trueTokens[value] ~= 0 then
    --    mask = bit32.bor(mask, trueTokens[value])
    --  end
    --  wait = true
    --else
      --tmp = valueC[j - 1]
      --value = valueC[j + 1]
      --print(tmp, value, j)
      local tmp, value = valueC[i], valueC[i + 1]
      if tmp == "byr" and (not byr) then
        if string.len(value) == 4 and tonumber(value) >= 1920 and tonumber(value) <= 2002 then
          mask = bit32.bor(mask, trueTokens.byr) --Set
          print("Byr valid!", mask)
        else
          mask = bit32.bor(bit32.bnot(mask), trueTokens.byr) --Clear
          mask = bit32.bnot(mask)
          print("Byr invalid!", mask)
        end
        byr = true
      end
      if tmp == "iyr" and (not iyr) then
        if string.len(value) == 4 and tonumber(value) >= 2010 and tonumber(value) <= 2020 then
          mask = bit32.bor(mask, trueTokens.iyr) --Set
          print("iyr valid!", mask)
        else
          mask = bit32.bor(bit32.bnot(mask), trueTokens.iyr) --Clear
          mask = bit32.bnot(mask)
          print("iyr invalid!", mask)
        end
        iyr = true
      end
      if tmp == "eyr" and (not eyr) then
        if string.len(value) == 4 and tonumber(value) >= 2020 and tonumber(value) <= 2030 then
          mask = bit32.bor(mask, trueTokens.eyr) --Set
          print("eyr valid!", mask)
        else
          mask = bit32.bor(bit32.bnot(mask), trueTokens.eyr) --Clear
          mask = bit32.bnot(mask)
          print("eyr invalid!", mask)
        end
        eyr = true
      end
      if tmp == "ecl" and (not ecl) then
        if colors[value] ~= 0 then
          mask = bit32.bor(mask, trueTokens.ecl)
          print("ecl valid!", mask)
        else
          mask = bit32.bor(bit32.bnot(mask), trueTokens.ecl) --Clear
          mask = bit32.bnot(mask)
          print("ecl invalid!", mask)
        end
        ecl = true
      end
      if tmp == "pid" and (not pid) then
        if string.len(value) == 9 and tonumber(value) ~= nil then
          mask = bit32.bor(mask, trueTokens.pid)
          print("pid valid!", mask)
        else
          mask = bit32.bor(bit32.bnot(mask), trueTokens.pid) --Clear
          mask = bit32.bnot(mask)
          print("pid invalid!", mask)
        end
        pid = true
      end
      if tmp == "hcl" and (not hcl) then
        if string.len(value) == 7 then
          if tonumber(value:gsub("#", ""), 16) == nil then
            mask = bit32.bor(bit32.bnot(mask), trueTokens.hcl) --Clear
            mask = bit32.bnot(mask)
          print("hcl invalid!", mask)
          else
            mask = bit32.bor(mask, trueTokens.hcl)
          print("hcl valid!", mask)
          end
        end
        hcl = true
      end
      if tmp == "hgt" and (not hgt) then
        local a, b = value:gsub("cm", "")
        if b == 1 then
          --a = a:gsub("m", "")
          if tonumber(a) ~= nil and (tonumber(a) >= 150 or tonumber(a) <= 193) then
            mask = bit32.bor(mask, trueTokens.hgt)
            print("hgt valid in cm!", mask, value, a, tonumber(a) ~= nil)
          else
            mask = bit32.bor(bit32.bnot(mask), trueTokens.hgt) --Clear
            mask = bit32.bnot(mask)
            print("hgt invalid in cm!", mask, value, a, tonumber(a) ~= nil)
          end
        else
          a, b = value:gsub("in", "")
          if b == 1 then
            --a = a:gsub("n", "")
            if tonumber(a) ~= nil and (tonumber(a) >= 59 or tonumber(a) <= 76) then
              mask = bit32.bor(mask, trueTokens.hgt)
              print("hgt valid in inch!", mask, value, a, tonumber(a) ~= nil)
            else
              mask = bit32.bor(bit32.bnot(mask), trueTokens.hgt) --Clear
              mask = bit32.bnot(mask)
              print("hgt invalid in inch!", mask, value, tonumber(a) ~= nil)
            end
          else
            mask = bit32.bor(bit32.bnot(mask), trueTokens.hgt) --Clear
            mask = bit32.bnot(mask)
            print("hgt invalid!", mask, value:gsub("i", ""),  value:gsub("c", ""))
          end
          hgt = true
        end
      end
      --wait = false
    --end
  end
  
  if mask == 1 + 2 + 4 + 8 + 16 + 32 + 64 then
    validPassports = validPassports + 1
    print("Passport valid!", mask, 1 + 2 + 4 + 8 + 16 + 32 + 64)
  else
    invalidPassports = invalidPassports + 1
    print("Passport invalid!", mask, 1 + 2 + 4 + 8 + 16 + 32 + 64)
  end
  print()
end

print("Valid passports: "..tostring(validPassports), "Invalid passports: "..tostring(invalidPassports))
