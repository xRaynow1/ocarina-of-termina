-- Initialisation
Sound.init()

local police = Font.load("app0:/font.ttf")
Font.setPixelSizes(police, 24)
local chrono = Timer.new()


local pistes = {
    {
        titre = "Clock Town (First Day)",
        chant = "Clock Town",
        indice = "L  R  O  X  Up  X  Down",
        melodie = "c-C-B-A-G-A-F",
        fichier = "app0:/ost/clock_town.oga"
    },
    {
        titre = "Song of Healing",
        chant = "Song of Healing",
        indice = "O  X  Down  O  X  Down  O",
        melodie = "B-A-F-B-A-F-B",
        fichier = "app0:/ost/song_of_healing.oga"
    },
    {
        titre = "Astral Observatory",
        chant = "Astral Observatory",
        indice = "L  Up  O  R  O  X  Up",
        melodie = "c-G-B-C-B-A-G",
        fichier = "app0:/ost/astral_observatory.oga"
    }
}


local notes_config = {
    { btn = SCE_CTRL_LTRIGGER, id = "c", label = "L",     y = 445, col = Color.new(80, 150, 255, 255),  fichier = "app0:/notes/note_c_low.wav" },
    { btn = SCE_CTRL_LEFT,     id = "D", label = "Left",  y = 431, col = Color.new(255, 220, 60, 255),  fichier = "app0:/notes/note_d.wav" },
    { btn = SCE_CTRL_RIGHT,    id = "E", label = "Right", y = 417, col = Color.new(255, 220, 60, 255),  fichier = "app0:/notes/note_e.wav" },
    { btn = SCE_CTRL_DOWN,     id = "F", label = "Down",  y = 403, col = Color.new(255, 220, 60, 255),  fichier = "app0:/notes/note_f.wav" },
    { btn = SCE_CTRL_UP,       id = "G", label = "Up",    y = 389, col = Color.new(255, 220, 60, 255),  fichier = "app0:/notes/note_g.wav" },
    { btn = SCE_CTRL_CROSS,    id = "A", label = "X",     y = 375, col = Color.new(255, 220, 60, 255),  fichier = "app0:/notes/note_a.wav" },
    { btn = SCE_CTRL_CIRCLE,   id = "B", label = "O",     y = 361, col = Color.new(255, 220, 60, 255),  fichier = "app0:/notes/note_b.wav" },
    { btn = SCE_CTRL_RTRIGGER, id = "C", label = "R",     y = 347, col = Color.new(80, 150, 255, 255),  fichier = "app0:/notes/note_c_high.wav" }
}


local etat = "MENU"
local onglet = 1
local selection = 1

local ost_handle = nil
local ost_en_pause = false
local note_handle = nil

local historique = {}
local max_notes = 7
local message = ""
local fin_message = 0


local function appuiUnique(pad, oldpad, bouton)
    return Controls.check(pad, bouton) and not Controls.check(oldpad, bouton)
end


local function arreterOST()
    if ost_handle ~= nil then
        Sound.close(ost_handle)
        ost_handle = nil
    end
    ost_en_pause = false
end

local function chargerOST(index)
    arreterOST()
    selection = index
    ost_handle = Sound.open(pistes[index].fichier)
    Sound.play(ost_handle, LOOP)
    ost_en_pause = false
end


local function jouerNote(note, temps)
    if note_handle ~= nil then
        Sound.close(note_handle)
        note_handle = nil
    end
    note_handle = Sound.open(note.fichier)
    Sound.play(note_handle, NO_LOOP)

    table.insert(historique, note)
    if #historique > max_notes then
        table.remove(historique, 1)
    end

    if etat == "SOLO" then
        local ids = {}
        for i = 1, #historique do
            table.insert(ids, historique[i].id)
        end
        local sequence = table.concat(ids, "-")

        for i = 1, #pistes do
            local m = pistes[i].melodie
            if #sequence >= #m and string.sub(sequence, -#m) == m then
                historique = {}
                onglet = 1
                etat = "LECTEUR"
                chargerOST(i)
                message = pistes[i].chant .. " recognized! Playing: " .. pistes[i].titre
                fin_message = temps + 4000
                break
            end
        end
    end
end


local oldpad = Controls.read()
local bg = Graphics.loadImage("app0:/bg.png")


while true do
    local temps = Timer.getTime(chrono)
    local pad = Controls.read()

    if etat == "MENU" then
        if appuiUnique(pad, oldpad, SCE_CTRL_LTRIGGER) then
            onglet = 1
        elseif appuiUnique(pad, oldpad, SCE_CTRL_RTRIGGER) then
            onglet = 2
        end

        if onglet == 1 then
            if appuiUnique(pad, oldpad, SCE_CTRL_UP) then
                selection = selection - 1
                if selection < 1 then selection = #pistes end
            elseif appuiUnique(pad, oldpad, SCE_CTRL_DOWN) then
                selection = selection + 1
                if selection > #pistes then selection = 1 end
            elseif appuiUnique(pad, oldpad, SCE_CTRL_CROSS) then
                historique = {}
                chargerOST(selection)
                etat = "LECTEUR"
            end
        else
            if appuiUnique(pad, oldpad, SCE_CTRL_CROSS) then
                historique = {}
                arreterOST()
                etat = "SOLO"
            end
        end

    elseif etat == "LECTEUR" then
        if appuiUnique(pad, oldpad, SCE_CTRL_SELECT) then
            arreterOST()
            historique = {}
            onglet = 1
            etat = "MENU"
        else
            if appuiUnique(pad, oldpad, SCE_CTRL_TRIANGLE) then
                local suivant = selection + 1
                if suivant > #pistes then suivant = 1 end
                chargerOST(suivant)
            elseif appuiUnique(pad, oldpad, SCE_CTRL_SQUARE) and ost_handle ~= nil then
                if ost_en_pause then
                    Sound.resume(ost_handle)
                    ost_en_pause = false
                else
                    Sound.pause(ost_handle)
                    ost_en_pause = true
                end
            end

            for i = 1, #notes_config do
                if appuiUnique(pad, oldpad, notes_config[i].btn) then
                    jouerNote(notes_config[i], temps)
                    break
                end
            end
        end

    elseif etat == "SOLO" then
        if appuiUnique(pad, oldpad, SCE_CTRL_SELECT) then
            historique = {}
            onglet = 2
            etat = "MENU"
        else
            if appuiUnique(pad, oldpad, SCE_CTRL_SQUARE) then
                historique = {}
            end

            for i = 1, #notes_config do
                if appuiUnique(pad, oldpad, notes_config[i].btn) then
                    jouerNote(notes_config[i], temps)
                    break
                end
            end
        end
    end


    Graphics.initBlend()
    Screen.clear(Color.new(18, 12, 30, 255))

    -- Background à 60 % d'opacité (alpha = 153 sur 255)
    if bg ~= nil then
        Graphics.drawImage(0, 0, bg, Color.new(255, 255, 255, 153))
    end

    if etat == "MENU" then
        local col_m1 = (onglet == 1) and Color.new(255, 215, 90, 255) or Color.new(130, 120, 150, 255)
        local col_m2 = (onglet == 2) and Color.new(110, 220, 255, 255) or Color.new(130, 120, 150, 255)
        Font.print(police, 40, 25, "[L] OST MENU + OCARINA", col_m1)
        Font.print(police, 500, 25, "[R] OCARINA SOLO", col_m2)
        Graphics.fillRect(40, 920, 62, 64, Color.new(90, 70, 130, 255))

        if onglet == 1 then
            Font.print(police, 40, 82, "Select a track to start the OST and ocarina:", Color.new(200, 190, 220, 255))
            for i = 1, #pistes do
                local y = 135 + (i - 1) * 65
                if i == selection then
                    Graphics.fillRect(40, 920, y - 8, y + 42, Color.new(60, 40, 95, 255))
                    Font.print(police, 60, y, "> " .. pistes[i].titre, Color.new(255, 220, 100, 255))
                else
                    Font.print(police, 60, y, "  " .. pistes[i].titre, Color.new(210, 205, 225, 255))
                end
            end
            Font.print(police, 40, 485, "Up/Down: Select | X: Confirm | L/R: Tab | START: Exit", Color.new(160, 150, 185, 255))
        else
            Font.print(police, 40, 82, "Ocarina Solo Mode - Available melodies:", Color.new(110, 220, 255, 255))
            for i = 1, #pistes do
                local y = 140 + (i - 1) * 58
                Font.print(police, 50, y, pistes[i].titre .. " :  " .. pistes[i].indice, Color.new(230, 225, 240, 255))
            end
            Graphics.fillRect(40, 920, 355, 415, Color.new(35, 50, 85, 255))
            Font.print(police, 210, 372, "Press [X] to take out the ocarina", Color.new(110, 220, 255, 255))
            Font.print(police, 40, 485, "X: Start ocarina | L/R: Tab | START: Exit", Color.new(160, 150, 185, 255))
        end

    else
        if etat == "LECTEUR" then
            Font.print(police, 40, 25, "OST PLAYBACK + OCARINA", Color.new(255, 215, 90, 255))
        else
            Font.print(police, 40, 25, "OCARINA SOLO", Color.new(110, 220, 255, 255))
        end
        Font.print(police, 650, 25, "[SELECT] Menu", Color.new(190, 180, 215, 255))
        Graphics.fillRect(40, 920, 62, 64, Color.new(90, 70, 130, 255))

        if etat == "LECTEUR" then
            for i = 1, #pistes do
                local y = 95 + (i - 1) * 58
                if i == selection then
                    Graphics.fillRect(40, 920, y - 6, y + 40, Color.new(60, 40, 95, 255))
                    local etat_txt = ost_en_pause and " [PAUSED]" or " [PLAYING]"
                    Font.print(police, 60, y, "> " .. pistes[i].titre .. etat_txt, Color.new(255, 220, 100, 255))
                else
                    Font.print(police, 60, y, "  " .. pistes[i].titre, Color.new(210, 205, 225, 255))
                end
            end
            Font.print(police, 40, 290, "/\\: Next track | []: Pause | L + D-Pad + X O R: 8 Notes", Color.new(160, 150, 185, 255))
        else
            Font.print(police, 40, 85, "Play a melody to launch its OST:", Color.new(110, 220, 255, 255))
            for i = 1, #pistes do
                local y = 130 + (i - 1) * 48
                Font.print(police, 50, y, pistes[i].titre .. " :  " .. pistes[i].indice, Color.new(230, 225, 240, 255))
            end
            Font.print(police, 40, 290, "[]: Clear staff | SELECT: Back to menu", Color.new(160, 150, 185, 255))
        end


        Graphics.fillRect(40, 920, 335, 465, Color.new(28, 20, 46, 255))
        for l = 0, 3 do
            local ly = 365 + l * 20
            Graphics.fillRect(70, 890, ly, ly + 2, Color.new(140, 100, 160, 180))
        end


        for i = 1, #historique do
            local n = historique[i]
            local nx = 120 + (i - 1) * 120
            Graphics.fillCircle(nx, n.y, 11, n.col)
            Font.print(police, nx - (#n.label * 6), 468, n.label, Color.new(220, 220, 235, 255))
        end
    end


    if temps < fin_message then
        Graphics.fillRect(40, 920, 495, 535, Color.new(40, 95, 65, 255))
        Font.print(police, 60, 502, message, Color.new(255, 255, 255, 255))
    end

    Graphics.termBlend()
    Screen.flip()

    if appuiUnique(pad, oldpad, SCE_CTRL_START) then
        break
    end

    oldpad = pad
end


arreterOST()
if note_handle ~= nil then Sound.close(note_handle) end
if bg ~= nil then Graphics.freeImage(bg) end
Timer.destroy(chrono)
System.exit()