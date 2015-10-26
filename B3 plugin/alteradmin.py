#
# MW3 B3 Plugin Written For AlterAdmin
#
# Purpose: To inprove banning efficency & inprove Overall Admin control
#

__version__ = '4.3.7'
__author__  = 'Luigi'

import re, time, threading, sys, traceback, thread, random
import ConfigParser

from b3 import functions
from b3 import clients
import b3.plugin
import copy
import b3, re, time
import b3.events
import urllib
import string
import httplib
import urllib

import b3
import b3.plugin
import b3.cron


class AlterAdminPlugin(b3.plugin.Plugin):
    _adminPlugin = None
    _BanList = []
    _parseUserCmdRE = re.compile(r"^(?P<cid>'[^']{2,}'|[0-9]+|[^\s]{2,}|@[0-9]+)(\s+(?P<parms>.*))?$")
    _currentVote = None
    _caller = None
    _in_progress = False
    _yes = 0
    _no = 0
    _vetoed = 0
    _times = 0
    _vote_times = 3
    _vote_interval = 0
	
    _votes = {}	
    def startup(self):
        """\
        Initialize plugin settings
        """
        self._adminPlugin = self.console.getPlugin('admin')
        if not self._adminPlugin:
            # something is wrong, can't start without admin plugin
            self.error('Could not find admin plugin')
            return False

        # register our commands
        if 'commands' in self.config.sections():
            for cmd in self.config.options('commands'):
                level = self.config.get('commands', cmd)
                sp = cmd.split('-')
                alias = None
                if len(sp) == 2:
                    cmd, alias = sp
                func = self.getCmd(cmd)
                if func:
                    self._adminPlugin.registerCommand(self, cmd, level, func, alias)
						
        msg = 'AlterAdmin Admin Plugin v. %s by %s started.' % (__version__, __author__)
        self.console.say(msg)
        
        f = open(self.config.getpath('settings', 'bansfile'),'r')
        for line in f:
            self._BanList.append(line.strip())
        self.registerEvent(b3.events.EVT_CLIENT_AUTH)
        self.registerEvent(b3.events.EVT_CLIENT_DISCONNECT)

        self.debug('Started')

    def getCmd(self, cmd):
        cmd = 'cmd_%s' % cmd
        if hasattr(self, cmd):
            func = getattr(self, cmd)
            return func
        return None

		
    def onEvent(self, event):
        """\
        Handle intercepted events
        """
		            	
        if event.type == b3.events.EVT_CLIENT_AUTH:
            event.client.setvar(self, 'muted', 0)
            if (event.client.ip or event.client.guid or event.client.exactName) in self._BanList:
                event.client.kick(reason="Super Banned", silent=False)


		
    def cmd_balance(self, data, client, cmd=None):
        """\
        <name> - balance players
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            sclient = client
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            self.console.say('^2Balanceing teams')
            self.console.write('balance 1')
            return True
			
    def cmd_ragequit(self, data, client, cmd=None):
        """\
        <name> - rage
        """
        m = self._adminPlugin.parseUserCmd(data)
        
        sclient = client

        if sclient:
            self.console.say('%s Just could not take it anymore! Good bye! (ragequit)'%sclient.exactName)
            self.console.write('clientkick %s "GoodBye! Let The Great MW2 Gods Bless you with many more ^1Ragequits!"'%sclient.cid)
            return True
			
    def cmd_rank(self, data, client, cmd=None):
        """\
        <name> - change a players prestieg to 11
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            sclient = client
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            self.console.say('^7Setting ^1%s ^7Prestige to 11'%sclient.exactName)
            self.console.write('rank %s'%sclient.cid)
            return True

    def cmd_unlock(self, data, client, cmd=None):
        """\
        <name> - Unlock player
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            sclient = client
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            self.console.say('^7Unlocking ^1%s ^7From the server'%sclient.exactName)
            self.console.write('unlock %s'%sclient.cid)
            return True

    def cmd_freeze(self, data, client, cmd=None):
        """\
        <name> - Freeze/Unfreeze player
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
          client.message('^7Invalid parameters, you must supply a player name')
          return False
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            self.console.say('^7Freeze/Unfreezeing ^1%s'%sclient.exactName)
            self.console.write('freeze %s'%sclient.cid)
            return True
			
    def cmd_space(self, data, client, cmd=None):
        """\
        <name> - Send player to space
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
          client.message('^7Invalid parameters, you must supply a player name')
          return False
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            self.console.say('^7Sending ^1%s ^7To space'%sclient.exactName)
            self.console.write('space %s'%sclient.cid)
            return True

    def cmd_lock(self, data, client, cmd=None):
        """\
        <name> - lock a player into the server
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
          client.message('^7Invalid parameters, you must supply a player name')
          return False
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
		
            if not m[1]:
				cmd.sayLoudOrPM(client,  '^1ERROR: ^7You must supply a reason')
				return False
            else:
                self._lockReason = ' '.join(m[1:])	
					
            self.console.say('^7Locking ^1%s ^7Into the server ^3(cant leave) ^7For: ^1%s'%(sclient.exactName,self._lockReason))
            self.console.write('lock %s'%sclient.cid)
            return True

    def cmd_prestige(self, data, client, cmd=None):
        """\
        <name> - change a players prestige
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
          client.message('^7Invalid parameters, you must supply a player name')
          return False
        else:
            sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
		
            if not m[1]:
				cmd.sayLoudOrPM(client,  '^1ERROR: ^7You must supply a Prestige!')
				return False
            else:
                self._prestige = ' '.join(m[1:])	
				
            self.console.write('prestige %s'%self._prestige)
            time.sleep(0.5)							
            self.console.write('setprestige %s'%sclient.cid)
            time.sleep(0.2) 			
            self.console.say('^2Setting ^1%s ^2Prestige to: ^3%s!'%(sclient.exactName,self._prestige))
            return True
			
			
    def cmd_bkick(self, data, client=None, cmd=None):
        """\
        <name> [<reason>] - kick a player with upgraded AlterAdmin kick function
        """
        
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
          client.message('^7Invalid parameters, you must supply a player name')
          return False
          
        sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            if sclient.maxLevel > client.maxLevel:
                self.console.say('Kick denied! , ^1Youfail.avi')
                return True
            else:
                self._kickTarget = sclient.cid
                self._kickTargetname = sclient.exactName
                self._kickIniter = client.exactName
                if not m[1]:
					cmd.sayLoudOrPM(client,  '^1ERROR: ^7You must supply a reason')
					return False
                else:
                    self._kickReason = ' '.join(m[1:])
                

                self.console.write('clientkick %s "^7^1Kicked by:^5 %s ^1Reason of Kick: ^5 %s "'%(self._kickTarget,self._kickIniter,self._kickReason))
                self.console.say('^7Player: ^2 %s ^1Kicked By:^3 %s ^7For:^2 %s'%(self._kickTargetname,self._kickIniter,self._kickReason))
                return True
        return True


		
    def cmd_fps(self, data, client, cmd=None):
        """\
        <name> - enable/disable r_fullbright for a client and/or self (olny admins)
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            sclient = client
        else:
			sclient = self._adminPlugin.findClientPrompt(m[0], client)
	if sclient:
            cmd.sayLoudOrPM(client,  'r_fullbright enabled/disabled! for %s'%sclient.exactName)
            self.console.write('fps %s'%sclient.cid)
            return True

    def cmd_iplookup(self, data, client, cmd=None):
        """\
        <ip> - search a given ip
	"""
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
          client.message('^7Invalid parameters, you must supply an ip')
          return False
        ip = m[0]
        cursor = self.console.storage.query("SELECT id, name, time_edit FROM clients WHERE ip = '%s'"%(ip))
        if cursor.rowcount == 0:
            cmd.sayLoudOrPM(client,  "No players are using this ip")
        else:
            cmd.sayLoudOrPM(client, "Players that use %s: " % (ip))
            while not cursor.EOF:
                msg = ""
                r = cursor.getRow()
                msg += "^7[^2@%s^7] %s (^3%s^7)" % (r['id'],  r['name'],  self.console.formatTime(r['time_edit']))
                cmd.sayLoudOrPM(client,  msg)
                cursor.moveNext()
        cursor.close()
        return True
    def cmd_ipalias(self, data, client, cmd=None):
        """\
        <name> - search players that have the same ip
	"""
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            client.message('^7Invalid parameters, you must supply a player name')
            return False
        sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            cursor = self.console.storage.query("SELECT id, name, time_edit FROM clients WHERE ip = '%s'"%(sclient.ip))
            if cursor.rowcount == 0:
                cmd.sayLoudOrPM(client,  "No players are using this ip")
            else:
                cmd.sayLoudOrPM(client, "Players that use %s: " % (sclient.ip))
                while not cursor.EOF:
                    msg = ""
                    r = cursor.getRow()
                    msg += "^7[^2@%s^7] %s (^3%s^7)" % (r['id'],  r['name'],  self.console.formatTime(r['time_edit']))
                    cmd.sayLoudOrPM(client,  msg)
                    cursor.moveNext()
            cursor.close()
        return True
    def cmd_clientip(self, data, client, cmd=None):
        """\
        <name> - Find a player's ip
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            client.message('^7Invalid parameters, you must supply a player name')
            return False
        sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            cmd.sayLoudOrPM(client, "IP of %s: %s"%(sclient.exactName, sclient.ip))
        return True
    def cmd_toadmins(self, data, client = None, cmd = None):
        """
        <message> - Message to broadcast to admins
        """
        adminList = self._adminPlugin.getAdmins()
        for admin in adminList:
            if admin != client:
                admin.message('^3[from ^1%s^3]^7%s'%(client.exactName,data))
        client.message('^7Message sent to online admins')
    def cmd_fastrestart(self, data, client, cmd=None):
        """\
        Restart the current map.
        """
        self.console.say('^2Fast map restart will be executed')
        time.sleep(2) 
        self.console.write('fast_restart')
        return True
    def cmd_rcon(self, data, client, cmd=None):
        """\
        <command> - Direct rcon command.
        """
        if not data:
            client.message('^7Missing command')
            return False
        else:
            self.console.say('^2Executing command: ^3%s'% data)
            time.sleep(2)
            self.console.write('%s' % data)
            return True
    def cmd_pm(self, data, client=None, cmd=None):
        """\
        <name> - Send a private to the player with the matching name
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            client.message('^7Invalid parameters, you must supply a player name')
            return False
        elif not m[1]:
            client.message('^7Invalid parameters, you must supply a message')
            return False
        sclient = self._adminPlugin.findClientPrompt(m[0], client)
        if sclient:
            client.message('^7Message sent to ^1%s'%sclient.exactName)
            msg = ' '.join(m[1:])
            sclient.message('^3[from ^1%s^3]^7%s'%(client.exactName,msg))
        return True
		
    def cmd_blackban(self, data, client, cmd=None):
        """\
        <name> - Super Ban a Player
        """
        m = self._adminPlugin.parseUserCmd(data)
        if not m:
            client.message('^7Invalid parameters, you must supply a player name')
            return False
        sclient = self._adminPlugin.findClientPrompt(m[0], client)
		
        if sclient:
            self.console.say('^7Banning ^3GUID ^2|| ^3IP ^7and ^3Name ^7From this Server.')
            f = open(self.config.getpath('settings', 'bansfile'),'a')
            f.write("----------------------------" )
            f.write("\n %s"%sclient.exactName)
            f.write("\n %s"%sclient.ip)
            f.write("\n %s"%sclient.guid)
            f.write("\n" )
            f.write("\n" )
            self._BanList.append(sclient.exactName)
            self._BanList.append(sclient.guid)
            self._BanList.append(sclient.ip)
            sclient.kick(reason="Black Ban",silent=False) 
        return True
