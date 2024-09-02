function ds(s)
    sleep(math.random(s, s+100))
end

function inv(itemid)
    for _, item in pairs(getInventory()) do
        if item.id == itemid then
            return item.amount
        end
    end
    return 0
end

function spr(a, b, c, d)
    sendPacketRaw(false, {type = a, value = b, x = getLocal().pos.x, y = getLocal().pos.y, punchx = c, punchy = d})
end

function sendCollect(a)
    tx = math.floor(a.pos.y/32) == 0 and (a.pos.x + 6) or (a.pos.x + 6 + 32 * math.floor(a.pos.y/32))
    pkt = {
        type = 11,
        value = a.oid,
        x = a.pos.x,
        y = a.pos.y,
        punchx = tx,
        punchy = 0
    }
    sendPacketRaw(false, pkt)
end

function Log(a)
    logToConsole("`0[`#Dr.Rhy Universe`0][`1PnB`0] `5"..a)
end

function take(d)
    for _, i in pairs(getWorldObject()) do
        if i.id == d then
            findPath(math.floor((i.pos.x + 10)/32), math.floor(i.pos.y/32))
            sleep(math.random(400, 700))
            if inv(d) ~= 0 then
                return
            end
        end
    end
end

function drop(id)
    while inv(id) > 0 do
        sendPacketRaw(false, {type = 0, state = 48, x = getLocal().pos.x, y = getLocal().pos.y})
        ds(1)
        sendPacket(2, "action|drop\n|itemID|" .. id)
        ds(1300)
        if inv(id) ~= 0 then
            findPath(math.floor(getLocal().pos.x / 32 + 1), math.floor(getLocal().pos.y / 32))
            ds(700)
        end
    end
    return inv(id) == 0
end

function cek(a, b)
    if math.floor(getLocal().pos.x/32) == a and math.floor(getLocal().pos.y/32) == b then
        return true
    end
    return false
end

AddHook("OnVarlist", "rhy_hook", function(v)
    if v[0] == "OnDialogRequest" then
        if v[1]:find("drop_item") then
            ca = v[1]:match("count||(%d+)")
            id = v[1]:match("itemID|(%d+)")
            sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..ca)
            Log("Dropped `1"..ca.." "..getItemByID(id).name)
            return true
        elseif v[1]:find("trash_item") then
            id = tonumber(v[1]:match("itemID|([%w%s]+)\n"))
            tc = inv(id)
            sendPacket(2,"action|dialog_return\ndialog_name|trash_item\nitemID|"..id.."|\ncount|"..tc)
            return true
        end
    elseif v[0] == "OnConsoleMessage" then
        return true
    end
    return false
end)

tilecount = {-2, -1, 0, 1, 2}

function pnb(m)
    repeat
        if inv((m+1)) < 180 then
            if cek(break_x, break_y) then
                for _, i in ipairs(tilecount) do
                    breakX, breakY = math.floor(getLocal().pos.x/32) + i, math.floor(getLocal().pos.y/32) - 2
                    if checkTile(breakX, breakY).fg ~= m then
                        if auto_collect then
                            objects = getWorldObject()
                            mainpos = getLocal().pos
                            for _, v in pairs(objects) do
                                objectX, objectY = math.floor((v.pos.x + 9) / 32), math.floor((v.pos.y + 9) / 32)
                                playerX, playerY = math.floor((mainpos.x + 10) / 32), math.floor((mainpos.y + 15) / 32)
                                if objectX == (playerX + i) and objectY == (playerY - 2) then
                                    sendCollect(v)
                                    sleep(math.random(10, 20))
                                end
                            end
                        end
                        ds(delay_place)
                        spr(3, m, breakX, breakY)
                        ds(delay_place)
                    else
                        spr(3, 18, breakX, breakY)
                        ds(delay_break)
                    end
                end
            else
                findPath(break_x, break_y)
                ds(1000)
            end
        else
            Log("Dropping `1"..getItemByID((block_id + 1)).name)
            findPath(drop_x, drop_y)
            ds(1000)
            if cek(drop_x, drop_y) then
                drop((m+1))
            else
                findPath(drop_x, drop_y)
                ds(1000)
            end
        end
    until inv(m) == 0
end

function trash()
    for _, list in pairs(trash_list) do
        if inv(list) >= 100 then
            sendPacket(2, "action|trash\n|itemID|"..list)
            ds(1500)
        end
    end
end

function main(d)
    if script_by == "Rhy Universe" and link_discord == "https://discord.com/invite/xVyUWvut2D" then
        while true do
            if inv(d) == 0 then
                Log("Taking `1"..getItemByID(block_id).name)
                take(d)
                if auto_trash then
                    trash()
                end
            elseif inv(d) ~= 0 then
                Log("Breaking `1"..getItemByID(block_id).name)
                pnb(d)
            end
        end
    else
        Log("`4Wrong watermark!")
        return
    end
end

Log("Starting Auto `1PnB")
Log("Set `1Block `5to `1"..getItemByID(block_id).name)
break_x, break_y = math.floor(getLocal().pos.x/32), math.floor(getLocal().pos.y/32)
main(block_id)