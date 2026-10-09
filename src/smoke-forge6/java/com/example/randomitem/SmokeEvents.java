package com.example.randomitem;
import net.minecraftforge.event.server.ServerStartedEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
@Mod.EventBusSubscriber(modid="randomitem")
public final class SmokeEvents {
    @SubscribeEvent public static void started(ServerStartedEvent event) {
        SmokeVerifier.verify(event.getServer());
    }
}
