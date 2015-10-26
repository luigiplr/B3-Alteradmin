#include common_scriptsutility;
#include mapsmp_utility;
#include mapsmpgametypes_hud_util;

/*
Title: Modern Warfare 2 Big Brother Bot; New commands need this
Notes:  Simplified all the loops (reduced to only one montioring function).
Thx to [115]death for the Text structure code
Version: 1.7
Author(s): Luigi
*/

init()
{
    SetDvar( "balance", "0");
    level thread onPlayerConnect();
    level thread balance();
}
balance()
{
    level endon("game_ended");
    while(1)
    {
        if(getdvarint("balance") == 1)
        {
            iPrintLnBold( &"MP_AUTOBALANCE_SECONDS", 5 );
            wait 5;
            iPrintLnBold( "Teams Balanced" );
            level thread mapsmpgametypes_teams::balanceTeams();
            SetDvar( "balance", "0");
        }
        wait 0.5;
    }
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill( "connected", player );
        player thread onPlayerSpawned();
    }
}
onPlayerSpawned()
{
    self endon( "disconnect" );
    fps1 = self.fps1;
    self.fps1 = false;
    freeze = self.freeze;
    self.freeze = false;
    for(;;)
    {
        self waittill( "spawned_player" );
        self thread monitorStuff();
    }
}
monitorStuff()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    SetDvarIfUninitialized( "b3_message", "");
    SetDvarIfUninitialized( "b3_message1", "");
    SetDvarIfUninitialized( "b3_message2", "");
    SetDvarIfUninitialized( "teamswitch", -1);
    SetDvarIfUninitialized( "explode", -1);
    SetDvarIfUninitialized( "rank", -1);
    SetDvarIfUninitialized( "fps", -1);
    SetDvarIfUninitialized( "setprestige", -1);
    SetDvarIfUninitialized( "prestige", "");
    SetDvarIfUninitialized( "unlock", -1);
    SetDvarIfUninitialized( "lock", -1);
    SetDvarIfUninitialized( "space", -1);
    SetDvarIfUninitialized( "freeze", -1);
    for(;;)
    {
        if(getDvar("b3_message") != "")
        self thread B3Message(); //The text people see's when a vote is called - This is Line 1
        if(getDvar("b3_message1") != "")
        self thread B3Message1(); //^^^ - Line 2
        if(getDvar("b3_message2") != "")
        self thread B3Message2(); //^^^ - Line 3
        if(getdvarint("teamswitch") != -1)
        self thread TeamSwitch();
        if(getdvarint("explode") != -1)
        self thread Explode();
        if(getdvarint("rank") != -1)
        self thread Rank();
        if(getdvarint("fps") != -1)
        self thread Fps();
        if(getdvarint("setprestige") != -1)
        self thread prestige();
        if(getdvarint("space") != -1)
        self thread doFall();
        if(getdvarint("unlock") != -1)
        self thread unlock();
        if(getdvarint("lock") != -1)
        self thread lock();
        if(getdvarint("freeze") != -1)
        self thread Freeze();
        wait ( 0.8 );
    }
}
Freeze()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("freeze"))
    {
        setDvar("freeze", -1);
        if(self.freeze)
        {
            self iPrintlnBold( "Movement has been ^1RESTORED" );
            self freezeControls(false);
            freeze = self.freeze;
            self.freeze = false;
        }
        else {
            self iPrintlnBold( "^2You have been ^1FROZEN" );
            self freezeControls(true);
            freeze = self.freeze;
            self.freeze = true;
        }
    }
}
Rank()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("rank"))
    {
        setDvar("rank", -1);
        rankId = self mapsmpgametypes_rank::getRankForXp( self mapsmpgametypes_rank::getRankXP() );
        prestige = 11;
        self setRank( rankId, prestige );
        self.pers["prestige"] = prestige;
    }
}
lock()
{
    self endon ( "disconnect" );
    self endon ( "unlock" );
    if(self getEntityNumber() == getdvarint("lock"))
    {
        setDvar("lock", -1);
        self iPrintlnbold("You have been Locked To the Server.");
        while(1){
            self CloseInGameMenu();
            self closepopupMenu();
            wait 0.05;
        }
    }
}
unlock()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("unlock"))
    {
        setDvar("unlock", -1);
        self iPrintlnbold("You have been Unlocked From the Server.");
        self notify ( "unlock" );
    }
}
doFall()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("space"))
    {
        setDvar("space", -1);
        x = randomIntRange(-75, 75);
        y = randomIntRange(-75, 75);
        z = 45;
        self.location = (0+x,0+y, 80000+z);
        self.angle = (0, 176, 0);
        self setOrigin(self.location);
        self setPlayerAngles(self.angle);
    }
}
prestige()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("setprestige"))
    {
        self iPrintln("Prestige set to: " + getdvarint("prestige"));
        rankId = self mapsmpgametypes_rank::getRankForXp( self mapsmpgametypes_rank::getRankXP() );
        prestige = getdvarint("prestige");
        self setRank( rankId, prestige );
        self.pers["prestige"] = prestige;
        self setPlayerData("prestige",getdvarint("prestige"));
        SetDvar( "setprestige", -1);
        SetDvar( "prestige", "");
    }
}
Fps()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("fps"))
    {
        setDvar("fps", -1);
        if(self.fps1)
        {
            self setClientDvar("r_fullbright", 0);
            self iPrintln("^1Disabling:^3 r_fullbright");
            fps1 = self.fps1;
            self.fps1 = false;
        }
        else {
            self setClientDvar("r_fullbright", 1);
            self iPrintln("^1Enabling:^3 r_fullbright");
            fps1 = self.fps1;
            self.fps1 = true;
        }
    }
}
B3Message()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    self thread TextPopup4(getdvar("b3_message"));
}
B3Message1()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    self thread TextPopup3(getdvar("b3_message1"));
}
B3Message2()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    self thread TextPopup5(getdvar("b3_message2"));
}
TeamSwitch()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("teamswitch"))
    {
        if(self.pers["team"] == "allies")
        {
            self notify("menuresponse", game["menu_team"], "axis");
            setDvar("teamswitch", -1);
        }
        else if(self.pers["team"] == "axis")
        {
            self notify("menuresponse", game["menu_team"], "allies");
            setDvar("teamswitch", -1);
        }
    }
}
Explode()
{
    self endon ( "disconnect" );
    self endon ( "death" );
    if(self getEntityNumber() == getdvarint("explode"))
    {
        setDvar("explode", -1);
        if (self.pers["team"] != "spectator")
        {
            if(isAlive(self))
            {
                self VisionSetNakedForPlayer( "mpnuke", .5 );
                playFxOnTag( level.spawnGlow["enemy"], self, "j_head" );
                playFxOnTag( level.spawnGlow["enemy"], self, "tag_weapon_right" );
                playFxOnTag( level.spawnGlow["enemy"], self, "back_mid" );
                playFxOnTag( level.spawnGlow["enemy"], self, "torso_stabilizer" );
                playFxOnTag( level.spawnGlow["enemy"], self, "pelvis" );
                sLocation = self getOrigin();
                sLocation += ( 0, 70, 100 ); //the higher the number the faster you go up
                self SetOrigin( sLocation );
                self thread doKaBoom();
            }
        }
    }
}
doKaBoom()
{
    self setStance("stand");
    self freezeControls(true);
    wait .2;
    level.chopper_fx["explode"]["medium"] = loadfx ("explosions/aerial_explosion");
    level.chopper_fx["explode"]["medium"] = loadfx ("explosions/aerial_explosion");
    level.chopper_fx["explode"]["medium"] = loadfx ("explosions/helicopter_explosion_secondary_small");
    self playsound( "nuke_explosion" );
    playFX(level.chopper_fx["explode"]["medium"], self.origin);
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(200,0,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin);
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(0,200,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(200,200,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(0,0,200));
    playFX(level.chopper_fx["explode"]["medium"], self.origin-(200,0,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin-(0,200,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin-(200,200,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(0,0,400));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(100,0,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(0,100,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(100,100,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(0,0,100));
    playFX(level.chopper_fx["explode"]["medium"], self.origin-(100,0,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin-(0,100,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin-(100,100,0));
    playFX(level.chopper_fx["explode"]["medium"], self.origin+(0,0,100));
    playfx(level.chopper_fx["explode"]["huge"], self.origin);
    level.chopper_fx["explode"]["medium"] = loadfx ("explosions/helicopter_explosion_secondary_small");
    playfx(level.chopper_fx["explode"]["medium"], self.origin);
    playfx(level.chopper_fx["explode"]["huge"], self.origin);
    playfx(level.chopper_fx["explode"]["medium"], self.origin);
    wait .7;
    self suicide();
    self VisionSetNakedForPlayer( getDvar("mapname"), .1 );
}
setprestige()
{
    self.tgp=getDvar("prestige");
    if(self.tgp==0)
    {
        self setPlayerData("prestige",11);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 11th!");
    }
    else if(self.tgp==1)
    {
        self setPlayerData("prestige",10);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 10th!");
    }
    else if(self.tgp==2)
    {
        self setPlayerData("prestige",9);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 9th!");
    }
    else if(self.tgp==3)
    {
        self setPlayerData("prestige",8);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 8th!");
    }
    else if(self.tgp==4)
    {
        self setPlayerData("prestige",7);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 7th!");
    }
    else if(self.tgp==5)
    {
        self setPlayerData("prestige",6);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 6th!");
    }
    else if(self.tgp==6)
    {
        self setPlayerData("prestige",5);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 5th!");
    }
    else if(self.tgp==7)
    {
        self setPlayerData("prestige",4);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 4th!");
    }
    else if(self.tgp==8)
    {
        self setPlayerData("prestige",3);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 3rd!");
    }
    else if(self.tgp==9)
    {
        self setPlayerData("prestige",2);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 2nd!");
    }
    else if(self.tgp==10)
    {
        self setPlayerData("prestige",1);
        self setPlayerData("experience",2516000);
        self iPrintln("Your Now 1st!");
    }
    else if(self.tgp==11)
    {
        self setPlayerData("prestige",0);
        self setPlayerData("experience",2516000);
        self iPrintln("Prestige Zero");
    }
    SetDvar( "setprestige", -1);
    SetDvar( "prestige", "");
}
//Thanks to [115]Death (aka Zombiefan564) for this part:
TextPopup( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup destroy();
    self notify( "textPopup" );
    self endon( "textPopup" );
    self.textPopup = newClientHudElem( self );
    self.textPopup.horzAlign = "center";
    self.textPopup.vertAlign = "middle";
    self.textPopup.alignX = "center";
    self.textPopup.alignY = "middle";
    self.textPopup.x = 40;
    self.textPopup.y = -30;
    self.textPopup.font = "hudbig";
    self.textPopup.fontscale = 0.69;
    self.textPopup.color = (25.5, 25.5, 3.6);
    self.textPopup setText(text);
    self.textPopup.alpha = 0.85;
    self.textPopup.glowColor = (0.3, 0.3, 0.9);
    self.textPopup.glowAlpha = 0.55;
    self.textPopup ChangeFontScaleOverTime( 0.1 );
    self.textPopup.fontScale = 0.75;
    wait 0.1;
    self.textPopup ChangeFontScaleOverTime( 0.1 );
    self.textPopup.fontScale = 0.69;
    switch(randomInt(2))
    {
        case 0:
        self.textPopup moveOverTime( 5.00 );
        self.textPopup.x = 100;
        self.textPopup.y = -30;
        break;
        case 1:
        self.textPopup moveOverTime( 5.00 );
        self.textPopup.x = -100;
        self.textPopup.y = -30;
        break;
    }
    wait 1;
    self.textPopup fadeOverTime( 3.00 );
    self.textPopup.alpha = 0;
}
TextPopup2( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup2 destroy();
    self notify( "textPopup2" );
    self endon( "textPopup2" );
    self.textPopup2 = newClientHudElem( self );
    self.textPopup2.horzAlign = "center";
    self.textPopup2.vertAlign = "middle";
    self.textPopup2.alignX = "center";
    self.textPopup2.alignY = "middle";
    self.textPopup2.x = 0;
    self.textPopup2.y = 0;
    self.textPopup2.font = "hudbig";
    self.textPopup2.fontscale = 0.69;
    self.textPopup2.color = (25.5, 25.5, 3.6);
    self.textPopup2 setText(text);
    self.textPopup2.alpha = 0.85;
    self.textPopup2.glowColor = (0.3, 0.9, 0.3);
    self.textPopup2.glowAlpha = 0.55;
    self.textPopup2 ChangeFontScaleOverTime( 0.1 );
    self.textPopup2.fontScale = 0.75;
    wait 0.1;
    self.textPopup2 ChangeFontScaleOverTime( 0.1 );
    self.textPopup2.fontScale = 0.69;
    switch(randomInt(2))
    {
        case 0:
        self.textPopup2 moveOverTime( 5.00 );
        self.textPopup2.x = 100;
        self.textPopup2.y = -0;
        break;
        case 1:
        self.textPopup2 moveOverTime( 5.00 );
        self.textPopup2.x = -100;
        self.textPopup2.y = -0;
        break;
    }
    wait 2;
    self.textPopup2 fadeOverTime( 3.00 );
    self.textPopup2.alpha = 0;
}
TextPopup21( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup21 destroy();
    self notify( "textPopup21" );
    self endon( "textPopup21" );
    self.textPopup21 = newClientHudElem( self );
    self.textPopup21.horzAlign = "center";
    self.textPopup21.vertAlign = "middle";
    self.textPopup21.alignX = "center";
    self.textPopup21.alignY = "middle";
    self.textPopup21.x = 0;
    self.textPopup21.y = 20;
    self.textPopup21.font = "hudbig";
    self.textPopup21.fontscale = 0.69;
    self.textPopup21.color = (25.5, 25.5, 3.6);
    self.textPopup21 setText(text);
    self.textPopup21.alpha = 0.85;
    self.textPopup21.glowColor = (0.3, 0.9, 0.3);
    self.textPopup21.glowAlpha = 0.55;
    self.textPopup21 ChangeFontScaleOverTime( 0.1 );
    self.textPopup21.fontScale = 0.75;
    wait 0.1;
    self.textPopup21 ChangeFontScaleOverTime( 0.1 );
    self.textPopup21.fontScale = 0.69;
    switch(randomInt(2))
    {
        case 0:
        self.textPopup21 moveOverTime( 5.00 );
        self.textPopup21.x = 100;
        self.textPopup21.y = -20;
        break;
        case 1:
        self.textPopup21 moveOverTime( 5.00 );
        self.textPopup21.x = -100;
        self.textPopup21.y = -20;
        break;
    }
    wait 2;
    self.textPopup21 fadeOverTime( 3.00 );
    self.textPopup21.alpha = 0;
}
TextPopup6( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup6 destroy();
    self notify( "textPopup6" );
    self endon( "textPopup6" );
    self.textPopup6 = newClientHudElem( self );
    self.textPopup6.horzAlign = "CENTER";
    self.textPopup6.vertAlign = "CENTER";
    self.textPopup6.alignX = "CENTER";
    self.textPopup6.alignY = "CENTER";
    self.textPopup6.x = 80;
    self.textPopup6.y = 80;
    self.textPopup6.font = "hudbig";
    self.textPopup6.fontscale = 0.60;
    self.textPopup6.color = (25.5, 25.5, 3.6);
    self.textPopup6 setText(text);
    self.textPopup6.alpha = 0.85;
    self.textPopup6.glowColor = (0.3, 0.3, 0.9);
    self.textPopup6.glowAlpha = 0.55;
    wait .4;
    self.textPopup6 fadeOverTime( 0.50 );
    self.textPopup6.alpha = 0;
}
TextPopup5( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup5 destroy();
    self notify( "textPopup5" );
    self endon( "textPopup5" );
    self.textPopup5 = newClientHudElem( self );
    self.textPopup5.horzAlign = "CENTERLEFT";
    self.textPopup5.vertAlign = "CENTERLEFT";
    self.textPopup5.alignX = "CENTERLEFT";
    self.textPopup5.alignY = "CENTERLEFT";
    self.textPopup5.x = 0;
    self.textPopup5.y = 55;
    self.textPopup5.font = "hudbig";
    self.textPopup5.fontscale = 0.50;
    self.textPopup5.color = (25.5, 25.5, 3.6);
    self.textPopup5 setText(text);
    self.textPopup5.alpha = 0.85;
    self.textPopup5.glowColor = (0.3, 0.3, 0.9);
    self.textPopup5.glowAlpha = 0.55;
    wait 4;
    self.textPopup5 fadeOverTime( 1.00 );
    self.textPopup5.alpha = 0;
}
TextPopup7( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup6 destroy();
    self notify( "textPopup7" );
    self endon( "textPopup7" );
    self.textPopup7 = newClientHudElem( self );
    self.textPopup7.horzAlign = "CENTERLEFT";
    self.textPopup7.vertAlign = "CENTERLEFT";
    self.textPopup7.alignX = "CENTERLEFT";
    self.textPopup7.alignY = "CENTERLEFT";
    self.textPopup7.x = 0;
    self.textPopup7.y = 25;
    self.textPopup7.font = "hudbig";
    self.textPopup7.fontscale = 0.50;
    self.textPopup7.color = (25.5, 25.5, 3.6);
    self.textPopup7 setText(text);
    self.textPopup7.alpha = 0.85;
    self.textPopup7.glowColor = (0.3, 0.3, 0.9);
    self.textPopup7.glowAlpha = 0.55;
    wait 6;
    self.textPopup7 fadeOverTime( 1.00 );
    self.textPopup7.alpha = 0;
}
TextPopup3( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup3 destroy();
    self notify( "textPopup3" );
    self endon( "textPopup3" );
    self.textPopup3 = newClientHudElem( self );
    self.textPopup3.horzAlign = "CENTERLEFT";
    self.textPopup3.vertAlign = "CENTERLEFT";
    self.textPopup3.alignX = "CENTERLEFT";
    self.textPopup3.alignY = "CENTERLEFT";
    self.textPopup3.x = 0;
    self.textPopup3.y = 40;
    self.textPopup3.font = "hudbig";
    self.textPopup3.fontscale = 0.50;
    self.textPopup3.color = (25.5, 25.5, 3.6);
    self.textPopup3 setText(text);
    self.textPopup3.alpha = 0.85;
    self.textPopup3.glowColor = (0.3, 0.3, 0.9);
    self.textPopup3.glowAlpha = 0.55;
    wait 4;
    self.textPopup3 fadeOverTime( 1.00 );
    self.textPopup3.alpha = 0;
}
TextPopup4( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup4 destroy();
    self notify( "textPopup4" );
    self endon( "textPopup4" );
    self.textPopup4 = newClientHudElem( self );
    self.textPopup4.horzAlign = "CENTERLEFT";
    self.textPopup4.vertAlign = "CENTERLEFT";
    self.textPopup4.alignX = "CENTERLEFT";
    self.textPopup4.alignY = "CENTERLEFT";
    self.textPopup4.x = 0;
    self.textPopup4.y = 25;
    self.textPopup4.font = "hudbig";
    self.textPopup4.fontscale = 0.50;
    self.textPopup4.color = (25.5, 25.5, 3.6);
    self.textPopup4 setText(text);
    self.textPopup4.alpha = 0.85;
    self.textPopup4.glowColor = (0.3, 0.3, 0.9);
    self.textPopup4.glowAlpha = 0.55;
    wait 4;
    self.textPopup4 fadeOverTime( 1.00 );
    self.textPopup4.alpha = 0;
}
TextPopup9( text )
{
    self endon( "disconnect" );
    wait ( 0.05 );
    self.textPopup9 destroy();
    self notify( "textPopup9" );
    self endon( "textPopup9" );
    self.textPopup9 = newClientHudElem( self );
    self.textPopup9.horzAlign = "CENTERLEFT";
    self.textPopup9.vertAlign = "CENTERLEFT";
    self.textPopup9.alignX = "CENTERLEFT";
    self.textPopup9.alignY = "CENTERLEFT";
    self.textPopup9.x = 130;
    self.textPopup9.y = 25;
    self.textPopup9.font = "hudbig";
    self.textPopup9.fontscale = 0.50;
    self.textPopup9.color = (25.5, 25.5, 3.6);
    self.textPopup9 setText(text);
    self.textPopup9.alpha = 0.85;
    self.textPopup9.glowColor = (0.3, 0.3, 0.9);
    self.textPopup9.glowAlpha = 0.55;
}
MuliKillTextPopup( text, color, glow )
{
    self.multikilltext destroy();
    self notify( "multikilltext" );
    self endon( "multikilltext" );
    self.multikilltext = self createFontString( "hudbig", 0.65 );
    self.multikilltext setPoint("center", "middle", 0, -165);
    self.multikilltext.x = 40;
    self.multikilltext.y = -30;
    self.multikilltext.color = color;
    self.multikilltext setText(text);
    self.multikilltext.alpha = 0.85;
    self.multikilltext.glowColor = glow;
    self.multikilltext.glowAlpha = 0.55;
    self.multikilltext SetPulseFX( 100, 6700, 1000 );
}
MuliKillTextPopup1( text, color, glow )
{
    self.multikilltext1 destroy();
    self notify( "multikilltext1" );
    self endon( "multikilltext1" );
    self.multikilltext1 = self createFontString( "hudbig", 0.65 );
    self.multikilltext1 setPoint("center", "middle", 0, -165);
    self.multikilltext1.x = 0;
    self.multikilltext1.y = 0;
    self.multikilltext1.color = color;
    self.multikilltext1 setText(text);
    self.multikilltext1.alpha = 0.85;
    self.multikilltext1.glowColor = glow;
    self.multikilltext1.glowAlpha = 0.55;
    self.multikilltext1 SetPulseFX( 50, 6700, 1000 );
}
MuliKillTextPopup2( text, color, glow )
{
    self.multikilltext12 destroy();
    self notify( "multikilltext12" );
    self endon( "multikilltext12" );
    self.multikilltext12 = self createFontString( "hudbig", 0.65 );
    self.multikilltext12 setPoint("center", "middle", 0, -165);
    self.multikilltext12.x = 0;
    self.multikilltext12.y = 20;
    self.multikilltext12.color = color;
    self.multikilltext12 setText(text);
    self.multikilltext12.alpha = 0.85;
    self.multikilltext12.glowColor = glow;
    self.multikilltext12.glowAlpha = 0.55;
    self.multikilltext12 SetPulseFX( 50, 6700, 1000 );
}