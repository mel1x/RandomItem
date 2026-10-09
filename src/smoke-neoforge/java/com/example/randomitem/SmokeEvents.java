package com.example.randomitem;

import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.entity.item.ItemTossEvent;
import net.neoforged.neoforge.event.server.ServerStartedEvent;

@EventBusSubscriber(modid="randomitem")
public final class SmokeEvents {
    @SubscribeEvent public static void tossed(ItemTossEvent event) {
        SmokeVerifier.recordDrop(event.getEntity());
    }
    @SubscribeEvent public static void started(ServerStartedEvent event) {
        SmokeVerifier.verify(event.getServer());
    }
}
