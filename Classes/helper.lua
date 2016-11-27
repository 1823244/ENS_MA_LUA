Helper = class(function(acc)
end)
function Helper:Init()
end
function Helper:LoadFromFile(fileName)
  file = io.open(fileName, "r")
  if file ~= nil then
    value = file:read()
    file:close()
    if value ~= nil then
      return value
    end
  end
  return ""
end
function Helper:printTable(tbl, fileName)
  for k, v in pairs(tbl) do
    self:AppendInFile(fileName, k .. " " .. v)
  end
end
function Helper:writeInFile(fileName, text)
  file = io.open(fileName, "w+t")
  if file ~= nil then
    file:write(text)
    file:close()
  end
end
function Helper:AppendInFile(fileName, text)
  file = io.open(fileName, "a")
  if file ~= nil then
    file:write(text)
    file:close()
  end
end
function Helper:getValueFromTable2(table_name, key1, value1, key2, value2, key3)
  local i
  for i = getNumberOf(table_name), 0, -1 do
    if getItem(table_name, i)[key1] ~= nil and tostring(getItem(table_name, i)[key1]) == tostring(value1) and tostring(getItem(table_name, i)[key2]) == tostring(value2) then
      return getItem(table_name, i)[key3]
    end
  end
  return nil
end
function Helper:InsertDot(str)
  return string.gsub(str, ",", ".")
end
function Helper:checkNill(value)
  if value == nil then
    logMemo:Add("No data!")
    return true
  end
  return false
end
function Helper:getHRTime()
  local now = os.clock()
  return string.format("%s,%3d", os.date("%X", now), select(2, math.modf(now)) * 1000)
end
function Helper:getMiliSeconds()
  local now = os.clock()
  return string.format("%s,%3d", os.date("%X", now), select(2, math.modf(now)) * 1000)
end
function Helper:getHRTime2()
  hour = tostring(os.date("*t").hour)
  minute = tostring(os.date("*t").min)
  second = tostring(os.date("*t").sec)
  if tonumber(hour) < 10 then
    hour = "0" .. hour
  end
  if tonumber(minute) < 10 then
    minute = "0" .. minute
  end
  if tonumber(second) < 10 then
    second = "0" .. second
  end
  return hour .. ":" .. minute .. ":" .. second
end
function Helper:getHRTime3(seconds)
  hour = os.date("*t").hour
  minute = os.date("*t").min
  sec = os.date("*t").sec + seconds
  if sec > 59 then
    minute = minute + 1
    sec = sec - 60
    if minute > 59 then
      hour = hour + 1
      minute = minute - 60
    end
  end
  return hour * 10000 + minute * 100 + sec
end
function Helper:getHRTime4()
  hour = tostring(os.date("*t").hour)
  minute = tostring(os.date("*t").min)
  second = tostring(os.date("*t").sec)
  return hour * 10000 + minute * 100 + second
end
function Helper:round(num, idp)
  local mult = 10 ^ (idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
