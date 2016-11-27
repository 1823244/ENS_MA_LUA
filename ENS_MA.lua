--25 01 16
--��� ���� �� kbrobot_bollinger2.lua
--��� ������ ������� ������� ������ �� Lua

--toDo
--���� ���������� �����
-- SettingsMA.luac
-- StrategyMA.luac
--��� ��� �������: luac.exe sourcefile.lua
--� ���������� ��������� ���� luac.out, ������� ���� ������������� ��� �������


local bit = require"bit"

--��������� ���� � ������ �������
--c:\TRAIDING\ROBOTS\DEV\ENS_MA_lua\devzone\ClassesC\

dofile (getScriptPath() .. "\\Classes\\class.lua")
dofile (getScriptPath() .. "\\Classes\\Window.lua")
dofile (getScriptPath() .. "\\Classes\\Helper.lua")
dofile (getScriptPath() .. "\\Classes\\Trader.lua")
dofile (getScriptPath() .. "\\Classes\\Transactions.lua")
dofile (getScriptPath() .. "\\Classes\\SettingsMA.lua")
dofile (getScriptPath() .. "\\Classes\\Security.lua")
dofile (getScriptPath() .. "\\Classes\\StrategyMA.lua")




--��� �������:
trader ={}
trans={}
helper={}
settings={}
strategy={}
security={}
window={}


BarCount=2 		--���������� ������, ���������� � �������. ���� ������ 2: ��������� � �������������

is_run = true	--���� ������ �������, ���� ������ - ������ ��������

working = false	--���� ����������. ����� �� �������� ���� ����� ���� ��������/��������� ������

Waiter=0		--�����-�� ����, ����� ������ �� ������������, ���� ���� � ��������� ������ StrategyBollinger

local hID=0		--����� �� �� ������������, ����� �� ��� �����?
 
function OnInit(path)

	trader = Trader()
	trader:Init(path)


	trans= Transactions()
	trans:Init()

	settings=Settings()
	settings:Init()
	settings:Load(trader.Path)


	helper= Helper()
	helper:Init()

	--����� ������ � ������ �������
	security=Security()
	security:Init(settings.ClassCode,settings.SecCodeBox)

	strategy=Strategy()
	strategy:Init()



	transactions=Transactions()
	transactions:Init(settings.ClientBox,settings.DepoBox, settings.SecCodeBox,settings.ClassCode)

end

--��� �� ���������� �������, � ������ ������� �������
function OnBuy()
    if working  then
      trans:order(settings.SecCodeBox,settings.ClassCode,"B",settings.ClientBox,settings.DepoBox,tostring(security.last+100*security.minStepPrice),settings.LotSizeBox)
	end 
end

--��� �� ���������� �������, � ������ ������� �������
function OnSell()
	if working then
		trans:order(settings.SecCodeBox,settings.ClassCode,"S",settings.ClientBox,settings.DepoBox,tostring(security.last-100*security.minStepPrice),settings.LotSizeBox)
	end
end

--��� �� ����� �����, � ������ ������� ��� �������!
function OnStart()

	window:InsertValue("�������",tostring(trader:GetCurrentPosition(settings.SecCodeBox,settings.ClientBox)))
	settings:Load(trader.Path)
	strategy.LotToTrade=tonumber(settings.LotSizeBox)

	--[[
	
		  local logfile = "c:\\TRAIDING\\ROBOTS\\DEMO\\ENS_MA_lua\\ARQA\\log.txt"
		  local file = io.open(logfile, "a")
		  if file ~= nil then
			file:write("----------------------------------------".."\n")
			file:write("sec code: "..tostring(settings.SecCodeBox).."\n")
			file:write("LotToTrade: "..tostring(strategy.LotToTrade).."\n")
			file:close()
		  end	
  --]]
	
end


function OnStop(s)

	window:Close()
	is_run = false
	
end 

--������� ���������� ���������� QUIK ��� ��� ��������� ������� ����������. 
--class - ������, ��� ������
--sec - ������, ��� ������
function OnParam( class, sec )

    if is_run == false or working==false then
        return
    end
	
	trans:CalcDateForStop()	--��������� ������ ������ � ���������� �� � �������� dateForStop ������� trans
	
    if (tostring(sec) == settings.SecCodeBox)  then
		
		time = os.date("*t")
    
		strategy.Second=time.sec	--�������
	
		security:Update()	--��������� ���� ��������� ������ � ������� security (�������� Last)
	
		window:InsertValue("����",tostring(security.last))
	
		--QLUA getNumCandles
		--������� ������������� ��� ��������� ���������� � ���������� ������ �� ���������� ��������������. 
		--������ ������: 
		--NUMBER getNumCandles (STRING tag)
		--���������� ����� � ���������� ������ �� ���������� ��������������. 
	
		--�������� ��������� [1] - ��� http://robostroy.ru/community/article.aspx?id=796
		--[1]������� �� �������� ���������� ������. �����: �� ������� ����
		NumCandles = getNumCandles(settings.IdPriceCombo)	
	 
		if NumCandles~=0 then
	 
			strategy.NumCandles=BarCount
	  
			--QLUA getCandlesByIndex
			--������� ������������� ��� ��������� ���������� � ������� �� �������������� 
			--(����� ������ ��� ���������� ������� ������ �� ������������, ������� ��� ��������� ������� ������ ������ ������ ���� ������). 
			--������ ������: 
			--TABLE t, NUMBER n, STRING l getCandlesByIndex (STRING tag, NUMBER line, NUMBER first_candle, NUMBER count) 
			--���������: 
			--tag � ��������� ������������� ������� ��� ����������, 
			--line � ����� ����� ������� ��� ����������. ������ ����� ����� ����� 0, 
			--first_candle � ������ ������ ������. ������ (����� �����) ������ ����� ������ 0, 
			--count � ���������� ������������� ������.
			--������������ ��������: 
			--t � �������, ���������� ������������� ������, 
			--n � ���������� ������ � ������� t , 
			--l � ������� (�������) �������.
	  
			--[1]������� getCandlesByIndex ������� ���������, � ����� �� ����� ����� �� �������� ������, 
			--� ���� ���������� � ����� ����� ������. ��� ����� ����� 0, � ����� �����, �������, 
			--�������������� N-1 � �� ������� ������ ���������� ������.
			
			--���_��� ��� ����������� 2 ������������� �����. ��������� �� �����, �.�. ��� ��� �� ������������
			tPrice,n,s = getCandlesByIndex(settings.IdPriceCombo,0,NumCandles-3, 2)		
			strategy:SetSeries(tPrice)

			--����� ����� ����������� ���� � �������� moving averages
			tPrice,n,s = getCandlesByIndex(settings.IdMAShort,0,NumCandles-3, 2)		
			strategy.Ma1Series=tPrice	--����� ���� (Ma1Series) ��� � Init, ��� ��������� �����

			tPrice,n,s = getCandlesByIndex(settings.IdMALong,0,NumCandles-3, 2)		
			strategy.Ma2Series=tPrice	--����� ���� (Ma2Series) ��� � Init, ��� ��������� �����
	  
	  
			security:Update()		--��������� ���� ��������� ������ � ������� security (�������� Last)
			strategy.Position=trader:GetCurrentPosition(settings.SecCodeBox,settings.ClientBox)
			
			--[[
			local logfile = "c:\\TRAIDING\\ROBOTS\\DEMO\\ENS_MA_lua\\ARQA\\log.txt"
			Helper:AppendInFile(logfile, "----------------------------------------".."\n")
			--Helper:AppendInFile(logfile, "sec code: "..self.secCode.."\n")
			Helper:AppendInFile(logfile, "sec code: "..tostring(settings.SecCodeBox).."\n")
			Helper:AppendInFile(logfile, "Position: "..tostring(strategy.Position).."\n")	
			Helper:AppendInFile(logfile, "settings.LotSizeBox: "..tostring(settings.LotSizeBox).."\n")	
			Helper:AppendInFile(logfile, "strategy.LotToTrade: "..tostring(strategy.LotToTrade).."\n")	
			--Helper:AppendInFile(logfile, "enter_quantity: "..tostring(enter_quantity).."\n")	
			--Helper:AppendInFile(logfile, "exit_quantity: "..tostring(exit_quantity).."\n")	
			Helper:AppendInFile(logfile, "rejim: "..tostring(settings.rejim).."\n")	
			--]]
			
			strategy.secCode = sec --ENS ��� �������
			strategy:DoBisness()
			strategy.PredPosition=strategy.Position

			--��������� ������ � ���������� ������� ������
			window:InsertValue("MA short(1)",tostring(strategy.Ma1))
			window:InsertValue("MA long(2)",tostring(strategy.Ma2))
			window:InsertValue("MAPred short(1)",tostring(strategy.Ma1Pred))
			window:InsertValue("MAPred long(2)",tostring(strategy.Ma2Pred))
			window:InsertValue("�������",tostring(strategy.Position))
		end

	end
	
end

--�������, ����������� ����� �������� ������ �� ������
function OnTransReply(trans_reply)

	helper:AppendInFile("TransLog",trans_reply["result_msg"].." \n")

end 

--f_cb � ������� ��������� ������ ��� ��������� ������� � �������. ���������� �� main()
--(���, ������� �������, ���������� ����� �� ������� ������)
--���������:
--	t_id - ����� �������, ���������� �������� AllocTable()
--	msg - ��� �������, ������������ � �������
--	par1 � par2 � �������� ���������� ������������ ����� ��������� msg, 
--
local f_cb = function( t_id,  msg,  par1, par2)
	
	--QLUA GetCell
	--������� ���������� �������, ���������� ������ �� ������ � ������ � ������ �key�, ����� ������� �code� � ������� �t_id�. 
	--������ ������: 
	--TABLE GetCell(NUMBER t_id, NUMBER key, NUMBER code)
	--��������� �������: 
	--image � ��������� ������������� �������� � ������, 
	--value � �������� �������� ������.
	--���� ������� ��������� ���� ������ ��������, �� ������������ �nil�.
	
	x=GetCell(window.hID, par1, par2) 

	if x~=nil then
		if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="Buy �� �����" then
			message("Buy",1)
			OnBuy()
		end
	end

	if x~=nil then
		if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="Sell �� �����" then
			message("Sell",1)
			OnSell()
		end
	end


	if x~=nil then
		if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="�����" then
			OnStart()
			message("�����",1)
			window:SetValueWithColor("�����","���������","Red")
			working=true
		end
	end

	if x~=nil then
		if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="���������" then

			message("���������",1)
			window:SetValueWithColor("���������","�����","Green")
			working=false
		end
	end




	if (msg==QTABLE_CLOSE)  then
		window:Close()
		is_run = false
		message("����",1)
	end


end 

--������� ������� ������, ������� �������� � �����
function main()

	--������� ���� ������ � �������� � ��������� � ��� ������� ������
	window = Window()									--������� Window() ����������� � ����� Window.luac � ������� �����
	
	--{'A','B'} - ��� ������ � ������� �������
	--�������: http://smart-lab.ru/blog/291666.php
	--����� ������� ������, ���������� ����������� � �������� ������� �������� ��� ���������:
	--t = {��������, ��������, ������}
	--��� ��������� ������������ ���������� ����:
	--t = {[1]=��������, [2]=��������, [3]=������}	
	
	--window:Init("ENS MovingAverages", {'A','B'})	--�������� ����� init ������ window
	window:Init(settings.TableCaption, {'A','B'})	--�������� ����� init ������ window
	window:AddRow({"���","����"},"")
	window:AddRow({settings.SecCodeBox,"0"},"Grey")
	window:AddRow({"�������",""},"")
	window:AddRow({"",""},"Grey")
	window:AddRow({"MA short(1)","MA long(2)"},"")
	window:AddRow({"",""},"Grey")
	window:AddRow({"MAPred short(1)","MAPred long(2)"},"")
	window:AddRow({"",""},"Grey")
	window:AddRow({"",""},"")
	window:AddRow({"Buy �� �����",""},"Green")
	window:AddRow({"Sell �� �����",""},"Red")
	window:AddRow({"",""},"")
	window:AddRow({"�����",""},"Green")


	--QLUA SetTableNotificationCallback
	--������� ������� ��������� ������ ��� ��������� ������� � �������. 
	--������ ������: 
	--NUMBER SetTableNotificationCallback (NUMBER t_id, FUNCTION f_cb)
	--���������: 
	--t_id � ������������� �������, 
	--f_cb � ������� ��������� ������ ��� ��������� ������� � �������.
	--� ������ ��������� ���������� ������� ���������� �1�, ����� � �0�. 
	--������ ������ ������� ��������� ������ ��� ��������� ������� � �������: 
	--f_cb = FUNCTION (NUMBER t_id, NUMBER msg, NUMBER par1, NUMBER par2)
	--���������: 
	--t_id � ������������� �������, ��� ������� �������������� ���������, 
	--par1 � par2 � �������� ���������� ������������ ����� ��������� msg, 
	--msg � ��� ���������.
	
	SetTableNotificationCallback (window.hID, f_cb)

	--����������
	
	--��� ��������� ������������ ���� ���� ���� ����� ��������, �.�. ������� �������� ���� ������� �����
	--[[ ��� �������� - ����� ��������� ����������
	if working == false then
		OnStart()
		message("�����",1)
		window:SetValueWithColor("�����","���������","Red")
		working=true
	end
	--]]
	
	--�������� 100 ����������� ����� ���������� 
	while is_run do
		sleep(50)
	end
	

end















