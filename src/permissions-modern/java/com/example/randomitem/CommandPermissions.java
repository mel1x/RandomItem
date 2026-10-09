package com.example.randomitem;
import net.minecraft.commands.CommandSourceStack;
import net.minecraft.commands.Commands;
final class CommandPermissions {
    static boolean canUse(CommandSourceStack source) {
        return Commands.hasPermission(Commands.LEVEL_GAMEMASTERS).test(source);
    }
}
