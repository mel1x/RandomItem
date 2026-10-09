package com.example.randomitem;

import net.minecraftforge.event.RegisterCommandsEvent;
import net.minecraftforge.fml.common.Mod;

@Mod("randomitem")
public final class RandomItemMod {
    public RandomItemMod() {
        RegisterCommandsEvent.BUS.addListener(event -> RandomItemCommand.register(event.getDispatcher()));
    }
}
