package com.example.randomitem;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.item.ItemStack;
final class OverflowItems {
    static void drop(ServerPlayer player, ItemStack stack) { player.drop(stack, false); }
}
