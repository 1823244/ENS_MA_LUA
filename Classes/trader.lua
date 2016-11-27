Trader = class(function(acc)
end)
function Trader:Init(path)
  self.classes = {}
  self.codes = {}
  self.clients = {}
  self.Path = ""
  self:GetClasses()
  self:GetCodes()
  self:GetClients()
  place = 0
  for i = 0, string.len(path) - 1 do
    ch = string.sub(path, i, i)
    if ch == "\\" then
      place = i
    end
  end
  self.Path = string.sub(path, 0, place)
end
function Trader:GetClasses()
  list = getClassesList()
  len = string.len(list)
  predPos = 0
  j = 0
  for i = 0, len - 1 do
    if string.sub(list, i, i) == "," then
      self.classes[j] = string.sub(list, predPos, i - 1)
      j = j + 1
      predPos = i + 1
    end
  end
end
function Trader:GetCodes()
  for i, v in ipairs(self.classes) do
    list = getClassSecurities(v)
    len = string.len(list)
    predPos = 0
    j = 0
    for i = 0, len - 1 do
      if string.sub(list, i, i) == "," and string.len(string.sub(list, predPos, i - 1)) < 6 then
        self.codes[j] = string.sub(list, predPos, i - 1)
        j = j + 1
        predPos = i + 1
      end
    end
  end
end
function Trader:GetClients()
  n = getNumberOf("client_codes")
  j = 0
  for i = 0, n - 1 do
    self.clients[j] = getItem("client_codes", i)
    j = j + 1
  end
  return clients
end
function Trader:GetClassByCode(code)
  for i, v in ipairs(self.classes) do
    list = getClassSecurities(v)
    len = string.len(list)
    predPos = 0
    for i = 0, len - 1 do
      if string.sub(list, i, i) == "," then
        if string.sub(list, predPos, i - 1) == code and v ~= "FUTEVN" then
          return v
        end
        predPos = i + 1
      end
    end
  end
  return ""
end
function Trader:GetCurrentPosition(code, client)
  curPosition = 0
  curPosition = self:getValueFromTable2("futures_client_holding", "sec_code", code, "trdaccid", client, "totalnet")
  if curPosition == nil then
    curPosition = self:getValueFromTable2("depo_limits", "sec_code", code, "client_code", client, "currentbal")
  end
  if curPosition == nil then
    curPosition = 0
  end
  return curPosition
end
function Trader:GetMoneyAmount(client)
  firmId = self:GetFirm(client)
  amount = 0
  if firmId ~= "" and firmId ~= 0 and firmId ~= "0" and firmId ~= nil and getPortfolioInfoEx(tostring(firmId), tostring(client), 2) ~= nil then
    amount = getPortfolioInfoEx(tostring(firmId), tostring(client), 2).all_assets
  end
  if amount == 0 then
    for i = getNumberOf("futures_client_limits"), 0, -1 do
      if getItem(table_name, i) ~= nil and getItem(table_name, i).trdaccid ~= nil and tostring(getItem(table_name, i).trdaccid) == tostring(client) then
        amount = tonumber(getItem(table_name, i).cbplplanned) + tonumber(getItem(table_name, i).varmargin) + tonumber(getItem(table_name, i).cbplimit)
      end
    end
  end
  return amount
end
function Trader:GetPriceByOrderNumber(number)
  for i = getNumberOf("trades"), 0, -1 do
    if getItem("trades", i) ~= nil and getItem("trades", i).order_num ~= nil and tostring(getItem("trades", i).order_num) == tostring(number) then
      return tonumber(getItem("trades", i).price)
    end
  end
  return 0
end
function Trader:GetFortsProfit(client)
  amount = 0
  table_name = "futures_client_limits"
  for i = getNumberOf(table_name), 0, -1 do
    if getItem(table_name, i) ~= nil and getItem(table_name, i).trdaccid ~= nil and tostring(getItem(table_name, i).trdaccid) == tostring(client) then
      amount = tonumber(getItem(table_name, i).varmargin)
    end
  end
  return amount
end
function Trader:GetProfit(client)
  firmId = self:GetFirm(client)
  amount = 0
  if firmId ~= "" and firmId ~= 0 and firmId ~= "0" and firmId ~= nil and getPortfolioInfoEx(tostring(firmId), tostring(client), 2) ~= nil then
    amount = getPortfolioInfoEx(tostring(firmId), tostring(client), 2).profit_loss
  end
  amount = 0
  table_name = "futures_client_limits"
  if amount == 0 then
    for i = getNumberOf(table_name), 0, -1 do
      if getItem(table_name, i) ~= nil and getItem(table_name, i).trdaccid ~= nil and tostring(getItem(table_name, i).trdaccid) == tostring(client) then
        amount = tonumber(getItem(table_name, i).varmargin)
      end
    end
  end
  return amount
end
function Trader:GetFirm(client)
  n = getNumberOf("money_limits")
  limit = {}
  for i = 0, n - 1 do
    limit = getItem("money_limits", i)
    if limit.order_num == client_code then
      return limit.firmid
    end
  end
  return ""
end
function Trader:getValueFromTable2(table_name, key1, value1, key2, value2, key3)
  local i
  for i = getNumberOf(table_name), 0, -1 do
    if getItem(table_name, i) ~= nil and getItem(table_name, i)[key1] ~= nil and tostring(getItem(table_name, i)[key1]) == tostring(value1) and tostring(getItem(table_name, i)[key2]) == tostring(value2) then
      return getItem(table_name, i)[key3]
    end
  end
  return nil
end
function Trader:GetTimeFromTrade(trade)
  hour = trade.datetime.hour
  minute = trade.datetime.min
  sec = trade.datetime.sec
  mili = trade.datetime.ms
  hourStr = AddZero(hour)
  minuteStr = AddZero(minute)
  secStr = AddZero(sec)
  miliStr = AddZero(mili)
  return hourStr .. ":" .. minuteStr .. ":" .. secStr .. "," .. miliStr
end
function Trader:findEnterPriceByClient(code, client)
  trade = {}
  orderPrice = 0
  for i = getNumberOf("trades") - 1, 0, -1 do
    trade = getItem("trades", i)
    if orderPrice == 0 and trade ~= nil and trade.price ~= nil and trade.seccode ~= nil and tostring(trade.seccode) == code and tostring(trade.client_code) == client then
      orderPrice = tonumber(trade.price)
    end
  end
  return orderPrice
end
function Trader:findEnterPrice(code)
  trade = {}
  orderPrice = 0
  for i = getNumberOf("trades") - 1, 0, -1 do
    trade = getItem("trades", i)
    if orderPrice == 0 and trade ~= nil and trade.price ~= nil and trade.seccode ~= nil and tostring(trade.seccode) == code then
      orderPrice = tonumber(trade.price)
    end
  end
  return orderPrice
end
function Trader:GetPath(path)
  place = 0
  for i = 0, string.len(path) - 1 do
    ch = string.sub(path, i, i)
    if ch == "\\" then
      place = i
    end
  end
  self.Path = string.sub(path, 0, place)
  return self.Path
end
