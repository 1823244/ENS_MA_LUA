
Strategy = class(function(acc)
end)

function Strategy:Init()
  self.FractalSeries = {}
  self.PriceSeries = {}
  self.Range = 0
  self.Stop = 0
  self.SetStop = 0
  self.Position = 0
  self.PredPosition = 0
  self.Reversed = 0
  self.Waiter = 0
  self.TimeToClose = 0
  self.Level = 0
  self.High = 0
  self.CurBar = ""
  self.PredBar = ""
  self.Diff = 0
  self.TimeFrame = 0
  self.NextBar = 0
  self.Close = 0
  self.Seconds = 0
  self.LastCandle = {}
  self.predTime = 0
  self.BuyLevel = 0
  self.SellLevel = 0
  self.Resultat = 0
  self.NextLot = 0
  self.CurTime = 0
  self.CurTimeStr = 0
  self.Resultat = 0
  self.Second = 0
  self.PredSecond = 0
  self.stopLevel = 0
  self.N = 0
  self.CurClose = 0
  self.LotToTrade = 0
  self.perm = 1
  self.BarEnter = 0
  self.Ma1 = 0
  self.Ma2 = 0
  self.Macd = 0
  self.Sar = 0
  self.Ma1Pred = 0
  self.Ma2Pred = 0
  self.MacdPred = 0
  self.SarPred = 0
  self.ClosePred = 0
  self.Ma1Series = {}
  self.Ma2Series = {}
  self.MacdSeries = {}
  self.SarSeries = {}
  self.Exit = ""
  self.NumCandles = 0
  self.FractalUp1Price = 0
  self.FractalUp1Time = 0
  self.FractalUp2Price = 0
  self.FractalUp2Time = 0
  self.FractalDown1Price = 0
  self.FractalDown1Time = 0
  self.FractalDown2Price = 0
  self.FractalDown2Time = 0
  self.UpCounter = 0
  self.DownCounter = 0
  self.UpCurCounter = 0
  self.DownCurCounter = 0
  self.DeltaDownTrend = 0
  self.DeltaUpTrend = 0
  self.DeltaDownKoef = 0
  self.DeltaUpKoef = 0
  self.UpTrend = 0
  self.DownTrend = 0
  self.PredLast = 0
  self.BBUp = 0
  self.BBDown = 0
end

function Strategy:SetSeries(priceSeries)
  if self:checkNill(priceSeries) then
    logMemo:Add("No data!")
  end
  self.PriceSeries = priceSeries
end

function AddZero(value)
  if string.len(tostring(value)) < 10 then
    value = "0" .. value
  end
  return tostring(value)
end

function Strategy:CheckNewCandle(lastCandle)
  if LastCandle ~= {} and LastCandle ~= nil and LastCandle.day * LastCandle.hour * LastCandle.min ~= lastCandle.day * lastCandle.hour * lastCandle.min then
    LastCandle = lastCandle
    return true
  end
  LastCandle = lastCandle
  return false
end

function Strategy:CheckIfNotEntryBar()
  if self.BarEnter == self.PriceSeries[0].datetime.hour * 100 + self.PriceSeries[0].datetime.min then
    return false
  end
  return true
end

function Strategy:GetTimeBar(number)
  hour = self.PriceSeries[number].datetime.hour
  minute = self.PriceSeries[number].datetime.min
  if hour < 10 then
    hour = "0" .. hour
  end
  if minute < 10 then
    minute = "0" .. minute
  end
  return tostring(hour) .. ":" .. tostring(minute)
end

function Strategy:addLog(mess)
  logMemo:Add(self.CurTimeStr .. " " .. mess)
end

--вызывается из этого же файла. Strategy:DoBisness()
function Strategy:CalcLevels()
  self.CurClose = tonumber(self.PriceSeries[0].close)
  self.Ma1 = self.Ma1Series[1].close
  self.Ma2 = self.Ma2Series[1].close
  self.Ma1Pred = self.Ma1Series[0].close 	--ENS
  self.Ma2Pred = self.Ma2Series[0].close	--ENS
end

--********************************************************************************
--********************************************************************************
--********************************************************************************
--********************************************************************************
--********************************************************************************
--похоже, это основная функция. она вызывается из файла робота, из функции OnParam().
--********************************************************************************
--********************************************************************************
--********************************************************************************
--********************************************************************************
--********************************************************************************
function Strategy:DoBisness()
  
  self:CalcLevels()
  
	--работа с режимом взята из аналогичного робота на QPILE
	local enter_quantity= 0
	local exit_quantity	= 0
  
    if settings.rejim == "revers" then
        enter_quantity	= self.LotToTrade 	- self.Position
        exit_quantity	= self.LotToTrade	+ self.Position
    end
 
	if settings.rejim == "long" then
        enter_quantity	= self.LotToTrade	- self.Position
        exit_quantity	= self.Position
    end
 
    if settings.rejim == "short" then
        enter_quantity	= -self.Position
        exit_quantity	= self.LotToTrade	+ self.Position
    end
 
  --пересечение снизу вверх - покупка
  if self.Ma1 ~= 0 
	and self.Ma1Pred  ~= 0 
	and self.Ma2 ~= 0
	and self.Ma2Pred  ~= 0
	and self.PredLast ~= 0
	and security.last ~= 0
	and self.Ma1Pred < self.Ma2Pred 
	and self.Ma1 > self.Ma2 
	and self.Position <= 0 
	and self.Waiter == 0 
	--ENS Добавил это условие. Если будет режим шорт, с этим условием в лонг не зайдем
	and enter_quantity ~= 0 then 
	
    self.Waiter = 1
	
	--[[
		if enter_quantity == 0 then
			local logfile = "c:\\TRAIDING\\ROBOTS\\DEMO\\ENS_MA_lua\\ARQA\\log.txt"
			Helper:AppendInFile(logfile, "----------------------------------------".."\n")
			Helper:AppendInFile(logfile, "operation BUY".."\n")
			Helper:AppendInFile(logfile, "sec code: "..tostring(settings.SecCodeBox).."\n")
			Helper:AppendInFile(logfile, "Position: "..tostring(self.Position).."\n")	
			Helper:AppendInFile(logfile, "LotToTrade: "..tostring(self.LotToTrade).."\n")	
			Helper:AppendInFile(logfile, "enter_quantity: "..tostring(enter_quantity).."\n")	
			
			Helper:AppendInFile(logfile, "rejim: "..tostring(settings.rejim).."\n")	
		end
	--]]
	
	
	
	--добавил работу с режимом. было так
    --self:Buy(self.LotToTrade - self.Position)
	--стало
	self:Buy(enter_quantity)
	--message("тест. покупка."..tostring(self.LotToTrade - self.Position).." лотов")
	
  end
  
  --пересечение сверху вниз - продажа
  if self.Ma1 ~= 0 
	and self.Ma1Pred  ~= 0 
	and self.Ma2 ~= 0
	and self.Ma2Pred  ~= 0
	and self.PredLast ~= 0
	and security.last ~= 0
	and self.Ma1Pred > self.Ma2Pred 
	and self.Ma1 < self.Ma2 
	and self.Position >= 0 
	and self.Waiter == 0
	--ENS Добавил это условие. Если будет режим лонг, с этим условием в шорт не зайдем	
    and exit_quantity ~= 0 then 
	
	self.Waiter = 1	--что делает этот флаг???
	

	--[[
		if exit_quantity == 0 then
			local logfile = "c:\\TRAIDING\\ROBOTS\\DEMO\\ENS_MA_lua\\ARQA\\log.txt"
			Helper:AppendInFile(logfile, "----------------------------------------".."\n")
			Helper:AppendInFile(logfile, "operation SELL".."\n")
			Helper:AppendInFile(logfile, "sec code: "..tostring(settings.SecCodeBox).."\n")
			Helper:AppendInFile(logfile, "Position: "..tostring(self.Position).."\n")	
			Helper:AppendInFile(logfile, "LotToTrade: "..tostring(self.LotToTrade).."\n")	
			Helper:AppendInFile(logfile, "enter_quantity: "..tostring(enter_quantity).."\n")	
			Helper:AppendInFile(logfile, "exit_quantity: "..tostring(exit_quantity).."\n")	
			Helper:AppendInFile(logfile, "rejim: "..tostring(settings.rejim).."\n")	
		end
	--]]

	
	
    --добавил работу с режимом. было так
	--self:Sell(self.LotToTrade + self.Position)
	--стало
	self:Sell(exit_quantity)
	--message("тест. продажа."..tostring(self.LotToTrade + self.Position).." лотов")
	
  end


  
  --свойство Second передается сюда из робота
  if self.Waiter ~= 0 and self.PredSecond ~= self.Second then
    self.Waiter = self.Waiter + 1
    self.PredSecond = self.Second
  end
  
  if self.Waiter > 5 then
    self.Waiter = 0
  end
  
  self.PredLast = security.last
  
end

function Strategy:checkNill(value)
  if value == 0 or value == nil then
    return true
  end
  return false
end

function Strategy:KillAll()
  killAllStopOrders(settings.SecCodeBox, settings.ClassCode)
  killAllOrders(settings.SecCodeBox, settings.ClassCode)
end

--вызывается из этого же файла. Strategy:DoBisness()
function Strategy:Buy(LotToTrade)
  message("Buy " .. settings.SecCodeBox, 1)
  transactions:order(settings.SecCodeBox, settings.ClassCode, "B", settings.ClientBox, settings.DepoBox, tostring(tonumber(security.last) + 60 * security.minStepPrice), LotToTrade)
end

--вызывается из этого же файла. Strategy:DoBisness()
function Strategy:Sell(LotToTrade)
  message("Sell " .. settings.SecCodeBox, 1)
  transactions:order(settings.SecCodeBox, settings.ClassCode, "S", settings.ClientBox, settings.DepoBox, tostring(tonumber(security.last) - 60 * security.minStepPrice), LotToTrade)
end
