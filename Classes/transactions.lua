Transactions = class(function(acc)
end)
helper = {}
function Transactions:Init()
  helper = Helper()
  helper:Init()
  self.dateForStop = "0"
end
function Transactions:order(seccode, class, operation, client, depo, price, qty)
  transaction = {
    CLASSCODE = class,
    ACTION = "NEW_ORDER",
    ACCOUNT = depo,
    CLIENT_CODE = client,
    OPERATION = operation,
    SECCODE = seccode,
    PRICE = tostring(price),
    QUANTITY = tostring(qty),
    TRANS_ID = "1"
  }
  res = sendTransaction(transaction)
  if res ~= "" then
  --функция возвращает строку только в случае ошибки. Результат транзакции можно получить, воспользовавшись функцией обратного вызова OnTransReply.
	message("order sent. "..res, 1)
  end
end
function Transactions:orderWithId(seccode, class, operation, client, depo, price, qty, id)
  transaction = {
    CLASSCODE = class,
    ACTION = "NEW_ORDER",
    ACCOUNT = depo,
    CLIENT_CODE = client,
    OPERATION = operation,
    SECCODE = seccode,
    PRICE = tostring(price),
    QUANTITY = tostring(qty),
    TRANS_ID = tostring(id)
  }
  res = sendTransaction(transaction)
  message(res, 1)
end
function Transactions:StopPlusTakeProfit(client, depo, operation, price, stop_price, stopprice2, OFFSET, OFFSET_UNITS, SPREAD, SPREAD_UNITS, quantity, seccode, classcode, dateForSTop)
  transaction = {
    ACCOUNT = depo,
    CLIENT_CODE = client,
    ACTION = "NEW_STOP_ORDER",
    STOP_ORDER_KIND = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
    CLASSCODE = classcode,
    SECCODE = seccode,
    OPERATION = operation,
    QUANTITY = tostring(quantity),
    TYPE = "L",
    STOPPRICE2 = tostring(stopprice2),
    OFFSET = tostring(OFFSET),
    OFFSET_UNITS = OFFSET_UNITS,
    SPREAD = tostring(SPREAD),
    SPREAD_UNITS = SPREAD_UNITS,
    PRICE = tostring(price),
    STOPPRICE = tostring(stop_price),
    EXPIRY_DATE = dateForSTop,
    TRANS_ID = "1"
  }
  res = sendTransaction(transaction)
  message(res, 1)
end
function Transactions:BindedStop(client, depo, operation, price, stop_price, linkedPrice, quantity, seccode, classcode)
  transaction = {
    ACCOUNT = depo,
    CLIENT_CODE = client,
    ACTION = "NEW_STOP_ORDER",
    STOP_ORDER_KIND = "WITH_LINKED_LIMIT_ORDER",
    CLASSCODE = classcode,
    SECCODE = seccode,
    OPERATION = operation,
    QUANTITY = tostring(quantity),
    TYPE = "L",
    LINKED_ORDER_PRICE = tostring(linkedPrice),
    PRICE = tostring(price),
    STOPPRICE = tostring(stop_price),
    KILL_IF_LINKED_ORDER_PARTLY_FILLED = "NO",
    TRANS_ID = "1"
  }
  res = sendTransaction(transaction)
  message(res, 1)
end
function Transactions:TakeProfit(client, depo, operation, stop_price, OFFSET, SPREAD, UNITS, position, dateForSTop, seccode, classcode)
  transaction = {
    ACCOUNT = depo,
    CLIENT_CODE = client,
    ACTION = "NEW_STOP_ORDER",
    STOP_ORDER_KIND = "TAKE_PROFIT_STOP_ORDER",
    CLASSCODE = classcode,
    SECCODE = seccode,
    OPERATION = operation,
    QUANTITY = position,
    TYPE = "L",
    OFFSET = tostring(OFFSET),
    OFFSET_UNITS = UNITS,
    SPREAD = SPREAD,
    SPREAD_UNITS = "PRICE_UNITS",
    STOPPRICE = tostring(stop_price),
    EXPIRY_DATE = dateForSTop,
    COMMENT = "",
    TRANS_ID = tostring(1)
  }
  res = sendTransaction(transaction)
  message(res, 1)
end
function Transactions:CalcDateForStop()
  timeServer = getInfoParam("SERVERTIME")
  secondServer = string.sub(timeServer, 7, 8)
  CurDate = getInfoParam("TRADEDATE")
  Second = secondServer
  curDay = tonumber(string.sub(CurDate, 1, 2)) + 10
  curMonth = tonumber(string.sub(CurDate, 4, 5))
  curYear = tonumber(string.sub(CurDate, 7, 10)) + 0
  if curDay > 28 then
    curMonth = curMonth + 1
    curDay = 10
    if curMonth > 12 then
      curMonth = 1
      curYear = curYear + 1
    end
  end
  if 10 > curMonth then
    curMonth = "0" .. tostring(curMonth)
  end
  if curDay < 10 then
    curDay = "0" .. tostring(curDay)
  end
  self.dateForStop = curYear .. curMonth .. curDay
end
function Transactions:CalcId()
  timeServer = getInfoParam("SERVERTIME")
  secondServer = string.sub(timeServer, 7, 8)
  minuteServer = string.sub(timeServer, 4, 5)
  hourServer = string.sub(timeServer, 1, 2)
  idServer = hourServer * 10000 + minuteServer * 100 + secondServer
  return idServer
end
function Transactions:CalcDiffSeconds(time1, time2)
  secondServer1 = tonumber(string.sub(time1, 5, 6))
  minuteServer1 = tonumber(string.sub(time1, 3, 4)) * 60
  hourServer1 = tonumber(string.sub(time1, 1, 2)) * 60 * 60
  idServer1 = hourServer1 + minuteServer1 + secondServer1
  secondServer2 = tonumber(string.sub(time2, 5, 6))
  minuteServer2 = tonumber(string.sub(time2, 3, 4)) * 60
  hourServer2 = tonumber(string.sub(time2, 1, 2)) * 60 * 60
  idServer2 = hourServer2 + minuteServer2 + secondServer2
  return idServer1 - idServer2
end
function Transactions:StopLimit(operation, stop_price, price, quantity)
  transaction = {
    CLASSCODE = self.Class,
    ACTION = "NEW_STOP_ORDER",
    ACCOUNT = self.Depo,
    CLIENT_CODE = self.Client,
    OPERATION = operation,
    SECCODE = self.Code,
    PRICE = tostring(price),
    STOPPRICE = tostring(stop_price),
    QUANTITY = tostring(quantity),
    TRANS_ID = tostring(1),
    EXPIRY_DATE = "GTC"
  }
  res = sendTransaction(transaction)
  message(res, 1)
end
function Transactions:StopLimitWithId(seccode, class, client, depo, operation, stop_price, price, quantity, id)
  transaction = {
    CLASSCODE = class,
    ACTION = "NEW_STOP_ORDER",
    ACCOUNT = depo,
    CLIENT_CODE = client,
    OPERATION = operation,
    SECCODE = seccode,
    PRICE = tostring(price),
    STOPPRICE = tostring(stop_price),
    QUANTITY = tostring(quantity),
    TRANS_ID = tostring(id),
    EXPIRY_DATE = "GTC"
  }
  res = sendTransaction(transaction)
  message(res, 1)
end
function Transactions:killAllOrders(code, class)
  for i = 0, getNumberOf("orders") - 1 do
    stopOrder = getItem("orders", i)
    if tostring(stopOrder.seccode) == code and bit.band(stopOrder.flags, 3) == 1 then
      self:killOrder(stopOrder.ordernum, code, class)
    end
  end
end
function Transactions:killAllOrdersByClient(code, class, client)
  for i = 0, getNumberOf("orders") - 1 do
    stopOrder = getItem("orders", i)
    if tostring(stopOrder.client_code) == client and tostring(stopOrder.seccode) == code and bit.band(stopOrder.flags, 3) == 1 then
      self:killOrder(stopOrder.ordernum, code, class)
    end
  end
end
function Transactions:killAllStopOrdersByClient(code, class, client)
  for i = 0, getNumberOf("stop_orders") - 1 do
    stopOrder = getItem("stop_orders", i)
    if tostring(stopOrder.client_code) == client and tostring(stopOrder.seccode) == code and bit.band(stopOrder.flags, 3) == 1 then
      message("Kill " .. tostring(stopOrder.ordernum), 1)
      self:killStopOrder(stopOrder.ordernum, code, class)
    end
  end
end
function Transactions:GetStopsCount(code, class, client)
  counter = 0
  for i = 0, getNumberOf("stop_orders") - 1 do
    stopOrder = getItem("stop_orders", i)
    if tostring(stopOrder.client_code) == client and tostring(stopOrder.seccode) == code and bit.band(stopOrder.flags, 3) == 1 then
      counter = counter + 1
    end
  end
  return counter
end
function Transactions:killAllStopOrders(code, class)
  for i = 0, getNumberOf("stop_orders") - 1 do
    stopOrder = getItem("stop_orders", i)
    if tostring(stopOrder.seccode) == code and bit.band(stopOrder.flags, 3) == 1 then
      message("Kill " .. tostring(stopOrder.ordernum), 1)
      self:killStopOrder(stopOrder.ordernum, code, class)
    end
  end
end
function Transactions:killStopOrder(number, code, class)
  kill_order_trans = {
    CLASSCODE = class,
    SECCODE = code,
    ACTION = "KILL_STOP_ORDER",
    STOP_ORDER_KEY = tostring(number),
    TRANS_ID = tostring(1)
  }
  sendTransaction(kill_order_trans)
end
function Transactions:killOrder(number, code, class)
  kill_order_trans = {
    CLASSCODE = class,
    SECCODE = code,
    ACTION = "KILL_ORDER",
    ORDER_KEY = tostring(number),
    TRANS_ID = tostring(1)
  }
  res = sendTransaction(kill_order_trans)
  message(res, 1)
end
