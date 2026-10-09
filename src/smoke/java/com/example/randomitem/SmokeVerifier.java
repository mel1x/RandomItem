package com.example.randomitem;

import com.mojang.brigadier.exceptions.CommandSyntaxException;
import net.minecraft.server.MinecraftServer;
import net.minecraft.world.entity.item.ItemEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import com.mojang.authlib.GameProfile;
import net.minecraft.server.level.ClientInformation;
import net.minecraft.server.level.ServerPlayer;
import java.util.UUID;

public final class SmokeVerifier {
    private static boolean checkingOverflow;
    private static final java.util.List<ItemEntity> tossed = new java.util.ArrayList<>();
    public static void recordDrop(ItemEntity entity) { if (checkingOverflow) tossed.add(entity); }
    public static void verify(MinecraftServer server) {
        try {
            var player = new ServerPlayer(server, server.overworld(),
                    new GameProfile(UUID.fromString("39e93820-d3bd-4085-9a06-d860e53e0c9b"), "RandomItemTest"),
                    ClientInformation.createDefault());
            var inventory = player.getInventory();
            player.setPos(0, 100, 0);
            server.overworld().getChunkAt(player.blockPosition());
            var dispatcher = server.getCommands().getDispatcher();
            var source = server.createCommandSourceStack().withEntity(player).withSuppressedOutput();
            if (dispatcher.getRoot().getChild("getRandomItem") == null) throw new AssertionError("Command not registered");
            inventory.clearContent();
            for (int i = 0; i < 200; i++) {
                inventory.clearContent();
                if (dispatcher.execute("getRandomItem", source) != 1) throw new AssertionError("Command failed");
                if (total(inventory) != 1) throw new AssertionError("Default command gave air or wrong amount");
            }
            inventory.clearContent();
            dispatcher.execute("getRandomItem 27 1", source);
            if (total(inventory) != 27) throw new AssertionError("Wrong selection count");
            for (int i = 0; i < 20; i++) {
                inventory.clearContent();
                dispatcher.execute("getRandomItem 27 64", source);
                int count = total(inventory);
                if (count < 27 || count > 27 * 64) throw new AssertionError("Stack bounds violated");
            }
            for (String command : new String[]{"getRandomItem 0", "getRandomItem 28", "getRandomItem 1 0", "getRandomItem 1 65"}) {
                try { dispatcher.execute(command, source); throw new AssertionError("Accepted invalid arguments: " + command); }
                catch (CommandSyntaxException expected) { }
            }
            try { dispatcher.execute("getRandomItem", server.createCommandSourceStack()); throw new AssertionError("Accepted console source"); }
            catch (CommandSyntaxException expected) { }
            inventory.clearContent();
            for (int i = 0; i < inventory.getContainerSize(); i++) inventory.setItem(i, new ItemStack(Items.BEDROCK, 64));
            tossed.clear();
            checkingOverflow = true;
            dispatcher.execute("getRandomItem 27 1", source);
            checkingOverflow = false;
            if (tossed.size() != 27 || tossed.stream().anyMatch(entity -> entity.getItem().getCount() != 1 || entity.isRemoved())) {
                throw new AssertionError("Full inventory failed to toss 27 valid item entities: " + tossed.size());
            }
            System.out.println("RANDOMITEM_SMOKE_PASS: defaults, counts, stack caps, argument bounds, console rejection, overflow");
            server.halt(false);
        } catch (Exception e) { throw new RuntimeException("RandomItem smoke test failed", e); }
    }

    private static int total(net.minecraft.world.entity.player.Inventory inventory) {
        int total = 0;
        for (int i = 0; i < inventory.getContainerSize(); i++) {
            ItemStack stack = inventory.getItem(i);
            if (stack.getCount() > stack.getMaxStackSize()) throw new AssertionError("Overstacked item");
            total += stack.getCount();
        }
        return total;
    }
}
