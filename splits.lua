math.randomseed(os.time())
local p1,p2,model = {1,1},{1,1},{}
model.__index = model
local function tdump(t) if type(t)~="table" then return type(t)=="string" and string.format("%q",t) or tostring(t) end local r,s,i={},{{t,nil,0}},"  " while #s>0 do local o=s[#s] local c,k,d=o[1],o[2],o[3] local nk,v=next(c,k) if not k then r[#r+1]="{\n" end while nk~=nil and type(v)=="function" do nk,v=next(c,nk) end if nk~=nil then o[2]=nk local l=i:rep(d+1) local ks=type(nk)=="number" and "" or (type(nk)=="string" and nk:match("^[%a_][%w_]*$") and nk or "["..string.format("%q",nk).."]") if ks~="" then ks=ks.." = " end r[#r+1]=l..ks if type(v)=="table" then s[#s+1]={v,nil,d+1} else r[#r+1]=(type(v)=="string" and string.format("%q",v) or tostring(v))..",\n" end else r[#r+1]=i:rep(d).."}"..(#s>1 and ",\n" or "\n") s[#s]=nil end end return table.concat(r) end
local function clrscr() if not os.execute("clear") then os.execute("cls") end end
function model.new(p) return setmetatable({mstate = {},his = {P1 = {}, P2 = {}},player = p},model) end
local function sortstate(p1, p2)
  local s1, sp1, s2, sp2= {p1[1], p1[2]}, false, {p2[1], p2[2]}, false
  if s1[1] > s1[2] then s1[1], s1[2] = s1[2], s1[1]; sp1 = true end
  if s2[1] > s2[2] then s2[1], s2[2] = s2[2], s2[1]; sp2 = true end
  return s1, s2, sp1, sp2
end
function model.find_moves_and_construct(p1,p2)
  local tmp_mstate_slice = {}
  for h1 = 1,2 do if p1[h1] > 0 then for h2 = 1,2 do if p2[h2] > 0 then tmp_mstate_slice[string.format("A%d%d",h1,h2)] = 10 end end end end
  local lc = (p1[1] > 0 and 1 or 0) + (p1[2] > 0 and 1 or 0)
  if lc == 1 then
    local li = p1[1] > 0 and 1 or 2
    local lv = p1[li]
    if lv % 2 == 0 then
      local hlv = lv / 2
      for h2 = 1,2 do if p2[h2] > 0 then tmp_mstate_slice[string.format("S%d%d",hlv,h2)] = 10 end end
    end
  end
  return tmp_mstate_slice
end
function model:update(w,r)
  local rew = r or ((w == self.player) and 5) or (w == "none" and -2) or -5
  for _,e in ipairs(self.his[self.player]) do if self.mstate[e.state] and self.mstate[e.state][e.move] then self.mstate[e.state][e.move] = math.max(1,self.mstate[e.state][e.move] + rew) end end
  self.his[self.player] = {}
end
function model:think(p1, p2)
  local sp1, sp2, swap1, swap2 = sortstate(p1, p2)
  local st_str = sp1[1]..sp1[2]..sp2[1]..sp2[2]
  if not self.mstate[st_str] then self.mstate[st_str] = model.find_moves_and_construct(sp1, sp2) end
  local moves, weights, total = {}, {}, 0
  for m, w in pairs(self.mstate[st_str]) do moves[#moves + 1], weights[#weights + 1], total = m,w,total + w end
  if total == 0 then for m, _ in pairs(model.find_moves_and_construct(sp1, sp2)) do moves[#moves + 1], weights[#weights + 1], total = m,1,total + 1 end end
  if #moves == 0 then return nil end
  local r, cumul, cmd = math.random(total),0,nil
  for i, w in ipairs(weights) do
    cumul = cumul + w
    if r <= cumul then cmd = moves[i]; break end
  end
  self.his[self.player][#self.his[self.player] + 1] = {state = st_str, move = cmd}
  local act,h1_raw,h2_raw,h1_final,h2_final = cmd:sub(1,1), tonumber(cmd:sub(2,2)), tonumber(cmd:sub(3,3)),nil,nil
  if act == "A" then h1_final,h2_final = swap1 and ((h1_raw == 1) and 2 or 1) or h1_raw, swap2 and ((h2_raw == 1) and 2 or 1) or h2_raw ; return string.format("A%d%d",h1_final,h2_final)
  elseif act == "S" then h2_final = swap2 and ((h2_raw == 1) and 2 or 1) or h2_raw ; return string.format("S%d%d",h1_raw,h2_final) end
end
function model:save(filename) local f = io.open(filename,"w"); if f then f:write("return "..tdump(self.mstate)) f:close() end end
function model:load(filename)
  local m_func,err = loadfile(filename)
  if not m_func then print("could not find "..filename) os.exit(1) end
  self.mstate = m_func()
end
local function ex_mv(cmd,att,def)
  local act = cmd:sub(1,1)
  if act == "A" then
    local h1,h2 = tonumber(cmd:sub(2,2)),tonumber(cmd:sub(3,3))
    def[h2] = def[h2] + att[h1]
    if def[h2] > 5 then def[h2] = def[h2] % 5 end
    if def[h2] == 5 then def[h2] = 0 end
  elseif act == "S" then
    local hlv,h2 = tonumber(cmd:sub(2,2)),tonumber(cmd:sub(3,3))
    att[1],att[2] = hlv,hlv
    def[h2] = def[h2] + hlv
    if def[h2] > 5 then def[h2] = def[h2] % 5 end
    if def[h2] == 5 then def[h2] = 0 end
  end
end
local function checkwinner(p1,p2) return ((p1[1] == 0 and p1[2] == 0) and "P2") or ((p2[1] == 0 and p2[2] == 0) and "P1") or nil end
local function draw_ux(p1,p2,isai)
  isai = isai or false
  print(string.format((isai and "AI" or "HUMAN")..": left : %d right: %d",p1[1],p1[2]))
  print(string.format("AI: left: %d right: %d",p2[1],p2[2]))
end
if arg[1] == "train" then
  if not arg[2] then print("specify model name to save") os.exit(1) end
  local mn,no_of_games = arg[2],arg[3]
  local m, p1_win, p2_win, none_win = model.new("P1"),0,0,0
  for i = 1, (no_of_games or 10000) do
    local tp1,tp2 = {1,1},{1,1}
    local t, turns = "P1",0
    while not checkwinner(tp1,tp2) and turns < 100 do
      if t == "P1" then
        m.player = "P1"
        local cmd = m:think(tp1,tp2)
        if not cmd then break end
        ex_mv(cmd,tp1,tp2)
        t = "P2"
      else
        m.player = "P2"
        local cmd = m:think(tp2,tp1)
        if not cmd then break end
        ex_mv(cmd,tp2,tp1)
        t = "P1"
      end
      turns = turns + 1
    end
    local w = checkwinner(tp1,tp2)
    m.player = "P2"; m:update(w or "none"); m.player = "P1"; m:update(w or "none")
    if w == "P1" then p1_win = p1_win + 1 elseif w == "P2" then p2_win = p2_win + 1 else none_win = none_win + 1 end
    if i % 100 == 0 then clrscr() draw_ux(tp1,tp2,true); io.write(i.." games played for training\np1: "..p1_win.."\np2: "..p2_win.."\nstalls: "..none_win.."\n") io.flush() end
  end
  m:save(mn)
  clrscr()
  print("training complete")
elseif arg[1] then
  local mn = (arg[1] == "self" and (arg[0]:match("@?(.*[/\\])") or "./").."model.lua") or arg[1]
  local ai = model.new("P2")
  ai:load(mn)
  p1,p2 = {1,1},{1,1}
  local ai_cmd
  while true do
    clrscr()
    draw_ux(p1,p2)
    local w = checkwinner(p1,p2)
    if w then if w == "P1" then print("winner: player") else print("winner: ai") end ai:update(w) ai:save(mn); p1,p2,ai_cmd = {1,1},{1,1},nil ; io.write("\npress enter to play again\n") io.flush() io.read() ; clrscr() draw_ux(p1,p2) end
    local cmd
    if ai_cmd then io.write("AI cmd: "..ai_cmd.."\n") io.flush() ai_cmd = nil end
    repeat
      io.write("command: ") io.flush()
      cmd = io.read():upper()
      local valid = model.find_moves_and_construct(p1,p2)
      if not valid[cmd] then print("invalid move") cmd = nil end
    until cmd or checkwinner(p1,p2)
    if cmd then
    ex_mv(cmd,p1,p2)
    w = checkwinner(p1,p2)
    if not w then ai_cmd = ai:think(p2,p1) ; if ai_cmd then ex_mv(ai_cmd,p2,p1) end end
    end
  end
else print("usage:\n  splits-lua <modelname> : play splits with modelname\n  splits-lua self : use the built-in model\n splits-lua train <modelname> <no of games to play: optional, default 10000> : train and save to modelname, plays 10000 games by default, can be changed") end