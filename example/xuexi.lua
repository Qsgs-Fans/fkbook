local extension = Package:new("xuexi")
extension.extensionName = "study"

Fk:loadTranslationTable{
  ["xuexi"] = "学习",
  ["st"] = "学",
}

local caocao = General(extension, "st__caocao", "wei", 4, 6, General.Male)
caocao.subkingdom = "qun"
caocao.shield = 2

local st__yingjie = fk.CreateTriggerSkill{
  name = "st__yingjie",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local st__yingjie_targetmod = fk.CreateTargetModSkill{
  name = "#st__yingjie_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:hasSkill(self.name) and scope == Player.HistoryPhase then
      return 1
    end
  end,
  extra_target_func = function(self, player, skill)
    if skill.trueName == "slash_skill" and player:hasSkill(self.name) then
      return 1
    end
  end,
}
local st__yingjie_maxcards = fk.CreateMaxCardsSkill{
  name = "#st__yingjie_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self.name) then
      return 1
    else
      return 0
    end
  end,
}
local st__yingjie_attackrange = fk.CreateAttackRangeSkill{
  name = "#st__yingjie_attackrange",
  correct_func = function (self, from)
    if from:hasSkill(self.name) then
      return 1
    end
    return 0
  end,
}
local st__yingjie_distance = fk.CreateDistanceSkill{
  name = "#st__yingjie_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -1
    end
  end,
}
local st__yingjie_prohibit = fk.CreateProhibitSkill{
  name = "#st__yingjie_prohibit",
  is_prohibited = function(self, from, to, card)
    if to:hasSkill(self.name) then
      return card.name == "archery_attack"
    end
  end,
}
st__yingjie:addRelatedSkill(st__yingjie_targetmod)
st__yingjie:addRelatedSkill(st__yingjie_maxcards)
st__yingjie:addRelatedSkill(st__yingjie_attackrange)
st__yingjie:addRelatedSkill(st__yingjie_distance)
st__yingjie:addRelatedSkill(st__yingjie_prohibit)
caocao:addSkill(st__yingjie)
caocao:addSkill("feiying")
Fk:loadTranslationTable{
  ["st__caocao"] = "曹操",
  ["st__yingjie"] = "英杰",
  [":st__yingjie"] = "锁定技，摸牌阶段，你额外摸一张牌；" ..
  "出牌阶段，你使用【杀】次数上限+1且目标上限+1；"..
  "你的手牌上限+1；你的攻击范围+1；你计算至其他角色距离-1；" ..
  "你不能成为【万箭齐发】的目标。",

  ["$st__yingjie1"] = "宁教我负天下人，休教天下人负我！",
  ["$st__yingjie2"] = "吾好梦中杀人！",
  ["~st__caocao"] = "霸业未成！未成啊！",
}

local st__lvmeng = General(extension, "st__lvmeng", "wu", 4, 4, General.Male)
local st__keji = fk.CreateTriggerSkill{
name = "st__keji",
anim_type = "offensive",
events = {fk.EventPhaseChanging},
can_trigger = function(self, event, target, player, data)
  if target == player and player:hasSkill(self.name) then
	if data.to ~= Player.NotActive then
	  return true
	end
  end
end,
on_cost = function(self, event, target, player, data)
  local room = player.room
  local targets = {}
  for _, p in ipairs(room:getOtherPlayers(player)) do
	if not player:isProhibited(p, Fk:cloneCard("slash")) then
	  table.insert(targets, p.id)
	end
  end
  if #targets == 0 then return end
  -- 这里的"#st__keji-choose"是你在询问中能看到的字符串，这个交给翻译表即可。
  local to = room:askForChoosePlayers(player, targets, 1, 1, "#st__keji-choose", self.name, true)
  if #to > 0 then
	self.cost_data = {to[1]}
	return true
  end
end,
on_use = function(self, event, target, player, data)
  local room = player.room
  room:useVirtualCard("slash", nil, player, player.room:getPlayerById(self.cost_data[1]), self.name, true)
  return true
end,
}
st__lvmeng:addSkill(st__keji)

Fk:loadTranslationTable{
["st__lvmeng"] = "吕蒙",
["st__keji"] = "克己",
[":st__keji"] = "克己：你可以跳过任意阶段，视为使用一张无距离和次数限制的【杀】。",
["#st__keji-choose"] = "克己：你可以跳过本阶段，视为使用一张【杀】"
}

local tester = General(extension, "st__tester", "shu", 4)
local test = fk.CreateActiveSkill{
  name = "st__test",
  target_filter = function(self, to_select)
    return true
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)  -- 这是你，技能的发动者
    local to = room:getPlayerById(effect.tos[1])  -- 这是选择的第一个目标
    -- 接下来就随意发挥吧！想写啥代码都行
    room:changeHp(to, -1, nil, self.name)
  end,
}
tester:addSkill(test)
-- 这是来自谋徐盛的技能，可以在第一轮开始时立刻进入额外回合
tester:addSkill("test_zhenggong")
Fk:loadTranslationTable{
  ["st__tester"] = "测试员",
  ["st__test"] = "演练",
  [":st__test"] = "出牌阶段，你可以演练。",
}

local st__jiecao = fk.CreateTriggerSkill{
  name = "st__jiecao",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.HpChanged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
tester:addSkill(st__jiecao)
Fk:loadTranslationTable{
  ["st__jiecao"] = "节操",
  [":st__jiecao"] = "锁定技，当你的体力值变化后，你摸一张牌。",
}

return extension
