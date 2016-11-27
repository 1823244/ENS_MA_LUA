Window = class(function(acc)
end)
function Window:Init(caption, columns)
  self.hID = AllocTable()
  i = 1
  for key, value in pairs(columns) do
    AddColumn(self.hID, i, value, true, QTABLE_STRING_TYPE, 20)
    i = i + 1
  end
  CreateWindow(self.hID)
  SetWindowCaption(self.hID, caption)
  InsertRow(self.hID, 0)
end
function Window:InsertValue(id, value)
  value = tostring(value)
  if value == nil then
    return
  end
  rows, columns = GetTableSize(self.hID)
  i = 1
  j = 1
  while i <= columns do
    j = 1
    while j <= rows do
      x = GetCell(self.hID, j, i)
      if x ~= nil and x.image == id then
        SetCell(self.hID, j + 1, i, value)
      end
      j = j + 1
    end
    i = i + 1
  end
end
function Window:SetValueWithColor(id, value, color)
  rows, columns = GetTableSize(self.hID)
  i = 1
  j = 1
  while i <= columns do
    j = 1
    while j <= rows do
      x = GetCell(self.hID, j, i)
      if x ~= nil and x.image == id then
        SetCell(self.hID, j, i, value)
        if color == "Grey" then
          SetColor(self.hID, j, QTABLE_NO_INDEX, RGB(220, 220, 220), QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
        end
        if color == "Green" then
          SetColor(self.hID, j, QTABLE_NO_INDEX, RGB(0, 255, 0), QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
        end
        if color == "Red" then
          SetColor(self.hID, j, QTABLE_NO_INDEX, RGB(255, 0, 0), QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
        end
      end
      j = j + 1
    end
    i = i + 1
  end
end
function Window:GetValue(id)
  value = 0
  rows, columns = GetTableSize(self.hID)
  i = 1
  j = 1
  while i <= columns do
    j = 1
    while j <= rows do
      x = GetCell(self.hID, j, i)
      if x ~= nil and x.image == id then
        value = GetCell(self.hID, j + 1, i).image
      end
      j = j + 1
    end
    i = i + 1
  end
  if value == nil or value == "" then
    value = 0
  end
  return value
end
function Window:IfExists(id)
  rows, columns = GetTableSize(self.hID)
  i = 1
  j = 1
  while i <= columns do
    j = 1
    while j <= rows do
      x = GetCell(self.hID, j, i)
      if x ~= nil and x.image == id then
        return true
      end
      j = j + 1
    end
    i = i + 1
  end
  return false
end
function Window:AddRow(row, color)
  rows, columns = GetTableSize(self.hID)
  InsertRow(self.hID, rows)
  i = 1
  for key, value in pairs(row) do
    SetCell(self.hID, rows, i, tostring(value))
    i = i + 1
  end
  if color == "Grey" then
    SetColor(self.hID, rows, QTABLE_NO_INDEX, RGB(220, 220, 220), QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
  end
  if color == "Green" then
    SetColor(self.hID, rows, QTABLE_NO_INDEX, RGB(0, 255, 0), QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
  end
  if color == "Red" then
    SetColor(self.hID, rows, QTABLE_NO_INDEX, RGB(255, 0, 0), QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
  end
end
function Window:Close()
  DestroyTable(self.hID)
end
