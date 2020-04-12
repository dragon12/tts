-- based off https://steamcommunity.com/sharedfiles/filedetails/?id=726247480

function onSave()
    if players then
        local data_to_save = {ps=player_scores, p=players, pc=playersCount, m=memoryOn}
        saved_data = JSON.encode(data_to_save)
        return saved_data
    end
end

function onload(saved_data)
    self.createButton(b_display)
    self.createButton(b_memory)
    self.createButton(b_b0)
    self.createButton(b_b1)
    self.createButton(b_b2)
    self.createButton(b_b3)
    self.createButton(b_b4)
    self.createButton(b_b5)
    self.createButton(b_b6)
    self.createButton(b_b7)
    self.createButton(b_b8)
    self.createButton(b_b9)
    self.createButton(b_enter)
    self.createButton(b_plus)
    self.createButton(b_minus)
    operator = ''

    if saved_data != '' and saved_data != nil then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.pc != nil and loaded_data.m == true then
            printToAll('Scoreboard Data Loaded',{1,1,1})
            player_scores = loaded_data.ps
            players = loaded_data.p
            playersCount = loaded_data.pc
            --start timer
            Timer.create({identifier='TD', function_name = 'timerDelay', delay=0.2})
            for i=1, playersCount, 1 do
                local tempName = getPlayerName(player_scores[i].color)
                b_standings[i].fullName = tempName
                tempName = string.sub(tempName,1,8)

                b_standings[i].label = tempName .. ': ' .. player_scores[i].score
                self.createButton(b_standings[i])
                b_standings[i].value = player_scores[i].score
            end
        else
            player_scores = {}
        end
    else
        player_scores = {}
    end
    memoryOn = true
end

function timerDelay()
    b_display.label = ''
    b_display.click_function = 'clear'
    self.editButton(b_display)
end

function start()
    players = getSeatedPlayers() -- Gets seated players
    --players = {'White', 'Purple', 'Blue', 'Green', 'Red', 'Yellow', 'Brown', 'Pink'} -- For debugging, fakes players at table
    playersCount = #players
    b_display.label = ''
    b_display.click_function = 'clear'
    self.editButton(b_display)

    for i=1, playersCount, 1 do
        local tempName = getPlayerName(players[i])
        tempName = string.sub(tempName,1,8)
        b_standings[i].label = tempName .. ': 0'
        self.createButton(b_standings[i])
        player_scores[i] = {color = players[i], score = 0}
    end
end

function memoryOnOff()
    if memoryOn then
        memoryOn = false
        b_memory.label='Memory:\nOFF'
        self.editButton(b_memory)
    else
        memoryOn = true
        b_memory.label='Memory:\nON'
        self.editButton(b_memory)
    end
end

function clear()
    b_display.label = ''
    self.editButton(b_display)
    operator = ''
    designatedPlayer = 0
end

function l1() l(1) end function l2() l(2) end function l3() l(3) end
function l4() l(4) end function l5() l(5) end function l6() l(6) end
function l7() l(7) end function l8() l(8) end

function l(ln)
    if operator == '' then
        local value = b_standings[ln].value
        b_display.label = value
        self.editButton(b_display)
        operator = 'pending'
        designatedPlayer = ln
    end
end

function plus()
    if operator == 'pending' then
        b_display.label = b_display.label .. ' + '
        self.editButton(b_display)
        operator = 'add'
    end
end

function minus()
    if operator == 'pending' then
        b_display.label = b_display.label .. ' - '
        self.editButton(b_display)
        operator = 'subtract'
    end
end

function b0() b('0') end function b1() b('1') end function b2() b('2') end
function b3() b('3') end function b4() b('4') end function b5() b('5') end
function b6() b('6') end function b7() b('7') end function b8() b('8') end
function b9() b('9') end

function b(n)
    if operator == 'add' or operator == 'subtract' then
        b_display.label = b_display.label .. n
        self.editButton(b_display)
    end
end

function enter()
    local mult = 0
    local opString = ''

    if operator == 'add' then
        mult = 1
        opString = '+'
    elseif operator == 'subtract' then
        mult = -1
        opString = '-'
    else
        printToAll("Can't press equals before inputting operation", {r=255,b=0,g=0})
        return
    end

    local valueOld = b_standings[designatedPlayer].value
    local s = b_display.label
    local valueIndex = string.find(s, opString)
    local valueNew = string.sub(s, valueIndex + 2, -1)

    local newScore = valueOld + (valueNew * mult)

    printToAll(string.format("Score update[%s]: %d %s %d = %d",
        getPlayerName(player_scores[designatedPlayer].color), valueOld, opString, valueNew, newScore),
        {r=255,g=255,b=255})

    player_scores[designatedPlayer].score = newScore

    updateScores()
end

function getPlayerName(color)
    local name = Player[color].steam_name
    if name == nil then
        return color
    else
        return name
    end
end

function updateScores()
    local sort_func = function( a,b ) return a.score > b.score end
    table.sort( player_scores, sort_func )
    for i=1, playersCount, 1 do
        local playerName = getPlayerName(player_scores[i].color)
        playerName = string.sub(playerName,1,9)

        b_standings[i].label = playerName .. ': ' .. player_scores[i].score
        b_standings[i].value = player_scores[i].score
        self.editButton(b_standings[i])
    end
    clear()
end

-- Basic paramiters for all buttons, utilized by createButton elsewhere
b_display = {
    index=0, label='Click Once Seated\nto Start Scoring', click_function='start', function_owner=self,
    position={-2.15,0.1,-0.925}, width=660, height=240, font_size=80
}

b_memory = {
    index=1, label='Memory:\nON', click_function='memoryOnOff', function_owner=self,
    position={-2.6,0.1,0.9}, width=220, height=220, font_size=40
}

b_b0 = {
    label='0', click_function='b0', function_owner=self,
    position={-1.925,0.1,0.9}, width=430, height=220, font_size=180
}

b_b1 = {
    label='1', click_function='b1', function_owner=self,
    position={-2.6,0.1,0.45}, width=220, height=220, font_size=180
}

b_b2 = {
    label='2', click_function='b2', function_owner=self,
    position={-2.15,0.1,0.45}, width=220, height=220, font_size=180
}

b_b3 = {
    label='3', click_function='b3', function_owner=self,
    position={-1.7,0.1,0.45}, width=220, height=220, font_size=180
}

b_b4 = {
    label='4', click_function='b4', function_owner=self,
    position={-2.6,0.1,0}, width=220, height=220, font_size=180
}

b_b5 = {
    label='5', click_function='b5', function_owner=self,
    position={-2.15,0.1,0}, width=220, height=220, font_size=180
}

b_b6 = {
    label='6', click_function='b6', function_owner=self,
    position={-1.7,0.1,0}, width=220, height=220, font_size=180
}

b_b7 = {
    label='7', click_function='b7', function_owner=self,
    position={-2.6,0.1,-0.45}, width=220, height=220, font_size=180
}

b_b8 = {
    label='8', click_function='b8', function_owner=self,
    position={-2.15,0.1,-0.45}, width=220, height=220, font_size=180
}

b_b9 = {
    label='9', click_function='b9', function_owner=self,
    position={-1.7,0.1,-0.45}, width=220, height=220, font_size=180
}

b_enter = {
    label='=', click_function='enter', function_owner=self,
    position={-1.25,0.1,0.68}, width=220, height=430, font_size=180
}

b_plus = {
    label='+', click_function='plus', function_owner=self,
    position={-1.25,0.1,-0.235}, width=220, height=430, font_size=180
}

b_minus = {
    label='-', click_function='minus', function_owner=self,
    position={-1.25,0.1,-0.925}, width=220, height=220, font_size=180
}


b_standings = {
    [1] = {
        index=15, label='', click_function='l1', function_owner=self,
        position={0.123,0.1,-0.9}, width=740, height=220, font_size=100, value='0'
    },

    [2] = {
        index=16, label='', click_function='l2', function_owner=self,
        position={0.123,0.1,-0.3}, width=740, height=220, font_size=100, value='0'
    },

    [3] = {
        index=17, label='', click_function='l3', function_owner=self,
        position={0.123,0.1,0.3}, width=740, height=220, font_size=100, value='0'
    },

    [4] = {
        index=18, label='', click_function='l4', function_owner=self,
        position={0.123,0.1,0.9}, width=740, height=220, font_size=100, value='0'
    },

    [5] = {
        index=19, label='', click_function='l5', function_owner=self,
        position={2.04,0.1,-0.9}, width=740, height=220, font_size=100, value='0'
    },

    [6] = {
        index=20, label='', click_function='l6', function_owner=self,
        position={2.04,0.1,-0.3}, width=740, height=220, font_size=100, value='0'
    },

    [7] = {
        index=21, label='', click_function='l7', function_owner=self,
        position={2.04,0.1,0.3}, width=740, height=220, font_size=100, value='0'
    },

    [8] = {
        index=22, label='', click_function='l8', function_owner=self,
        position={2.04,0.1,0.9}, width=740, height=220, font_size=100, value='0'
    }
}
