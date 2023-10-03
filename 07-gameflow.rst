游戏流程相关的事件
====================

本文将以默认逻辑为基础讲述新月杀的游戏流程与包括翻面、额外阶段/回合在内的相关操作。

轮次事件
---------

新月杀默认逻辑是基于身份局构造出来的，负责正式游戏的action处的代码如下：

.. code-block:: lua
  function GameLogic:action()
    self:trigger(fk.GamePrepared)
    local room = self.room

    execGameEvent(GameEvent.DrawInitial)

    while true do
      execGameEvent(GameEvent.Round)
      if room.game_finished then break end
    end
  end

在执行完分发起始手牌事件后，游戏将一直执行轮次事件直到房间认为游戏结束。

何谓事件？
++++++++++



回合事件
---------

阶段事件
---------

主动技
--------

视为技
--------
