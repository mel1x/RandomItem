package com.example.randomitem;

import com.mojang.brigadier.CommandDispatcher;
import com.mojang.brigadier.arguments.IntegerArgumentType;
import net.minecraft.commands.CommandSourceStack;
import net.minecraft.commands.Commands;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public final class RandomItemCommand {
    private static final Random RANDOM = new Random();
    private RandomItemCommand() {}

    public static void register(CommandDispatcher<CommandSourceStack> dispatcher) {
        dispatcher.register(Commands.literal("getRandomItem")
                .requires(CommandPermissions::canUse)
                .executes(context -> give(context.getSource().getPlayerOrException(), 1, 1))
                .then(Commands.argument("count", IntegerArgumentType.integer(1, 27))
                        .executes(context -> give(context.getSource().getPlayerOrException(),
                                IntegerArgumentType.getInteger(context, "count"), 1))
                        .then(Commands.argument("maxStack", IntegerArgumentType.integer(1, 64))
                                .executes(context -> give(context.getSource().getPlayerOrException(),
                                        IntegerArgumentType.getInteger(context, "count"),
                                        IntegerArgumentType.getInteger(context, "maxStack"))))));
    }

    private static int give(ServerPlayer player, int count, int maxStack) {
        List<Item> items = new ArrayList<>();
        for (Item item : BuiltInRegistries.ITEM) {
            if (item != Items.AIR) items.add(item);
        }
        if (items.isEmpty()) return 0;
        for (int i = 0; i < count; i++) {
            ItemStack stack = new ItemStack(items.get(RANDOM.nextInt(items.size())));
            int limit = Math.min(maxStack, stack.getMaxStackSize());
            stack.setCount(RANDOM.nextInt(Math.max(1, limit)) + 1);
            player.getInventory().add(stack);
            if (!stack.isEmpty()) OverflowItems.drop(player, stack);
        }
        player.inventoryMenu.broadcastChanges();
        return 1;
    }
}
