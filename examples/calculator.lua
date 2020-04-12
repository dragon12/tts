-- from https://steamcommunity.com/sharedfiles/filedetails/?id=2042127206

function onSave()
    local data_to_save = {saved_count = count}
    saved_data = JSON.encode(data_to_save)
    return saved_data
end

count2 = 0

function onload(saved_data)
    generateButtonParamiters()

    if saved_data != '' then
        local loaded_data = JSON.decode(saved_data)
        count = loaded_data.saved_count
    else
        count = 0
    end

    if count2 > 9999 then
        b_smalldisplay.font_size = 120
    else
        b_smalldisplay.font_size = 160
    end

    if count > 99999 then
        b_display.font_size = 180
    elseif count < 99999 then
        b_display.font_size = 180
    else
        b_display.font_size = 250
    end

    b_display.label = tostring(count)
    b_smalldisplay.label = tostring(count2)

    self.createButton(b_display)
    self.createButton(b_smalldisplay)
    self.createButton(b_plus)
    self.createButton(b_minus)
    self.createButton(b_R)
    self.createButton(b_1)
    self.createButton(b_2)
    self.createButton(b_3)
    self.createButton(b_4)
    self.createButton(b_5)
    self.createButton(b_6)
    self.createButton(b_7)
    self.createButton(b_8)
    self.createButton(b_9)
    self.createButton(b_0)
end

function reset()
    count = 0
    count2 = 0
    updatesmallDisplay()
    updateDisplay()
end

function plus()
    count = count + count2
    updatesmallDisplay()
    updateDisplay()
end

function minus()
    count = count - count2
    updatesmallDisplay()
    updateDisplay()
end

function increase_1()
    count2 = (count2*10) +1
    updatesmallDisplay()
    updateDisplay()
end

function increase_2()
    count2 = (count2*10) +2
    updatesmallDisplay()
    updateDisplay()
end

function increase_3()
    count2 = (count2*10) +3
    updatesmallDisplay()
    updateDisplay()
end

function increase_4()
    count2 = (count2*10) +4
    updatesmallDisplay()
    updateDisplay()
end

function increase_5()
    count2 = (count2*10) +5
    updatesmallDisplay()
    updateDisplay()
end

function increase_6()
    count2 = (count2*10) +6
    updatesmallDisplay()
    updateDisplay()
end

function increase_7()
    count2 = (count2*10) +7
    updatesmallDisplay()
    updateDisplay()
end

function increase_8()
    count2 = (count2*10) +8
    updatesmallDisplay()
    updateDisplay()
end

function increase_9()
    count2 = (count2*10) +9
    updatesmallDisplay()
    updateDisplay()
end

function increase_0()
    count2 = (count2*10) +0
    updatesmallDisplay()
    updateDisplay()
end

function clear1()
    count = 0
    updatesmallDisplay()
    updateDisplay()
end

function clear2()
    count2 = 0
    updatesmallDisplay()
    updateDisplay()
end

function updateDisplay()
    if count > 99999 then
        b_display.font_size = 180
    elseif count < 99999 then
        b_display.font_size = 180
    else
        b_display.font_size = 250
    end
    if count >= 99999999 then
        count = 99999999
    elseif count <= -99999999 then
        count = -99999999
    else
        count = count
    end
    b_display.label = tostring(count)
    self.editButton(b_display)
end

function updatesmallDisplay()
    if count2 > 9999 then
        b_smalldisplay.font_size = 120
    else
        b_smalldisplay.font_size = 160
    end
    if count2 >= 9999999 then
        count2 = 9999999
    end
    b_smalldisplay.label = tostring(count2)
    self.editButton(b_smalldisplay)
end

function generateButtonParamiters()
    b_display = {
        index = 1, click_function = 'clear1', function_owner = self, label = '',
        position = {0, 0.1, -1.5}, width = 1000, height = 300, font_size = 250
    }
    b_smalldisplay = {
        index = 0, click_function = 'clear2', function_owner = self, label = '',
        position = {0, 0.1, -0.7}, width = 600, height = 180, font_size = 160
    }

    b_plus = {
        click_function = 'plus', function_owner = self, label =  '+',
        position = {0.85, 0.1, -0.7}, width = 140, height = 140, font_size = 140
    }
    b_minus = {
        click_function = 'minus', function_owner = self, label =  '-',
        position = {-0.85, 0.1, -0.7}, width = 140, height = 140, font_size = 140
    }

    b_R = {
        click_function = 'reset', function_owner = self, label =  'R',
        position = {0.75, 0.1, 1.5}, width = 200, height = 200, font_size = 180
    }

    b_1 = {
        click_function = 'increase_1', function_owner = self, label =  '1',
        position = {-0.75, 0.1, 0}, width = 200, height = 200, font_size = 180
    }
    b_2 = {
        click_function = 'increase_2', function_owner = self, label =  '2',
        position = {0, 0.1, 0}, width = 200, height = 200, font_size = 180
    }
    b_3 = {
        click_function = 'increase_3', function_owner = self, label =  '3',
        position = {0.75, 0.1, 0}, width = 200, height = 200, font_size = 180
    }

    b_4 = {
        click_function = 'increase_4', function_owner = self, label =  '4',
        position = {-0.75, 0.1, 0.5}, width = 200, height = 200, font_size = 180
    }
    b_5 = {
        click_function = 'increase_5', function_owner = self, label =  '5',
        position = {0, 0.1, 0.5}, width = 200, height = 200, font_size = 180
    }
    b_6 = {
        click_function = 'increase_6', function_owner = self, label =  '6',
        position = {0.75, 0.1, 0.5}, width = 200, height = 200, font_size = 180
    }

    b_7 = {
        click_function = 'increase_7', function_owner = self, label =  '7',
        position = {-0.75, 0.1, 1}, width = 200, height = 200, font_size = 180
    }
    b_8 = {
        click_function = 'increase_8', function_owner = self, label =  '8',
        position = {0, 0.1, 1}, width = 200, height = 200, font_size = 180
    }
    b_9 = {
        click_function = 'increase_9', function_owner = self, label =  '9',
        position = {0.75, 0.1, 1}, width = 200, height = 200, font_size = 180
    }

    b_0 = {
        click_function = 'increase_0', function_owner = self, label =  '0',
        position = {0, 0.1, 1.5}, width = 200, height = 200, font_size = 180
    }
end
