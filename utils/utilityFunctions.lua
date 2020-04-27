
--[[
   Helper methods
   Author: dragon12
]]
colorCodes = {
    White = {r=1, g=1, b=1},
    Brown = {r=0.443, g=0.231, b=0.09},
    Red = {r=0.856, g=0.1, b=0.094},
    Orange = {r=0.956, g=0.392, b=0.113},
    Yellow = {r=0.905, g=0.898, b=0.172},
    Green = {r=0.192, g=0.701, b=0.168},
    Teal = {r=0.129, g=0.694, b=0.607},
    Blue = {r=0.118, g=0.53, b=1},
    Purple = {r=0.627, g=0.125, b=0.941},
    Pink = {r=0.96, g=0.439, b=0.807},
    Grey = {r=0.5, g=0.5, b=0.5},
    Black = {r=0.25, g=0.25, b=0.25},
}


function getPlayerName(color)
    playerName = Player[color].steam_name
    if playerName == nil then
        return color
    else
        return playerName
    end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function createButton(params)
    params.index = currIndex
    params.created = true
    self.createButton(params)
    currIndex = currIndex + 1
    return params.index
end


function printAllButtons()
    allButtons = self.getButtons()

    for i, t in pairs(allButtons) do
        print ("button, i=",i,", t=", t)
        for k,v in pairs(t) do
            print("    k=", k, ", v=", v)
        end
    end
end

function noop()
end

--[[
  End helper methods
  ]]--
