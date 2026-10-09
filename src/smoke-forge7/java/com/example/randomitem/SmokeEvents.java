package com.example.randomitem;
import net.minecraftforge.event.server.ServerStartedEvent;
import net.minecraftforge.event.entity.item.ItemTossEvent;
import net.minecraftforge.eventbus.api.listener.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
@Mod.EventBusSubscriber(modid="randomitem")
public final class SmokeEvents {
    @SubscribeEvent public static void tossed(ItemTossEvent event) { SmokeVerifier.recordDrop(event.getEntity()); }
    @SubscribeEvent public static void started(ServerStartedEvent event) {
        SmokeVerifier.verify(event.getServer());
    }
}
