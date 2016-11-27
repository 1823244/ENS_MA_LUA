Security = class(function(acc)
end)
function Security:Init(class, code)
  self.minStepPrice = getParamEx(class, code, "SEC_PRICE_STEP").param_value + 0
  self.STEPPRICET = getParamEx(class, code, "STEPPRICET").param_value + 0
  if self.minStepPrice == nil or tonumber(self.minStepPrice) == 0 then
    message("\208\157\208\181\209\130 \208\188\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\208\190\208\179\208\190 \209\136\208\176\208\179\208\176 \209\134\208\181\208\189\209\139 \208\178 \208\154\208\178\208\184\208\186\208\181. \208\148\208\190\208\177\208\176\208\178\209\140\209\130\208\181 \208\181\208\179\208\190 \208\178 \209\130\208\176\208\177\208\187\208\184\209\134\209\131 \208\184\208\189\209\129\209\130\209\128\209\131\208\188\208\181\208\189\209\130\208\190\208\178", 2)
  end
  self.lotSize = getParamEx(class, code, "LOTSIZE").param_value + 0
  if self.lotSize == nil or tonumber(self.lotSize) == 0 then
    message("\208\157\208\181\209\130 \209\128\208\176\208\183\208\188\208\181\209\128\208\176 \208\187\208\190\209\130\208\176 \208\178 \208\154\208\178\208\184\208\186\208\181. \208\148\208\190\208\177\208\176\208\178\209\140\209\130\208\181 \208\181\208\179\208\190 \208\178 \209\130\208\176\208\177\208\187\208\184\209\134\209\131 \208\184\208\189\209\129\209\130\209\128\209\131\208\188\208\181\208\189\209\130\208\190\208\178", 2)
  end
  self.last = getParamEx(class, code, "LAST").param_value + 0
  self.code = code
  self.class = class
end
function Security:Update()
  self.last = getParamEx(self.class, self.code, "LAST").param_value + 0
end
