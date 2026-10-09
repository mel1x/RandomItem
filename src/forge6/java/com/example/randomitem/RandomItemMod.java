package com.example.randomitem;

import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.event.RegisterCommandsEvent;
import net.minecraftforge.fml.common.Mod;

@Mod("randomitem")
public final class RandomItemMod {
    public RandomItemMod() {
        MinecraftForge.EVENT_BUS.addListener(this::onRegisterCommands);
    }
    private void onRegisterCommands(RegisterCommandsEvent event) {
        RandomItemCommand.register(event.getDispatcher());
    }
}
