package com.example.randomitem;

import com.mojang.brigadier.CommandDispatcher;
import com.mojang.brigadier.arguments.IntegerArgumentType;
import net.minecraft.commands.CommandSourceStack;
import net.minecraft.commands.Commands;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.server.level.ServerPlayer;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.event.RegisterCommandsEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.registries.ForgeRegistries;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Mod("randomitem")
public class RandomItemMod {
    private static final Random RANDOM = new Random();

    public RandomItemMod() {
        MinecraftForge.EVENT_BUS.register(this);
    }

    @SubscribeEvent
    public void onRegisterCommands(RegisterCommandsEvent event) {
        registerGetRandomItemCommand(event.getDispatcher());
    }

    private void registerGetRandomItemCommand(CommandDispatcher<CommandSourceStack> dispatcher) {
        dispatcher.register(
                Commands.literal("getRandomItem")
                        .requires(source -> source.hasPermission(2))
                        .executes(context -> executeGetRandomItem(context.getSource().getPlayerOrException(), 1, 1))
                        .then(Commands.argument("count", IntegerArgumentType.integer(1, 27))
                                .executes(context -> executeGetRandomItem(
                                        context.getSource().getPlayerOrException(),
                                        IntegerArgumentType.getInteger(context, "count"),
                                        1
                                ))
                                .then(Commands.argument("maxStack", IntegerArgumentType.integer(1, 64))
                                        .executes(context -> executeGetRandomItem(
                                                context.getSource().getPlayerOrException(),
                                                IntegerArgumentType.getInteger(context, "count"),
                                                IntegerArgumentType.getInteger(context, "maxStack")
                                        ))
                                )
                        )
        );
    }

    private int executeGetRandomItem(ServerPlayer player, int count, int maxStackSize) {
        for (int i = 0; i < count; i++) {
            ItemStack randomItem = getRandomItem(maxStackSize);
            player.getInventory().add(randomItem);
        }
        return 1;
    }

    private ItemStack getRandomItem(int maxRequestedStack) {
        List<Item> allItems = new ArrayList<>();
        ForgeRegistries.ITEMS.forEach(allItems::add);

        Item randomItem = allItems.get(RANDOM.nextInt(allItems.size()));

        // Получаем максимальный размер стака для данного предмета
        int itemMaxStackSize = randomItem.getMaxStackSize();

        // Если предмет стакается (максимальный стак больше 1)
        if (itemMaxStackSize > 1) {
            // Берём минимальное значение между запрошенным размером стака,
            // максимальным размером стака предмета и 64
            int effectiveMaxStack = Math.min(Math.min(maxRequestedStack, itemMaxStackSize), 64);
            // Генерируем случайное количество от 1 до effectiveMaxStack
            int randomStackSize = RANDOM.nextInt(effectiveMaxStack) + 1;
            return new ItemStack(randomItem, randomStackSize);
        } else {
            // Если предмет не стакается, всегда выдаём 1
            return new ItemStack(randomItem, 1);
        }
    }
}