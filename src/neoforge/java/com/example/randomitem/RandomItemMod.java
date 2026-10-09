package com.example.randomitem;

import net.neoforged.fml.common.Mod;
import net.neoforged.neoforge.common.NeoForge;
import net.neoforged.neoforge.event.RegisterCommandsEvent;

@Mod("randomitem")
public final class RandomItemMod {
    public RandomItemMod() {
        NeoForge.EVENT_BUS.addListener(this::registerCommands);
    }

    private void registerCommands(RegisterCommandsEvent event) {
        RandomItemCommand.register(event.getDispatcher());
    }
}
