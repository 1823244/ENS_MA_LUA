helper = {}
Settings = class(function(acc)
end)
function Settings:Init()
  self.DepoBox = ""
  self.ClientBox = ""
  self.ClassCode = ""
  self.SecCodeBox = ""
  self.LotSizeBox = ""
  self.TypeLimitCombo = ""
  self.IdPriceCombo = ""
  self.IdMAShort = ""
  self.IdMALong = ""
  self.Path = ""
  self.TableCaption=""
  self.rejim=""
  helper = Helper()
  helper:Init()
end
function Settings:Load(path)
  self.DepoBox = helper:LoadFromFile(path .. "files\\DepoBox")
  self.ClientBox = helper:LoadFromFile(path .. "files\\ClientBox")
  self.ClassCode = helper:LoadFromFile(path .. "files\\ClassCode")
  self.SecCodeBox = helper:LoadFromFile(path .. "files\\SecCodeBox")
  self.LotSizeBox = helper:LoadFromFile(path .. "files\\LotSizeBox")
  self.TypeLimitCombo = helper:LoadFromFile(path .. "files\\TypeLimitCombo")
  self.IdPriceCombo = helper:LoadFromFile(path .. "files\\IdPriceCombo")
  self.IdMAShort = helper:LoadFromFile(path .. "files\\IdMAShort")
  self.IdMALong = helper:LoadFromFile(path .. "files\\IdMALong")
  self.TableCaption = helper:LoadFromFile(path .. "files\\TableCaption")
  self.rejim = helper:LoadFromFile(path .. "files\\rejim")
  self.Path = path
  
	--[[
			local logfile = "c:\\TRAIDING\\ROBOTS\\DEMO\\ENS_MA_lua\\ARQA\\log.txt"
			Helper:AppendInFile(logfile, "----------------------------------------".."\n")
			--Helper:AppendInFile(logfile, "sec code: "..self.secCode.."\n")
			Helper:AppendInFile(logfile, "sec code: "..tostring(self.SecCodeBox).."\n")
			
			Helper:AppendInFile(logfile, "LotToTrade: "..tostring(self.LotSizeBox).."\n")	
			Helper:AppendInFile(logfile, "rejim: "..tostring(self.rejim).."\n")	
  --]]  
end
