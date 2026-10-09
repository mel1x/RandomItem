package com.example.randomitem;
import net.minecraft.commands.CommandSourceStack;
final class CommandPermissions {
    static boolean canUse(CommandSourceStack source) {
        return source.hasPermission(2);
    }
}
